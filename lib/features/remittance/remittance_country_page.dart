import 'package:didpay/features/remittance/countries.dart';
import 'package:didpay/features/remittance/countries_notifier.dart';
import 'package:didpay/features/remittance/remittance_page.dart';
import 'package:didpay/features/tbdex/rfq_state.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RemittanceCountryPage extends HookConsumerWidget {
  const RemittanceCountryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countries = ref.read(countriesProvider);
    final country = useState<Country?>(null);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(
              context,
              Loc.of(context).sendMoneyAbroad,
              Loc.of(context).selectCountryToGetStarted,
            ),
            Expanded(
              child: _buildCountryList(context, ref, countries, country),
            ),
            _buildNextButton(context, country.value),
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
    List<Country> countries,
    ValueNotifier<Country?> selectedCountry,
  ) =>
      ListView.builder(
        itemCount: countries.length,
        itemBuilder: (context, index) {
          final country = countries[index];
          final isSelected = selectedCountry.value?.code == country.code;

          return Country.buildCountryTile(
            context,
            country,
            isSelected: isSelected,
            onTap: () => selectedCountry.value = country,
          );
        },
      );

  Widget _buildNextButton(
    BuildContext context,
    Country? country,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Grid.side),
        child: FilledButton(
          onPressed: country == null
              ? null
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RemittancePage(
                        country: country,
                        rfqState: const RfqState(),
                      ),
                    ),
                  );
                },
          child: Text(Loc.of(context).next),
        ),
      );
}
