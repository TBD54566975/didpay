import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/header.dart';
import 'package:didpay/shared/next_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ErrorMessage extends HookConsumerWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorMessage({
    required this.message,
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
            Header(title: Loc.of(context).errorFound, subtitle: message),
            Expanded(child: Container()),
            NextButton(onPressed: onRetry, title: Loc.of(context).tapToRetry),
          ],
        ),
      );
}
