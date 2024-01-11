import 'package:flutter/material.dart';
import 'package:flutter_starter/features/send/send_page.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(Loc.of(context).home)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          Text(
            'Balance: \$0.00 USD',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton(
                  onPressed: () {}, child: Text(Loc.of(context).deposit)),
              FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const SendPage(),
                    ));
                  },
                  child: Text(Loc.of(context).send)),
              FilledButton(
                  onPressed: () {}, child: Text(Loc.of(context).withdraw)),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
