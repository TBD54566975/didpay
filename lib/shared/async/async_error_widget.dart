import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/header.dart';
import 'package:didpay/shared/next_button.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AsyncErrorWidget extends HookConsumerWidget {
  final String text;
  final VoidCallback onRetry;

  const AsyncErrorWidget({
    required this.text,
    required this.onRetry,
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) =>
      Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Header(title: Loc.of(context).errorFound, subtitle: text),
            const Expanded(child: Spacer()),
            NextButton(onPressed: onRetry, title: Loc.of(context).tapToRetry),
          ],
        ),
      );
}
