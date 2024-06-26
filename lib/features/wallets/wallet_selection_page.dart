import 'package:didpay/features/pfis/pfi.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class WalletSelectionPage extends HookConsumerWidget {
  final Pfi pfi;

  const WalletSelectionPage({required this.pfi, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold();

    // final wallets = ref.watch(walletsProvider);
    // final selectedWallet =
    //     useState<Wallet?>(Wallet(name: 'DidPay', url: 'didpay://'));
    //   return Scaffold(
    //     appBar: AppBar(),
    //     body: switch (wallets) {
    //       AsyncError(:final error) =>
    //         Center(child: Text('${Loc.of(context).error}: $error')),
    //       AsyncData(:final value) => SafeArea(
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.stretch,
    //             children: [
    //               Header(
    //                 title: Loc.of(context).selectWallet,
    //                 subtitle: Loc.of(context).selectWalletDescription,
    //               ),
    //               Expanded(
    //                 child: SizedBox(
    //                   height: Grid.sm,
    //                   child: _buildWalletList(context, selectedWallet, value),
    //                 ),
    //               ),
    //               _buildNextButton(context, ref, selectedWallet.value),
    //             ],
    //           ),
    //         ),
    //       _ => const Center(child: CircularProgressIndicator()),
    //     },
    //   );
  }

  // Widget _buildWalletList(
  //   BuildContext context,
  //   ValueNotifier<Wallet?> selectedWalletState,
  //   List<Wallet> wallets,
  // ) =>
  //     ListView(
  //       children: wallets
  //           .map(
  //             (wallet) => ListTile(
  //               title: Text(
  //                 wallet.name,
  //                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
  //               ),
  //               leading: Container(
  //                 width: Grid.md,
  //                 height: Grid.md,
  //                 decoration: BoxDecoration(
  //                   color: Theme.of(context).colorScheme.surface,
  //                   borderRadius: BorderRadius.circular(Grid.xxs),
  //                 ),
  //                 child: Center(
  //                   child: Icon(
  //                     Icons.wallet,
  //                     color: Theme.of(context).colorScheme.primary,
  //                   ),
  //                 ),
  //               ),
  //               trailing: (selectedWalletState.value?.name == wallet.name)
  //                   ? Icon(
  //                       Icons.check,
  //                       color: Theme.of(context).colorScheme.primary,
  //                     )
  //                   : null,
  //               onTap: () {
  //                 selectedWalletState.value = wallet;

  //                 if (selectedWalletState.value?.name == 'DidPay') {
  //                   return;
  //                 }

  //                 showModalBottomSheet<void>(
  //                   context: context,
  //                   builder: (context) {
  //                     return Container(
  //                       padding:
  //                           const EdgeInsets.symmetric(horizontal: Grid.sm),
  //                       height: 200,
  //                       child: const Center(
  //                         child: Column(
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: <Widget>[
  //                             Text(
  //                               'You have elected to store your credential in the TBD Identity Wallet. Make sure you have the TBD Identity Wallet app installed in order to continue.',
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                 );
  //               },
  //             ),
  //           )
  //           .toList(),
  //     );

  // Widget _buildNextButton(
  //   BuildContext context,
  //   WidgetRef ref,
  //   Wallet? selectedWallet,
  // ) =>
  //     Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: Grid.side),
  //       child: FilledButton(
  //         onPressed: () async {
  //           if (selectedWallet?.name == 'DidPay') {
  //             await Navigator.of(context).push(
  //               MaterialPageRoute(
  //                 builder: (context) {
  //                   return PfiVerificationPage(pfi: pfi);
  //                 },
  //               ),
  //             );
  //           } else {
  //             final result = await DidResolver.resolve(pfi.didUri);
  //             final widgetService = result.didDocument?.service
  //                 ?.firstWhereOrNull((e) => e.type == 'IDV');

  //             final oidcParams =
  //                 await ref.read(idvServiceProvider).getAuthRequest(
  //                       'http://${widgetService?.serviceEndpoint}',
  //                     );
  //             await WalletLinkingService().launchWallet(
  //               oidcParams.claims.misc,
  //               selectedWallet?.url,
  //             );
  //           }
  //         },
  //         child: Text(Loc.of(context).next),
  //       ),
  //     );
}
