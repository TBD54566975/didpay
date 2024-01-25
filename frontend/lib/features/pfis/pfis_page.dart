import 'package:flutter/material.dart';
import 'package:flutter_starter/features/pfis/pfi_providers.dart';
import 'package:flutter_starter/features/pfis/pfi_verification_page.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_starter/features/pfis/pfi.dart';

class PfisPage extends HookConsumerWidget {
  const PfisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider and get the AsyncValue object
    AsyncValue<List<Pfi>> pfisAsyncValue = ref.watch(pfisProvider);

    return Scaffold(
      appBar: AppBar(title: Text(Loc.of(context).selectYourRegion)),
      body: pfisAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (pfis) {
          // Build the list when data is available
          return ListView(
            children: pfis.map(
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
            ).toList(),
          );
        },
      ),
    );
  }
}
