import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter_starter/features/account/account_providers.dart';
import 'package:flutter_starter/services/service_providers.dart';
import 'package:flutter_starter/shared/constants.dart';
import 'package:flutter_starter/shared/theme/grid.dart';
import 'package:flutter_starter/shared/success_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
        child: vcJwt == null
            ? verifying(context)
            : SuccessPage(
                text: Loc.of(context).verificationComplete,
              ),
      ),
    );
  }

  Widget verifying(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: Grid.lg),
        Text(
          'Verifying your credentials...',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Grid.lg),
        const Center(child: CircularProgressIndicator())
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
        '${pfiService.serviceEndpoint}/credential?transactionId=$transactionId');
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
