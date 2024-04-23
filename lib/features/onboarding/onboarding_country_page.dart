import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/app/app_tabs.dart';
import 'package:didpay/features/countries/countries_notifier.dart';
import 'package:didpay/features/countries/country.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class OnboardingCountryPage extends HookConsumerWidget {
  const OnboardingCountryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(
      () {
        Future.delayed(
          Duration.zero,
          () => ref.read(countriesProvider.notifier).reload(),
        );
        return null;
      },
      [],
    );

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(
              context,
              Loc.of(context).whereAreYouLocated,
              Loc.of(context).selectYourCountry,
            ),
            Expanded(
              child: _buildCountryList(context, ref),
            ),
            _buildNextButton(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, String subtitle) =>
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Grid.side,
          vertical: Grid.xs,
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: Grid.xs),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );

  Widget _buildCountryList(
    BuildContext context,
    WidgetRef ref,
  ) =>
      ref.watch(countriesProvider).when(
            data: (countries) {
              final selectedCountry = ref.watch(countryProvider);

              return ListView.builder(
                itemCount: countries.length,
                itemBuilder: (context, index) {
                  final country = countries[index];
                  final isSelected = selectedCountry?.code == country.code;

                  return Country.buildCountryTile(
                    context,
                    country,
                    isSelected: isSelected,
                    onTap: () =>
                        ref.read(countryProvider.notifier).state = country,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text(error.toString())),
          );

  Widget _buildNextButton(
    BuildContext context,
    WidgetRef ref,
  ) {
    final country = ref.watch(countryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Grid.side),
      child: FilledButton(
        onPressed: country == null
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AppTabs(),
                  ),
                );
              },
        child: Text(Loc.of(context).next),
      ),
    );
  }
}
