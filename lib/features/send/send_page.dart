import 'package:dap/dap.dart';
import 'package:didpay/features/dap/dap_form.dart';
import 'package:didpay/features/dap/dap_state.dart';
import 'package:didpay/features/feature_flags/feature_flag.dart';
import 'package:didpay/features/feature_flags/feature_flags_notifier.dart';
import 'package:didpay/features/payment/payment_amount_page.dart';
import 'package:didpay/features/payment/payment_details_state.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/error_message.dart';
import 'package:didpay/shared/header.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SendPage extends HookConsumerWidget {
  const SendPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featureFlags = ref.watch(featureFlagsProvider);

    final dap = useState<AsyncValue<Dap>?>(null);
    final dapText = useState<String?>(null);

    return Scaffold(
      appBar: _buildAppBar(context, featureFlags),
      body: SafeArea(
        child: switch (dap.value) {
          AsyncError(:final error) => ErrorMessage(
              message: error.toString(),
              onRetry: () => dap.value = null,
            ),
          _ => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Header(
                  title: Loc.of(context).whoDoYouWantToPay,
                  subtitle: Loc.of(context).enterADap,
                ),
                Expanded(
                  child: DapForm(
                    buttonTitle: Loc.of(context).next,
                    dapText: dapText,
                    dap: dap,
                    onSubmit: (recipientDap, moneyAddresses) async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PaymentAmountPage(
                            paymentState: PaymentState(
                              transactionType: TransactionType.send,
                              paymentDetailsState: PaymentDetailsState(
                                paymentName: recipientDap.dap,
                              ),
                            ),
                            dapState: DapState(
                              moneyAddresses: moneyAddresses,
                            ),
                          ),
                          fullscreenDialog: true,
                        ),
                      );

                      if (context.mounted) dap.value = null;
                    },
                  ),
                ),
              ],
            ),
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, List<FeatureFlag> featureFlags) =>
      AppBar(
        actions: featureFlags.any(
          (flag) => flag.name == Loc.of(context).lucidMode && flag.isEnabled,
        )
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: Grid.xxs),
                  child: IconButton(
                    icon: const Icon(Icons.deblur, size: Grid.md),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PaymentAmountPage(
                          paymentState: PaymentState(
                            transactionType: TransactionType.send,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]
            : null,
      );
}
