import 'package:didpay/features/account/account_page.dart';
import 'package:didpay/features/home/home_page.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/send/send_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _TabItem {
  final String label;
  final Icon icon;
  final Widget screen;

  _TabItem(this.label, this.icon, this.screen);
}

class AppTabs extends HookConsumerWidget {
  const AppTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = useState(0);
    final pfis = ref.read(pfisProvider);

    final tabs = [
      _TabItem(
        'Home',
        const Icon(Icons.home_outlined),
        const HomePage(),
      ),
      _TabItem(
        'Send',
        const Icon(Icons.attach_money),
        const SendPage(),
      ),
      _TabItem(
        'Account',
        const Icon(Icons.person_outlined),
        const AccountPage(),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex.value,
        children: tabs.map((tab) => tab.screen).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Theme.of(context).colorScheme.primary,
        selectedFontSize: 12,
        currentIndex: selectedIndex.value,
        onTap: (index) => _onTabTapped(context, index, selectedIndex, pfis),
        items: tabs
            .map(
              (tab) => BottomNavigationBarItem(
                icon: tab.icon,
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }

  void _onTabTapped(
    BuildContext context,
    int index,
    ValueNotifier<int> selectedIndex,
    List<Pfi> pfis,
  ) {
    if (index == 1 && pfis.isEmpty) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Loc.of(context).mustAddPfiBeforeSending,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
      return;
    }
    selectedIndex.value = index;
  }
}
