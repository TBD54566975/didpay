import 'package:didpay/config/config.dart';
import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/tbdex/rfq_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class Tbdex {
  static Rfq createRfq(WidgetRef ref, RfqState rfqState) {
    final did = ref.read(didProvider);
    final country = ref.read(countryProvider);
    final pfi = Config.getPfi(country);

    return Rfq.create(
      pfi?.didUri ?? '',
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
  }

  // TODO(ethan-tbd): create order, https://github.com/TBD54566975/didpay/issues/115
}
