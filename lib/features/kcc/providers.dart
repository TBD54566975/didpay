import 'dart:math';

import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/kcc/kcc_issuance_service.dart';
import 'package:didpay/features/kcc/lib.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:equatable/equatable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:retry/retry.dart';

final kccIssuanceServiceProvider = Provider<KccIssuanceService>((ref) {
  return KccIssuanceService();
});

final idvRequestProvider = FutureProvider.family<IdvRequest, NuPfi>(
  (ref, pfi) async {
    final kccIssuanceService = ref.read(kccIssuanceServiceProvider);
    final bearerDidProvider = ref.read(didProvider);

    return kccIssuanceService.getIdvRequest(pfi, bearerDidProvider);
  },
);

final accessTokenProvider =
    FutureProvider.family<TokenResponse, ({NuPfi pfi, IdvRequest idvRequest})>(
        (ref, params) async {
  final bearerDid = ref.read(didProvider);
  final kccIssuanceService = ref.read(kccIssuanceServiceProvider);

  return retry(
    () => kccIssuanceService.getAccessToken(
      params.pfi,
      params.idvRequest,
      bearerDid,
    ),
    retryIf: (e) {
      if (e is TokenResponseException) {
        return e.errorCode == TokenResponseErrorCode.authorizationPending;
      }
      return false;
    },
  );
});

final verifiableCredentialProvider = FutureProvider.family<
    CredentialResponse,
    ({
      NuPfi pfi,
      IdvRequest idvRequest,
    })>(
  (ref, params) async {
    final bearerDid = ref.read(didProvider);
    final kccIssuanceService = ref.read(kccIssuanceServiceProvider);

    final tokenResponse = await retry(
      () => kccIssuanceService.getAccessToken(
        params.pfi,
        params.idvRequest,
        bearerDid,
      ),
      retryIf: (e) {
        if (e is TokenResponseException) {
          return e.errorCode == TokenResponseErrorCode.authorizationPending;
        }
        return false;
      },
    );

    return kccIssuanceService.getVerifiableCredential(
      params.pfi,
      params.idvRequest,
      tokenResponse,
      bearerDid,
    );
  },
);
