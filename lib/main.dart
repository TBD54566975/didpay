import 'dart:convert';

import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/app/app.dart';
import 'package:didpay/features/storage/storage_service.dart';
import 'package:didpay/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web5/web5.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  var storage = const FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final did = await getOrCreateDid(storage);
  final vc = await storage.read(key: Constants.verifiableCredentialKey);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        secureStorageProvider.overrideWithValue(storage),
        didProvider.overrideWithValue(did),
      ],
      child: App(onboarding: vc == null),
    ),
  );
}

Future<BearerDid> getOrCreateDid(FlutterSecureStorage storage) async {
  final existingPortableDidJson =
      await storage.read(key: Constants.portableDidKey);
  if (existingPortableDidJson != null) {
    final portableDidJson = json.decode(existingPortableDidJson);
    final portableDid = PortableDid.fromMap(portableDidJson);
    return BearerDid.import(portableDid);
  }

  final did = await DidJwk.create();
  final portableDid = await did.export();
  final portableDidJson = jsonEncode(portableDid.map);

  await storage.write(
    key: Constants.portableDidKey,
    value: portableDidJson,
  );
  return did;
}
