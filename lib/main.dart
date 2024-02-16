import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/app/app.dart';
import 'package:didpay/services/service_providers.dart';
import 'package:didpay/shared/constants.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web5_flutter/web5_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  FlutterSecureStorage storage = const FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final keyManager = SecureStorageKeyManager(storage: storage);
  final did = await getOrCreateDid(keyManager, storage);
  final vc = await storage.read(key: Constants.verifiableCredentialKey);

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      secureStorageProvider.overrideWithValue(storage),
      didProvider.overrideWithValue(did),
    ],
    child: App(onboarding: vc == null),
  ));
}

Future<Did> getOrCreateDid(
  KeyManager keyManager,
  FlutterSecureStorage storage,
) async {
  final didUri = await storage.read(key: Constants.didUriKey);
  if (didUri != null) {
    return DidJwk(uri: didUri, keyManager: keyManager);
  }

  final did = await DidJwk.create(keyManager: keyManager);
  await storage.write(key: Constants.didUriKey, value: did.uri);
  return did;
}
