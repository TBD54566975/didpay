import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/kcc/kcc_issuance_service.dart';
import 'package:didpay/features/kcc/lib/idv_request.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/vcs/vcs_notifier.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/async/async_error_widget.dart';
import 'package:didpay/shared/async/async_loading_widget.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class KccRetrievalPage extends HookConsumerWidget {
  final Pfi pfi;
  final IdvRequest idvRequest;

  const KccRetrievalPage({
    required this.pfi,
    required this.idvRequest,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credentialResponse =
        useState<AsyncValue<String>>(const AsyncLoading());

    useEffect(
      () {
        Future.microtask(
          () async => _pollForCredential(ref, credentialResponse),
        );

        return null;
      },
      [],
    );

    return Scaffold(
      body: SafeArea(
        child: credentialResponse.value.when(
          loading: () =>
              AsyncLoadingWidget(text: Loc.of(context).verifyingYourIdentity),
          error: (error, stackTrace) => AsyncErrorWidget(
            text: error.toString(),
            onRetry: () => _pollForCredential(ref, credentialResponse),
          ),
          data: (data) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: Grid.xl),
                    Text(
                      Loc.of(context).identityVerificationComplete,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: Grid.xs),
                    Icon(
                      Icons.check_circle,
                      size: Grid.xl,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Grid.side),
                child: FilledButton(
                  onPressed: () => Navigator.of(context, rootNavigator: true)
                      .pop(credentialResponse.value.asData?.value),
                  child: Text(Loc.of(context).next),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pollForCredential(
    WidgetRef ref,
    ValueNotifier<AsyncValue<String>> state,
  ) async {
    try {
      final credential = await ref.read(kccIssuanceProvider).pollForCredential(
            pfi,
            idvRequest,
            ref.read(didProvider),
          );

      await ref.read(vcsProvider.notifier).add(credential).then(
            (credential) => state.value = AsyncData(credential),
          );
    } on Exception catch (e, stackTrace) {
      state.value = AsyncError(e, stackTrace);
    }
  }
}
