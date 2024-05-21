import 'package:didpay/features/pfis/add_pfi_page.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfi_modal.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PfisPage extends HookConsumerWidget {
  const PfisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pfis = ref.watch(pfisProvider);

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Grid.side,
              vertical: Grid.xs,
            ),
            child: Text(
              Loc.of(context).myPfis,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: pfis.length + 1,
              itemBuilder: (context, index) => index != pfis.length
                  ? _buildPfiTile(context, ref, pfis[index])
                  : _buildAddPfiTile(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPfiTile(BuildContext context, WidgetRef ref, Pfi pfi) {
    return ListTile(
      title: Text(
        pfi.did,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      leading: Container(
        width: Grid.md,
        height: Grid.md,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(Grid.xxs),
        ),
        child: const Center(
          // TODO(ethan-tbd): replace with PFI icon
          child: Icon(Icons.abc),
        ),
      ),
      onTap: () => PfiModal.show(context, ref, pfi),
    );
  }

  Widget _buildAddPfiTile(BuildContext context) {
    return ListTile(
      title: Text(
        Loc.of(context).addAPfi,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      leading: Container(
        width: Grid.md,
        height: Grid.md,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(Grid.xxs),
        ),
        child: const Center(
          child: Icon(Icons.add),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddPfiPage()),
        );
      },
    );
  }
}
