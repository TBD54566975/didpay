import 'package:didpay/features/app/app_tabs.dart';
import 'package:didpay/features/pfis/add_pfi_page.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/modal_flow.dart';
import 'package:didpay/shared/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class App extends HookConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pfis = ref.watch(pfisProvider);
    return MaterialApp(
      title: 'DIDPay',
      theme: lightTheme(context),
      darkTheme: darkTheme(context),
      home: pfis.isEmpty ? AddPfiPage() : const AppTabs(),
      localizationsDelegates: Loc.localizationsDelegates,
      supportedLocales: const [
        Locale('en', ''),
      ],
    );
  }
}
