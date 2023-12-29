import 'package:flutter/material.dart';
import 'package:flutter_starter/features/pfis/pfi_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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
            (e) => ListTile(
              title: Text(e.name),
              subtitle: Text(e.id),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _launchUrl(e.widgetUrl);
              },
            ),
          )
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}
