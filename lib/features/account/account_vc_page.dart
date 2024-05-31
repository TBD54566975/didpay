import 'package:didpay/features/vcs/vcs_notifier.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AccountVcPage extends HookConsumerWidget {
  const AccountVcPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vcs = ref.watch(vcsProvider);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Grid.side,
                vertical: Grid.xs,
              ),
              child: Text(
                'My VCs',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: vcs.length,
                itemBuilder: (context, index) =>
                    _buildVcTile(context, ref, vcs[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVcTile(BuildContext context, WidgetRef ref, String vc) {
    return ListTile(
      title: Text(
        vc,
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
    );
  }
}
