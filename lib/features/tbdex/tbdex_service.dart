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
    String? payinCurrency,
    String? payoutCurrency,
  }) async {
    final offeringsMap = <Pfi, List<Offering>>{};

    for (final pfi in pfis) {
      try {
        final offerings = await TbdexHttpClient.listOfferings(
          pfi.did,
          filter: GetOfferingsFilter(
            payinCurrency: payinCurrency,
            payoutCurrency: payoutCurrency,
          ),
        );

        offeringsMap[pfi] = offerings;
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

    await Future.delayed(const Duration(milliseconds: 500));

    return offeringsMap;
  }

  Future<AccountBalance> getAccountBalance(List<Pfi> pfis) async {
    final balancesMap = <Pfi, List<Balance>>{};
    var totalAvailable = Decimal.zero;
    String? currencyCode;

    for (final pfi in pfis) {
      try {
        final balances = await TbdexHttpClient.listBalances(pfi.did);
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
            final isValid = await _isValidExchange(did, pfi.did, exchangeId);
            return isValid ? exchangeId : null;
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

  Future<bool> _isValidExchange(
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
          .any((message) => message.metadata.kind == MessageKind.quote);
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
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      await TbdexHttpClient.createExchange(rfq, replyTo: rfq.metadata.from);
    } on Exception {
      rethrow;
    }

    return rfq;
  }

  Future<Order> submitOrder(
    BearerDid did,
    String pfiDid,
    String exchangeId,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    final order = Order.create(pfiDid, did.uri, exchangeId);
    await order.sign(did);
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      await TbdexHttpClient.submitOrder(order);
    } on Exception {
      rethrow;
    }

    return order;
  }

  Future<Close> submitClose(
    BearerDid did,
    String pfiDid,
    String exchangeId,
  ) async {
    final closeData = CloseData(reason: 'User requested');
    final close = Close.create(pfiDid, did.uri, exchangeId, closeData);
    await close.sign(did);

    try {
      await TbdexHttpClient.submitClose(close);
    } on Exception {
      rethrow;
    }

    return close;
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
