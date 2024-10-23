import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/feature_flags/feature_flag.dart';
import 'package:didpay/features/feature_flags/feature_flags_notifier.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_add_page.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/qr/qr_tabs.dart';
import 'package:didpay/features/vcs/vcs_notifier.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/modal/modal_manage_item.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/tile_container.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:web5/web5.dart';

class AccountPage extends HookConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pfis = ref.watch(pfisProvider);
    final credentials = ref.watch(vcsProvider);
    final featureFlags = ref.watch(featureFlagsProvider);
    final dap = Loc.of(context).placeholderDap;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfile(context, dap),
            Center(child: Text(dap)),
            const SizedBox(height: Grid.lg),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLinkedPfisList(context, ref, pfis),
                    const SizedBox(height: Grid.lg),
                    _buildIssuedCredentialsList(context, ref, credentials),
                    if (featureFlags.isNotEmpty) ...[
                      const SizedBox(height: Grid.lg),
                      _buildFeatureFlagsList(
                        context,
                        ref,
                        featureFlags
                            .where((flag) => flag == lucidMode)
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, String dap) => Padding(
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
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    width: Grid.quarter,
                  ),
                  color: Theme.of(context).colorScheme.surfaceContainer,
                ),
                child: const Center(child: Icon(Icons.person, size: Grid.xl)),
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
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QrTabs(dap: dap),
                        fullscreenDialog: true,
                      ),
                    ),
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
            itemBuilder: (context, index) => index < pfis.length
                ? TileContainer(child: _buildPfiTile(context, ref, pfis[index]))
                : TileContainer(child: _buildAddPfiTile(context)),
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
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(Grid.xxs),
          ),
          child: const Center(child: Icon(Icons.account_balance)),
        ),
        onTap: () => ModalManageItem.show(
          context,
          pfi.did,
          Loc.of(context).removePfi,
          pfi.did,
          () async => ref.read(pfisProvider.notifier).remove(pfi),
        ),
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
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(Grid.xxs),
          ),
          child: const Center(
            child: Icon(Icons.add),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PfisAddPage()),
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
                        _buildCredentialTile(context, ref, credentials[index]),
                  ),
                ),
        ],
      );

  Widget _buildCredentialTile(
    BuildContext context,
    WidgetRef ref,
    String credential,
  ) =>
      ListTile(
        title: Text(
          _getCredentialTitle(credential),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        leading: Container(
          width: Grid.md,
          height: Grid.md,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(Grid.xxs),
          ),
          child: const Center(child: Icon(Icons.gpp_good)),
        ),
        onTap: () => ModalManageItem.show(
          context,
          _getCredentialTitle(credential),
          Loc.of(context).removeCredential,
          credential,
          () async => ref.read(vcsProvider.notifier).remove(credential),
        ),
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
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(Grid.xxs),
          ),
          child: Center(
            child:
                Icon(Icons.error, color: Theme.of(context).colorScheme.outline),
          ),
        ),
      );

  Widget _buildFeatureFlagsList(
    BuildContext context,
    WidgetRef ref,
    List<FeatureFlag> featureFlags,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Grid.side),
            child: Text(
              Loc.of(context).featureFlags,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: featureFlags.length,
            itemBuilder: (context, index) => TileContainer(
              child: _buildFeatureFlagToggle(context, ref, featureFlags[index]),
            ),
          ),
        ],
      );

  Widget _buildFeatureFlagToggle(
    BuildContext context,
    WidgetRef ref,
    FeatureFlag flag,
  ) =>
      SwitchListTile(
        title: Text(
          flag.name,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: AutoSizeText(
          flag.description,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        value: flag.isEnabled,
        onChanged: (value) async {
          await ref.read(featureFlagsProvider.notifier).toggleFlag(flag);
        },
        activeColor: Theme.of(context).colorScheme.tertiary,
        trackOutlineColor: WidgetStateColor.resolveWith(
          (_) => Colors.transparent,
        ),
      );

  String _getCredentialTitle(String credentialJwt) {
    final decodedJwt = Jwt.decode(credentialJwt);
    final payload = decodedJwt.claims.misc?['vc'] as Map<String, dynamic>?;
    final issuedAt = payload?['issuanceDate'] as String?;
    final issuanceDate = issuedAt != null
        ? DateFormat('MMM dd yyyy').format(DateTime.parse(issuedAt).toLocal())
        : 'no issuance date';

    return 'KCC - $issuanceDate';
  }
}
