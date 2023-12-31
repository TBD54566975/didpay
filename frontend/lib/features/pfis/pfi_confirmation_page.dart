import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter_starter/features/account/account_providers.dart';
import 'package:flutter_starter/services/service_providers.dart';
import 'package:flutter_starter/shared/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/features/app/app_tabs.dart';
import 'package:flutter_starter/features/pfis/pfi.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web5_flutter/web5_flutter.dart';

class PfiConfirmationPage extends HookConsumerWidget {
  final Pfi pfi;
  final String transactionId;

  const PfiConfirmationPage({
    required this.pfi,
    required this.transactionId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vcJwt = ref.watch(vcProvider);

    useEffect(() {
      verifyCredential(ref);
      return null;
    }, []);

    return Scaffold(
      body: SafeArea(
        child: vcJwt == null ? verifying(context) : verified(context, vcJwt),
      ),
    );
  }

  Widget verifying(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Text(
          'Verifying your credentials...',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        const Center(child: CircularProgressIndicator())
      ],
    );
  }

  Widget verified(BuildContext context, String vcJwt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Your credentials have been verified!',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Icon(Icons.check_circle,
                    size: 80, color: Theme.of(context).colorScheme.primary),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: FilledButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AppTabs()),
                (Route<dynamic> route) => false,
              );
            },
            child: Text(Loc.of(context).done),
          ),
        ),
      ],
    );
  }

  Future<void> verifyCredential(WidgetRef ref) async {
    final result = await DidDht.resolve(pfi.didUri);
    final pfiService =
        result.didDocument?.service?.firstWhereOrNull((e) => e.type == 'PFI');

    if (pfiService == null) {
      // Add real error handling here...
      throw Exception('PFI service endpoint not found');
    }

    var uri = Uri.parse(
        '${pfiService.serviceEndpoint}/credential?transaction_id=$transactionId');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      // Add real error handling here...
      throw Exception('Failed to get credential');
    }

    final jsonResponse = json.decode(response.body);
    ref.read(secureStorageProvider).write(
        key: Constants.verifiableCredentialKey, value: jsonResponse['jwt']);
    ref.read(vcProvider.notifier).state = jsonResponse['jwt'];
  }
}
