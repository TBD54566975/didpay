import 'package:didpay/features/kcc/kcc_webview_page.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/header.dart';
import 'package:didpay/shared/next_button.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web5/web5.dart';

class KccConsentPage extends HookConsumerWidget {
  final Pfi pfi;
  final PresentationDefinition presentationDefinition;

  const KccConsentPage({
    required this.pfi,
    required this.presentationDefinition,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAgreed = useState(false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop();
            }
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Header(
              title: Loc.of(context).termsOfService,
              subtitle: Loc.of(context).exampleTerms,
            ),
            const Spacer(),
            _buildUserAndPrivacyAgreement(context, hasAgreed),
            NextButton(
              onPressed: !hasAgreed.value
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => KccWebviewPage(
                            pfi: pfi,
                            presentationDefinition: presentationDefinition,
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAndPrivacyAgreement(
    BuildContext context,
    ValueNotifier<bool> hasAgreed,
  ) =>
      Padding(
        padding:
            const EdgeInsets.only(left: 5, right: Grid.side, bottom: Grid.xs),
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
