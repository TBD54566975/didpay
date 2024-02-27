import 'package:didpay/features/pfis/pfi_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CountryPage extends HookWidget {
  const CountryPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: _buildList(context, country),
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

  Widget _buildList(BuildContext context, ValueNotifier<String?> country) {
    return ListView(
      children: ['United States', 'Mexico', 'Kenya']
          .map(
            (c) => ListTile(
              title: Text(
                c,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              trailing: (country.value == c)
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () {
                country.value = c;
              },
            ),
          )
          .toList(),
    );
  }
}
