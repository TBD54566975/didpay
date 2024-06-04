import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/header.dart';
import 'package:didpay/shared/theme/grid.dart';
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
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Grid.side),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Header(title: Loc.of(context).errorFound, subtitle: text),
              Expanded(child: Container()),
              FilledButton(
                onPressed: onRetry,
                child: Text(Loc.of(context).tapToRetry),
              ),
            ],
          ),
        ),
      );
}
