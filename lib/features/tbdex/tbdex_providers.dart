import 'package:didpay/config/config.dart';
import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/tbdex/rfq_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

final offeringsProvider =
    FutureProvider.family.autoDispose<List<Offering>, String>((ref, did) async {
  try {
    final country = ref.read(countryProvider);
    final pfi = Config.getPfi(country);
    final offerings = await TbdexHttpClient.getOfferings(
      pfi?.didUri ?? '',
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
    final country = ref.read(countryProvider);
    final pfi = Config.getPfi(country);

    final rfq = Rfq.create(
      pfi?.didUri ?? '',
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
