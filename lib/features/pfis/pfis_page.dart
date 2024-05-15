import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PfisPage extends ConsumerWidget {
  const PfisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pfis = ref.watch(pfisNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PFIs Yo'),
            ListView(
              shrinkWrap: true,
              children: pfis.map((pfi) {
                return ListTile(
                  title: Text(pfi.did),
                );
              }).toList(),
            ),
            _buildAddPfiButton(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPfiButton(BuildContext context, WidgetRef ref) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Grid.side),
        child: FilledButton(
          onPressed: () async {
            final pfisNotifier = ref.read(pfisNotifierProvider.notifier);
            try {
              await pfisNotifier.add('did:web:www.linkedin.com');
            } on Exception catch (e) {
              print(e);
            }
          },
          child: Text(Loc.of(context).next),
        ),
      );
}
// Widget _buildScanQr(
//     BuildContext context,
//     TextEditingController recipientDidController,
//     ValueNotifier<String?> errorText,
//     ValueNotifier<bool> isPhysicalDevice,
//     String did,
//   ) =>
//       Padding(
//         padding: const EdgeInsets.symmetric(vertical: Grid.xxs),
//         child: ListTile(
//           leading: const Icon(Icons.qr_code),
//           title: Text(
//             Loc.of(context).scanQrCode,
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//           trailing: const Icon(Icons.chevron_right),
//           onTap: () => isPhysicalDevice.value
//               ? _scanQrCode(
//                   context,
//                   recipientDidController,
//                   errorText,
//                   Loc.of(context).noDidQrCodeFound,
//                 )
//               : _simulateScanQrCode(
//                   context,
//                   recipientDidController,
//                   did,
//                 ),
//         ),
//       );
// }
