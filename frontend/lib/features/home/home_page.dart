import 'package:flutter/material.dart';
import 'package:flutter_starter/features/pfis/pfi_providers.dart';
import 'package:flutter_starter/features/pfis/pfi_verification_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web5_flutter/web5_flutter.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pfis = ref.watch(pfisProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        children: [
          ...pfis.map(
            (pfi) => ListTile(
              title: Text(pfi.name),
              subtitle: Text(pfi.didUri),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final result = await DidDht.resolve(pfi.didUri);
                final widgetService = result.didDocument?.service
                    ?.firstWhere((e) => e.type == 'kyc-widget');
                if (widgetService?.serviceEndpoint != null) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PfiVerificationPage(
                        widgetUri: widgetService!.serviceEndpoint,
                      ),
                    ),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
