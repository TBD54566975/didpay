import 'package:decimal/decimal.dart';
import 'package:didpay/features/account/account_balance.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:retry/retry.dart';
import 'package:tbdex/tbdex.dart';
import 'package:web5/web5.dart';

final tbdexServiceProvider = Provider((_) => TbdexService());

class TbdexService {
  Future<Map<Pfi, List<Offering>>> getOfferings(
    List<Pfi> pfis, {
    List<String>? payinCurrencies,
    List<String>? payoutCurrencies,
  }) async {
    final offeringsMap = <Pfi, List<Offering>>{};

    for (final pfi in pfis) {
      try {
        final offerings = await TbdexHttpClient.listOfferings(
          pfi.did,
          // TODO(ethan-tbd): update tbdex-dart to support list of payin and payout currencies
          // filter: GetOfferingsFilter(
          //   payinCurrency: payinCurrency,
          //   payoutCurrency: payoutCurrency,
          // ),
        );

        // TODO(ethan-tbd): remove when tbdex-dart supports filtering by payin and payout currencies
        final filteredOfferings = (payoutCurrencies == null)
            ? offerings
            : offerings
                .where(
                  (offering) => payoutCurrencies.contains(
                    offering.data.payout.currencyCode.toLowerCase(),
                  ),
                )
                .toList();

        if (filteredOfferings.isNotEmpty) {
          offeringsMap[pfi] = filteredOfferings;
        }
      } on Exception catch (e) {
        if (e is ValidationError) continue;
        rethrow;
      }
    }

    if (offeringsMap.isEmpty) {
      throw Exception(
        'No offerings found for any linked PFIs',
      );
    }

    // TODO(ethan-tbd): remove later, temporarily filter out stored balance payin offerings
    final filteredOfferingsMap = offeringsMap.map(
      (key, value) => MapEntry(
        key,
        value
            .where(
              (offering) =>
                  offering.data.payin.methods.firstOrNull?.kind !=
                  'USD_STOREDBAL_PAYIN',
            )
            .toList(),
      ),
    );

    return filteredOfferingsMap;
  }

  Future<AccountBalance> getAccountBalance(
    BearerDid did,
    List<Pfi> pfis,
  ) async {
    final balancesMap = <Pfi, List<Balance>>{};
    var totalAvailable = Decimal.zero;
    String? currencyCode;

    for (final pfi in pfis) {
      try {
        final balances = await TbdexHttpClient.listBalances(did, pfi.did);
        balancesMap[pfi] = balances;

        for (final balance in balances) {
          totalAvailable += Decimal.parse(balance.data.available);
          currencyCode ??= balance.data.currencyCode;
        }
      } on Exception catch (e) {
        if (e is ResponseError) continue;
        rethrow;
      }
    }

    return AccountBalance(
      total: totalAvailable.toString(),
      currencyCode: currencyCode ?? '',
      balancesMap: balancesMap,
    );
  }

  Future<Map<Pfi, List<String>>> getExchanges(
    BearerDid did,
    List<Pfi> pfis,
  ) async {
    final exchangesMap = <Pfi, List<String>>{};

    for (final pfi in pfis) {
      try {
        final exchanges = await TbdexHttpClient.listExchanges(did, pfi.did);

        final validExchanges = await Future.wait(
          exchanges.map((exchangeId) async {
            final isComplete =
                await _isCompleteExchange(did, pfi.did, exchangeId);
            return isComplete ? exchangeId : null;
          }),
        );

        final filteredExchanges = validExchanges.whereType<String>().toList();

        if (filteredExchanges.isNotEmpty) exchangesMap[pfi] = filteredExchanges;
      } on Exception catch (e) {
        if (e is ValidationError) continue;
        rethrow;
      }
    }

    return exchangesMap;
  }

  Future<bool> _isCompleteExchange(
    BearerDid did,
    String pfiDid,
    String exchangeId,
  ) async {
    try {
      final exchange = await getExchange(
        did,
        pfiDid,
        exchangeId,
      );

      return exchange
          .any((message) => message.metadata.kind == MessageKind.orderstatus);
    } on Exception {
      return false;
    }
  }

  Future<Exchange> getExchange(
    BearerDid did,
    String pfiDid,
    String exchangeId,
  ) async {
    Exchange exchange;
    try {
      exchange = await TbdexHttpClient.getExchange(did, pfiDid, exchangeId);
    } on Exception {
      rethrow;
    }

    return exchange;
  }

  Future<Rfq> sendRfq(
    BearerDid did,
    String pfiDid,
    String offeringId,
    String payinAmount,
    String payinKind,
    String payoutKind,
    Map<String, String>? payinDetails,
    Map<String, String>? payoutDetails, {
    List<String>? claims,
  }) async {
    final rfq = Rfq.create(
      pfiDid,
      did.uri,
      CreateRfqData(
        offeringId: offeringId,
        payin: CreateSelectedPayinMethod(
          amount: payinAmount,
          kind: payinKind,
          paymentDetails: payinDetails,
        ),
        payout: CreateSelectedPayoutMethod(
          kind: payoutKind,
          paymentDetails: payoutDetails,
        ),
        claims: claims,
      ),
    );

    await rfq.sign(did);

    try {
      await TbdexHttpClient.createExchange(rfq);
    } on Exception {
      rethrow;
    }

    return rfq;
  }

  Future<Order> sendOrder(
    BearerDid did,
    String pfiDid,
    String exchangeId,
  ) async {
    final order = Order.create(pfiDid, did.uri, exchangeId);
    await order.sign(did);

    try {
      await TbdexHttpClient.submitOrder(order);
    } on Exception {
      rethrow;
    }

    return order;
  }

  Future<Cancel> sendCancel(
    BearerDid did,
    String pfiDid,
    String exchangeId,
  ) async {
    final cancelData = CancelData(reason: 'User requested');
    final cancel = Cancel.create(pfiDid, did.uri, exchangeId, cancelData);
    await cancel.sign(did);

    try {
      await TbdexHttpClient.submitCancel(cancel);
    } on Exception {
      rethrow;
    }

    return cancel;
  }

  Future<Quote> pollForQuote(
    BearerDid did,
    String pfiDid,
    String exchangeId,
  ) =>
      retry(
        () async {
          final exchange = await getExchange(did, pfiDid, exchangeId);
          return _getQuote(exchange);
        },
        maxAttempts: 15,
        maxDelay: const Duration(seconds: 10),
        retryIf: (e) => e is _QuoteNotFoundException,
      );

  Quote _getQuote(Exchange exchange) => exchange.firstWhere(
        (message) => message.metadata.kind == MessageKind.quote,
        orElse: () => throw _QuoteNotFoundException(),
      ) as Quote;
}

class _QuoteNotFoundException implements Exception {}
