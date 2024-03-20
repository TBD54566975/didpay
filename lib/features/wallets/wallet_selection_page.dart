import 'package:collection/collection.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfi_verification_page.dart';
import 'package:didpay/features/wallets/wallet.dart';
import 'package:didpay/features/wallets/wallets_provider.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/services/linking_service.dart';
import 'package:didpay/services/service_providers.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web5/web5.dart';

class WalletSelectionPage extends HookConsumerWidget {
  final Pfi pfi;

  const WalletSelectionPage({required this.pfi, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletsProvider);
    final selectedWallet =
        useState<Wallet?>(Wallet(name: 'DidPay', url: 'didpay://'));

    return Scaffold(
      appBar: AppBar(),
      body: switch (wallets) {
        AsyncError(:final error) =>
          Center(child: Text('${Loc.of(context).error}: $error')),
        AsyncData(:final value) => SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(
                  context,
                  Loc.of(context).selectWallet,
                  Loc.of(context).selectWalletDescription,
                ),
                Expanded(
                  child: SizedBox(
                    height: Grid.sm,
                    child: _buildWalletList(context, selectedWallet, value),
                  ),
                ),
                _buildNextButton(context, ref, selectedWallet.value),
              ],
            ),
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _buildWalletList(
    BuildContext context,
    ValueNotifier<Wallet?> selectedWalletState,
    List<Wallet> wallets,
  ) =>
      ListView(
        children: wallets
            .map(
              (wallet) => ListTile(
                title: Text(
                  wallet.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
                ),
                leading: Container(
                  width: Grid.md,
                  height: Grid.md,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(Grid.xxs),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.wallet,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                trailing: (selectedWalletState.value?.name == wallet.name)
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  selectedWalletState.value = wallet;

                  if (selectedWalletState.value?.name == 'DidPay') {
                    return;
                  }

                  showModalBottomSheet<void>(
                    context: context,
                    builder: (context) {
                      return Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: Grid.sm),
                        height: 200,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'You have elected to store your credential in the TBD Identity Wallet. Make sure you have the TBD Identity Wallet app installed in order to continue.',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
            .toList(),
      );

  Widget _buildHeader(BuildContext context, String title, String subtitle) =>
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Grid.side,
          vertical: Grid.xs,
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: Grid.xs),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );

  Widget _buildNextButton(
    BuildContext context,
    WidgetRef ref,
    Wallet? selectedWallet,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Grid.side),
        child: FilledButton(
          onPressed: () async {
            if (selectedWallet?.name == 'DidPay') {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return PfiVerificationPage(pfi: pfi);
                  },
                ),
              );
            } else {
              final result = await DidResolver.resolve(pfi.didUri);
              final widgetService = result.didDocument?.service
                  ?.firstWhereOrNull((e) => e.type == 'IDV');

              final oidcParams =
                  await ref.read(idvServiceProvider).getAuthRequest(
                        'http://${widgetService?.serviceEndpoint}',
                      );
              await LinkingService().launchWallet(
                oidcParams.claims.misc,
                selectedWallet?.url,
              );
            }
          },
          child: Text(Loc.of(context).next),
        ),
      );
}
