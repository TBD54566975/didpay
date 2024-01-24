import 'package:flutter/material.dart';
import 'package:flutter_starter/features/home/account_balance.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(Loc.of(context).home)),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AccountBalance(),
        ],
      ),
    );
  }
}
