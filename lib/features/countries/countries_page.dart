import 'package:didpay/features/countries/countries.dart';
import 'package:didpay/features/countries/countries_notifier.dart';
import 'package:didpay/features/payment/payment_amount_page.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/header.dart';
import 'package:didpay/shared/next_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CountriesPage extends HookConsumerWidget {
  const CountriesPage({super.key});

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
            Header(
              title: Loc.of(context).sendMoneyAbroad,
              subtitle: Loc.of(context).selectCountryToGetStarted,
            ),
            Expanded(
              child: _buildCountryList(context, ref, countries, country),
            ),
            NextButton(
              onPressed: country.value == null
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PaymentAmountPage(
                            paymentState: PaymentState(
                              transactionType: TransactionType.send,
                            ),
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

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
}
