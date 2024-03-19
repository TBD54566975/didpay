import 'package:didpay/config/config.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfi_verification_page.dart';
import 'package:didpay/features/wallets/wallet_selection_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AgreementPage extends HookWidget {
  final Pfi pfi;

  const AgreementPage({required this.pfi, super.key});

  @override
  Widget build(BuildContext context) {
    final hasAgreed = useState(false);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(
              context,
              Loc.of(context).termsOfService,
              Loc.of(context).exampleTerms,
            ),
            Expanded(child: Container()),
            _buildUserAndPrivacyAgreement(context, hasAgreed),
            const SizedBox(height: Grid.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Grid.side),
              child: FilledButton(
                onPressed: !hasAgreed.value
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => Config.hasWalletPicker
                                ? WalletSelectionPage(pfi: pfi)
                                : PfiVerificationPage(pfi: pfi),
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

  Widget _buildUserAndPrivacyAgreement(
    BuildContext context,
    ValueNotifier<bool> hasAgreed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: Grid.side),
      child: GestureDetector(
        onTapUp: (_) => hasAgreed.value = !hasAgreed.value,
        child: Row(
          children: [
            Checkbox(
              value: hasAgreed.value,
              onChanged: (newValue) => hasAgreed.value = newValue ?? false,
            ),
            const SizedBox(
              width: Grid.xxs,
            ),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodySmall,
                  children: <TextSpan>[
                    TextSpan(text: Loc.of(context).iCertifyThatIAgreeToThe),
                    TextSpan(
                      text: Loc.of(context).userAgreement,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      recognizer: TapGestureRecognizer(),
                    ),
                    TextSpan(text: Loc.of(context).andIHaveReadThe),
                    TextSpan(
                      text: Loc.of(context).privacyPolicy,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      recognizer: TapGestureRecognizer(),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
