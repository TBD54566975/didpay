import 'package:didpay/features/account/account_did_page.dart';
import 'package:didpay/features/account/account_vc_page.dart';
import 'package:didpay/features/pfis/pfis_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// TODO(ethan-tbd): redesign AccountPage, https://github.com/TBD54566975/didpay/issues/130
class AccountPage extends HookWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
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
                  Loc.of(context).account,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    _buildMyPfisTile(context),
                    _buildMyDidTile(context),
                    _buildMyVcTile(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildMyPfisTile(BuildContext context) => ListTile(
        title: Text(
          Loc.of(context).myPfis,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        trailing: const Icon(Icons.chevron_right),
        leading: Container(
          width: Grid.md,
          height: Grid.md,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(Grid.xxs),
          ),
          child: const Center(
            child: Icon(Icons.currency_exchange),
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const PfisPage(),
            ),
          );
        },
      );

  Widget _buildMyDidTile(BuildContext context) => ListTile(
        title: Text(
          Loc.of(context).myDid,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        trailing: const Icon(Icons.chevron_right),
        leading: Container(
          width: Grid.md,
          height: Grid.md,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(Grid.xxs),
          ),
          child: const Center(
            child: Icon(Icons.text_snippet),
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AccountDidPage(),
            ),
          );
        },
      );

  Widget _buildMyVcTile(BuildContext context) => ListTile(
        title: Text(
          Loc.of(context).myVc,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        trailing: const Icon(Icons.chevron_right),
        leading: Container(
          width: Grid.md,
          height: Grid.md,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(Grid.xxs),
          ),
          child: const Center(
            child: Icon(Icons.person),
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AccountVcPage(),
            ),
          );
        },
      );
}
