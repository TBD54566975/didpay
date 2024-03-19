import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AccountVCPage extends HookConsumerWidget {
  const AccountVCPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vc = ref.watch(vcProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My VC')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Grid.side),
        child: Center(child: SelectableText(vc ?? '')),
      ),
    );
  }
}
