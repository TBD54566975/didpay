import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/tbdex/rfq_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

final offeringsProvider =
    FutureProvider.family.autoDispose<List<Offering>, String>((ref, did) async {
  try {
    // TODO(ethan-tbd): don't hardcode the DID, https://github.com/TBD54566975/didpay/issues/133
    final offerings = await TbdexHttpClient.getOfferings(
      'did:web:localhost%3A8892:ingress',
    );
    return offerings;
  } on Exception catch (e) {
    throw Exception('Failed to load offerings: $e');
  }
});

final rfqProvider =
    FutureProvider.family.autoDispose<void, RfqState>((ref, rfqState) async {
  try {
    final did = ref.read(didProvider);

    // TODO(ethan-tbd): don't hardcode the DID, https://github.com/TBD54566975/didpay/issues/133
    final rfq = Rfq.create(
      'did:web:localhost%3A8892:ingress',
      did.uri,
      CreateRfqData(
        offeringId: rfqState.offeringId ?? '',
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

    await TbdexHttpClient.createExchange(rfq, replyTo: rfq.metadata.from);
  } on Exception catch (e) {
    throw Exception('Failed to load RFQ: $e');
  }
});

// TODO(ethan-tbd): add providers for other tbdex client methods below
