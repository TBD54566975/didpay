import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_starter/features/account/account_providers.dart';
import 'package:flutter_starter/features/app/app.dart';
import 'package:flutter_starter/services/service_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterSecureStorage storage = const FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final did = await getOrCreateDid(storage);

  runApp(ProviderScope(
    overrides: [
      secureStorage.overrideWithValue(storage),
      didProvider.overrideWithValue(did),
    ],
    child: const App(),
  ));
}

Future<String> getOrCreateDid(FlutterSecureStorage storage) async {
  const didKey = 'did';
  final did = await storage.read(key: didKey);
  if (did != null) {
    return did;
  }

  final keyManager = InMemoryKeyManager();
  final jwt = await DidJwk.create(keyManager: keyManager);
  await storage.write(key: didKey, value: jwt.uri);

  return jwt.uri;
}
