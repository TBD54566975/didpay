import 'package:didpay/features/account/account_did_page.dart';
import 'package:didpay/features/account/account_management_modal.dart';
import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/pfis/add_pfi_page.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/vcs/vcs_notifier.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/tile_container.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AccountPage extends HookConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pfis = ref.watch(pfisProvider);
    final credentials = ref.watch(vcsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfile(
              context,
              ref.read(didProvider).uri,
            ),
            const Center(child: Text('username@didpay.me')),
            const SizedBox(height: Grid.lg),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLinkedPfisList(context, ref, pfis),
                    const SizedBox(height: Grid.lg),
                    _buildIssuedCredentialsList(context, ref, credentials),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, String did) => Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Grid.xs,
          horizontal: Grid.side,
        ),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: Grid.profile,
                height: Grid.profile,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: Grid.quarter,
                  ),
                  color: Theme.of(context).colorScheme.background,
                ),
                child: const Center(
                  child: Icon(Icons.person, size: Grid.xl),
                ),
              ),
              Positioned(
                bottom: -Grid.xxs,
                right: -Grid.xxs,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.qr_code, size: Grid.sm),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AccountDidPage(),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildLinkedPfisList(
    BuildContext context,
    WidgetRef ref,
    List<Pfi> pfis,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Grid.side),
            child: Text(
              Loc.of(context).linkedPfis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: pfis.length + 1,
            itemBuilder: (context, index) {
              if (index < pfis.length) {
                return TileContainer(
                  child: _buildPfiTile(context, ref, pfis[index]),
                );
              } else {
                return TileContainer(
                  child: _buildAddPfiTile(context),
                );
              }
            },
          ),
        ],
      );

  Widget _buildPfiTile(BuildContext context, WidgetRef ref, Pfi pfi) =>
      ListTile(
        title: Text(
          pfi.did,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        leading: Container(
          width: Grid.md,
          height: Grid.md,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(Grid.xxs),
          ),
          child: const Center(child: Icon(Icons.attach_money)),
        ),
        onTap: () => AccountManagementModal.show(context, ref, pfi: pfi),
      );

  Widget _buildAddPfiTile(BuildContext context) => ListTile(
        title: Text(
          Loc.of(context).addAPfi,
          style: Theme.of(context).textTheme.titleSmall,
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

  Widget _buildIssuedCredentialsList(
    BuildContext context,
    WidgetRef ref,
    List<String> credentials,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Grid.side),
            child: Text(
              Loc.of(context).issuedCredentials,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          credentials.isEmpty
              ? TileContainer(child: _buildNoCredentialsTile(context))
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: credentials.length,
                  itemBuilder: (context, index) => TileContainer(
                    child:
                        _buildCredentialsTile(context, ref, credentials[index]),
                  ),
                ),
        ],
      );

  Widget _buildCredentialsTile(
    BuildContext context,
    WidgetRef ref,
    String credential,
  ) =>
      ListTile(
        title: Text(
          '${credential.substring(0, 10)}...${credential.substring(credential.length - 20)}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        leading: Container(
          width: Grid.md,
          height: Grid.md,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(Grid.xxs),
          ),
          child: const Center(child: Icon(Icons.gpp_good)),
        ),
        onTap: () =>
            AccountManagementModal.show(context, ref, credential: credential),
      );

  Widget _buildNoCredentialsTile(BuildContext context) => ListTile(
        title: Text(
          Loc.of(context).noCredentialsIssuedYet,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        leading: Container(
          width: Grid.md,
          height: Grid.md,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(Grid.xxs),
          ),
          child: Center(
            child:
                Icon(Icons.error, color: Theme.of(context).colorScheme.outline),
          ),
        ),
      );
}
