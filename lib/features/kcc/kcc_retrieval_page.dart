import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/kcc/kcc_issuance_service.dart';
import 'package:didpay/features/kcc/lib.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/l10n/app_localizations.dart';
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
    final bearerDid = ref.watch(didProvider);
    final kccIssuanceService = ref.watch(kccIssuanceProvider);
    final credentialResponse =
        useState<AsyncValue<CredentialResponse>>(const AsyncLoading());

    useEffect(
      () {
        Future.microtask(() async {
          try {
            final value = await kccIssuanceService.pollForCredential(
              pfi,
              idvRequest,
              bearerDid,
            );
            credentialResponse.value = AsyncData(value);
          } on Exception catch (e, stackTrace) {
            credentialResponse.value = AsyncError(e, stackTrace);
          }
        });

        return;
      },
      [],
    );

    return Scaffold(
      body: SafeArea(
        child: credentialResponse.value.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error - $error')),
          data: (data) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: Grid.xl),
                      Text(
                        'Your KCC has been issued and stored on your device!',
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
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: Text(Loc.of(context).done),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
