import 'package:decimal/decimal.dart';
import 'package:didpay/features/account/account_balance.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:retry/retry.dart';
import 'package:tbdex/tbdex.dart';
import 'package:web5/web5.dart';

final tbdexServiceProvider = Provider((_) => TbdexService());

class TbdexService {
  Future<Map<Pfi, List<Offering>>> getOfferings(List<Pfi> pfis) async {
    final offeringsMap = <Pfi, List<Offering>>{};

    for (final pfi in pfis) {
      try {
        await TbdexHttpClient.listOfferings(pfi.did)
            .then((offerings) => offeringsMap[pfi] = offerings);
      } on Exception {
        rethrow;
      }
    }

    return offeringsMap;
  }

  Future<AccountBalance> getAccountBalance(List<Pfi> pfis) async {
    final balancesMap = <Pfi, List<Balance>>{};
    var totalAvailable = Decimal.zero;
    String? currencyCode;

    for (final pfi in pfis) {
      try {
        await TbdexHttpClient.listBalances(pfi.did).then((balances) {
          balancesMap[pfi] = balances;
          for (final balance in balances) {
            totalAvailable += Decimal.parse(balance.data.available);
            currencyCode ??= balance.data.currencyCode;
          }
        });
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
        await TbdexHttpClient.listExchanges(did, pfi.did)
            .then((exchanges) => exchangesMap[pfi] = exchanges);
      } on Exception catch (e) {
        if (e is ValidationError) continue;
        rethrow;
      }
    }

    return exchangesMap;
  }

  Future<Exchange> getExchange(
    BearerDid did,
    Pfi pfi,
    String exchangeId,
  ) async {
    Exchange exchange;
    try {
      exchange = await TbdexHttpClient.getExchange(did, pfi.did, exchangeId);
    } on Exception {
      rethrow;
    }

    return exchange;
  }

  Future<Rfq> sendRfq(
    BearerDid did,
    PaymentState paymentState,
  ) async {
    final rfq = Rfq.create(
      paymentState.selectedPfi?.did ?? '',
      did.uri,
      CreateRfqData(
        offeringId: paymentState.selectedOffering?.metadata.id ?? '',
        payin: CreateSelectedPayinMethod(
          amount: paymentState.payinAmount.toString(),
          kind: paymentState.selectedPayinMethod?.kind ?? '',
          paymentDetails:
              paymentState.transactionType == TransactionType.deposit
                  ? paymentState.formData ?? {}
                  : null,
        ),
        payout: CreateSelectedPayoutMethod(
          kind: paymentState.selectedPayoutMethod?.kind ?? '',
          paymentDetails:
              paymentState.transactionType != TransactionType.deposit
                  ? paymentState.formData ?? {}
                  : null,
        ),
        claims: paymentState.claims,
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

  Future<Order> submitOrder(BearerDid did, Pfi? pfi, String? exchangeId) async {
    await Future.delayed(const Duration(seconds: 1));
    final order = Order.create(pfi?.did ?? '', did.uri, exchangeId ?? '');
    await order.sign(did);
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      await TbdexHttpClient.submitOrder(order);
    } on Exception {
      rethrow;
    }

    return order;
  }

  Future<Quote> pollForQuote(
    BearerDid did,
    Pfi pfi,
    String exchangeId,
  ) =>
      retry(
        () async {
          final exchange = await getExchange(did, pfi, exchangeId);
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
