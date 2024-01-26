import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/features/deposit/deposit_page.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:flutter_starter/shared/grid.dart';

class AccountBalance extends HookWidget {
  const AccountBalance({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Grid.side),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.outline, width: 2.0),
          borderRadius: BorderRadius.circular(25.0),
        ),
        padding: const EdgeInsets.all(Grid.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Loc.of(context).accountBalance,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: Grid.xxs),
            Center(
              child: Text(
                '\$0.00',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: Grid.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const DepositPage(),
                        ));
                      },
                      child: Text(Loc.of(context).deposit)),
                ),
                const SizedBox(width: Grid.xs),
                Expanded(
                  child: FilledButton(
                      onPressed: () {}, child: Text(Loc.of(context).withdraw)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
