import 'package:didpay/features/countries/countries_page.dart';
import 'package:didpay/features/dap/dap_form.dart';
import 'package:didpay/features/feature_flags/feature_flag.dart';
import 'package:didpay/features/feature_flags/feature_flags_notifier.dart';
import 'package:didpay/features/feature_flags/lucid/lucid_offerings_page.dart';
import 'package:didpay/features/payment/payment_amount_page.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/header.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SendPage extends HookConsumerWidget {
  const SendPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featureFlags = ref.watch(featureFlagsProvider);

    return Scaffold(
      appBar: _buildAppBar(context, featureFlags),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Header(
              title: Loc.of(context).whoDoYouWantToPay,
              subtitle: Loc.of(context).enterADap,
            ),
            Expanded(
              child: DapForm(
                buttonTitle: Loc.of(context).next,
                onSubmit: (did) => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PaymentAmountPage(
                      paymentState: PaymentState(
                        transactionType: TransactionType.send,
                      ),
                    ),
                    fullscreenDialog: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, List<FeatureFlag> featureFlags) =>
      AppBar(
        leading: featureFlags
                .any((flag) => flag.name == 'Remittance' && flag.isEnabled)
            ? Padding(
                padding: const EdgeInsets.only(left: Grid.xxs),
                child: IconButton(
                  icon: const Icon(Icons.language, size: Grid.lg),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CountriesPage(),
                    ),
                  ),
                ),
              )
            : null,
        actions: featureFlags.any(
          (flag) => flag.name == Loc.of(context).lucidMode && flag.isEnabled,
        )
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: Grid.xxs),
                  child: IconButton(
                    icon: const Icon(Icons.deblur, size: Grid.lg),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LucidOfferingsPage(),
                      ),
                    ),
                  ),
                ),
              ]
            : null,
      );
}
