import 'package:flutter/material.dart';
import 'package:flutter_starter/features/pfis/pfi_providers.dart';
import 'package:flutter_starter/features/pfis/pfi_verification_page.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PfisPage extends HookConsumerWidget {
  const PfisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pfis = ref.watch(pfisProvider);
    return Scaffold(
      appBar: AppBar(title: Text(Loc.of(context).selectYourRegion)),
      body: ListView(
        children: [
          ...pfis.map(
            (pfi) => ListTile(
              title: Text(pfi.name),
              subtitle: Text(pfi.didUri),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PfiVerificationPage(pfi: pfi),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
