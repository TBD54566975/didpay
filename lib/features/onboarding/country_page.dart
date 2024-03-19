import 'package:didpay/features/onboarding/country.dart';
import 'package:didpay/features/pfis/pfi_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CountryPage extends HookConsumerWidget {
  const CountryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countries = ref.read(countryProvider);
    final country = useState<String?>(null);

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
              child: _buildCountryList(context, country, countries),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Grid.side),
              child: FilledButton(
                onPressed: country.value == null
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PfiPage(),
                          ),
                        );
                      },
                child: Text(Loc.of(context).next),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, String subtitle) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: Grid.side, vertical: Grid.xs),
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
  }

  Widget _buildCountryList(
    BuildContext context,
    ValueNotifier<String?> country,
    List<Country> countries,
  ) {
    return ListView(
      children: countries
          .map(
            (c) => ListTile(
              title: Text(
                c.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
              ),
              leading: Container(
                width: Grid.md,
                height: Grid.md,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(Grid.xxs),
                ),
                child: Center(
                  child: _buildFlag(context, c.code),
                ),
              ),
              trailing: (country.value == c.name)
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                country.value = c.name;
              },
            ),
          )
          .toList(),
    );
  }

  Widget _buildFlag(BuildContext context, String countryCode) {
    const asciiOffset = 0x41;
    const flagOffset = 0x1F1E6;

    final firstChar = countryCode.codeUnitAt(0) - asciiOffset + flagOffset;
    final secondChar = countryCode.codeUnitAt(1) - asciiOffset + flagOffset;

    var emoji =
        String.fromCharCode(firstChar) + String.fromCharCode(secondChar);

    return Text(
      emoji,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }
}
