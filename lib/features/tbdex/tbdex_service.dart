import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/tbdex/rfq_state.dart';
import 'package:didpay/shared/http_status.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';
import 'package:web5/web5.dart';

final tbdexServiceProvider = Provider((_) => TbdexService());

class TbdexService {
  // TODO(ethan-tbd): return Map<Pfi, List<Offering>>
  Future<List<Offering>> getOfferings(List<Pfi> pfis) async {
    final offerings = <Offering>[];

    for (final pfi in pfis) {
      final response = await TbdexHttpClient.listOfferings(pfi.did);
      if (response.statusCode.category == HttpStatus.success) {
        offerings.addAll(response.data!);
      }
    }

    if (offerings.isEmpty) {
      throw Exception('no offerings found');
    }

    return offerings;
  }

  Future<Map<Pfi, List<String>>> getExchanges(
    BearerDid did,
    List<Pfi> pfis,
  ) async {
    final exchangeMap = <Pfi, List<String>>{};

    for (final pfi in pfis) {
      try {
        final response = await TbdexHttpClient.listExchanges(did, pfi.did);
        if (response.statusCode.category == HttpStatus.success) {
          exchangeMap[pfi] = response.data!;
        } else {
          throw Exception(
            'failed to fetch exchanges with status code ${response.statusCode}',
          );
        }
      } on Exception {
        return exchangeMap;
      }
    }

    return exchangeMap;
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

  Future<Rfq> sendRfq(BearerDid did, Pfi pfi, RfqState rfqState) async {
    final rfq = Rfq.create(
      pfi.did,
      did.uri,
      CreateRfqData(
        offeringId: rfqState.offering?.metadata.id ?? '',
        payin: CreateSelectedPayinMethod(
          amount: rfqState.payinAmount ?? '',
          kind: rfqState.payinMethod?.kind ?? '',
        ),
        payout: CreateSelectedPayoutMethod(
          kind: rfqState.payoutMethod?.kind ?? '',
        ),
        claims: [],
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

  Future<Order> submitOrder(BearerDid did, Pfi pfi, String exchangeId) async {
    final order = Order.create(pfi.did, did.uri, exchangeId);
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
