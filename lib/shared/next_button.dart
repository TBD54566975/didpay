import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class NextButton extends HookWidget {
  final void Function()? onPressed;
  final String? title;

  const NextButton({required this.onPressed, this.title, super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(
            left: Grid.side, right: Grid.side, bottom: Grid.xxs,),
        child: FilledButton(
          onPressed: onPressed,
          child: Text(title ?? Loc.of(context).next),
        ),
      );
}
