import 'package:didpay/features/account/account_did_page.dart';
import 'package:didpay/features/account/account_vc_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';

// TODO(ethan-tbd): redesign AccountPage, https://github.com/TBD54566975/didpay/issues/130
class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _buildAccountNavigation(context),
      ),
    );
  }

  Widget _buildAccountNavigation(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Grid.side,
              vertical: Grid.xs,
            ),
            child: Text(
              Loc.of(context).account,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text(
                    Loc.of(context).myDid,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  leading: const Icon(Icons.text_snippet, size: Grid.md),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AccountDidPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text(
                    Loc.of(context).myVc,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  leading: const Icon(Icons.person, size: Grid.md),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AccountVCPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      );
}
