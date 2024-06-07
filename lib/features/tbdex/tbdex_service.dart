import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/tbdex/tbdex_exceptions.dart';
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
          try {
            final exchange = await getExchange(did, pfi, exchangeId);
            return _getQuote(exchange);
          } on Exception catch (e) {
            throw QuoteNotFoundException(
              message: 'no quote found in exchange $exchangeId',
              cause: e,
            );
          }
        },
        maxAttempts: 15,
        maxDelay: const Duration(seconds: 10),
        retryIf: (e) => e is QuoteNotFoundException,
      );

  Quote _getQuote(Exchange exchange) => exchange.firstWhere(
        (message) => message.metadata.kind == MessageKind.quote,
        orElse: () => throw QuoteNotFoundException(
          message: 'no quote found in exchange ${exchange.first.metadata.id}',
        ),
      ) as Quote;
}
