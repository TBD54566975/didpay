import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/shared/http_status.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';
import 'package:web5/web5.dart';

final tbdexServiceProvider = Provider((_) => TbdexService());

class TbdexService {
  Future<Map<Pfi, List<Offering>>> getOfferings(List<Pfi> pfis) async {
    final offeringsMap = <Pfi, List<Offering>>{};

    for (final pfi in pfis) {
      try {
        final response = await TbdexHttpClient.listOfferings(pfi.did);
        if (response.statusCode.category == HttpStatus.success) {
          offeringsMap[pfi] = response.data!;
        }
      } on Exception catch (_) {
        rethrow;
      }
    }

    if (offeringsMap.isEmpty) {
      throw Exception('no offerings found');
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
        final response = await TbdexHttpClient.listExchanges(did, pfi.did);
        if (response.statusCode.category == HttpStatus.success) {
          exchangesMap[pfi] = response.data!;
        } else {
          throw Exception(
            'failed to fetch exchanges with status code ${response.statusCode}',
          );
        }
      } on Exception {
        return exchangesMap;
      }
    }

    return exchangesMap;
  }

  Future<List<Message>> getExchange(
    BearerDid did,
    Pfi pfi,
    String exchangeId,
  ) async {
    final response =
        await TbdexHttpClient.getExchange(did, pfi.did, exchangeId);
    if (response.statusCode.category == HttpStatus.success) {
      return response.data!;
    }

    throw Exception(
      'failed to fetch exchange with status code ${response.statusCode}',
    );
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
          amount: paymentState.payinAmount ?? '',
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
    await Future.delayed(const Duration(seconds: 1));

    final response =
        await TbdexHttpClient.createExchange(rfq, replyTo: rfq.metadata.from);

    if (response.statusCode.category != HttpStatus.success) {
      throw Exception(
        'failed to send rfq with status code ${response.statusCode}',
      );
    }
    return rfq;
  }

  Future<Order> submitOrder(BearerDid did, Pfi? pfi, String? exchangeId) async {
    await Future.delayed(const Duration(seconds: 1));
    final order = Order.create(pfi?.did ?? '', did.uri, exchangeId ?? '');
    await order.sign(did);
    await Future.delayed(const Duration(seconds: 1));

    final response = await TbdexHttpClient.submitOrder(order);

    if (response.statusCode.category != HttpStatus.success) {
      throw Exception(
        'failed to send order with status code ${response.statusCode}',
      );
    }
    return order;
  }
}
