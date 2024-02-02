import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/features/account/account_page.dart';
import 'package:flutter_starter/features/home/home_page.dart';
import 'package:flutter_starter/features/send/send_page.dart';
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
        onTap: (index) => selectedIndex.value = index,
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
}
