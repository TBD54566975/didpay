import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/storage/storage_service.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/constants.dart';
import 'package:didpay/shared/pending_page.dart';
import 'package:didpay/shared/success_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:web5/web5.dart';

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

    useEffect(
      () {
        _verifyCredential(ref);
        return null;
      },
      [],
    );

    return Scaffold(
      body: SafeArea(
        child: vcJwt == null
            ? PendingPage(text: Loc.of(context).verifyingYourIdentity)
            : SuccessPage(text: Loc.of(context).verificationComplete),
      ),
    );
  }

  Future<void> _verifyCredential(WidgetRef ref) async {
    final result = await DidResolver.resolve(pfi.didUri);
    final pfiService =
        result.didDocument?.service?.firstWhereOrNull((e) => e.type == 'PFI');

    if (pfiService == null) {
      // TODO(ethan-tbd): Add real error handling here...
      throw Exception('PFI service endpoint not found');
    }

    var uri = Uri.parse(
      '${pfiService.serviceEndpoint}/credential?transactionId=$transactionId',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      // Add real error handling here...
      throw Exception('Failed to get credential');
    }

    final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
    await ref.read(secureStorageProvider).write(
          key: Constants.verifiableCredentialKey,
          value: jsonResponse['jwt'],
        );
    ref.read(vcProvider.notifier).state = jsonResponse['jwt'];
  }
}
