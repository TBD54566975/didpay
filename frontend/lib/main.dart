import 'dart:convert';
import 'dart:typed_data';

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

Future<DidJwk> getOrCreateDid(FlutterSecureStorage storage) async {
  const didUriKey = 'did';
  final didUri = await storage.read(key: didUriKey);
  final km = SecureStorageKeyManager(storage: storage);
  final DidJwk did;

  if (didUri != null) {
    did = DidJwk(uri: didUri, keyManager: km);
  } else {
    did = await DidJwk.create(keyManager: km);
    await storage.write(key: didUriKey, value: did.uri);
  }

  return did;
}

class SecureStorageKeyManager implements KeyManager {
  final supportedAlgorithms = {
    DsaName.ed25519: Ed25519(),
    DsaName.secp256k1: Secp256k1(),
  };

  final FlutterSecureStorage storage;
  final InMemoryKeyManager inMemoryKeyManager = InMemoryKeyManager();

  SecureStorageKeyManager({required this.storage});

  @override
  Future<String> generatePrivateKey(DsaName alg) async {
    final keyId = await inMemoryKeyManager.generatePrivateKey(alg);
    final privateKeyJwk = inMemoryKeyManager.keyStore[keyId]!;

    storage.write(key: keyId, value: privateKeyJwk.toString());

    return keyId;
  }

  @override
  Future<Jwk> getPublicKey(String keyAlias) async {
    final privateKeyJwkStr = await storage.read(key: keyAlias);

    if (privateKeyJwkStr == null) {
      throw Exception('No key found with alias $keyAlias');
    }

    final privateKeyJwk = Jwk.fromJson(json.decode(privateKeyJwkStr));
    final dsaAlias =
        DsaAlias(algorithm: privateKeyJwk.alg, curve: privateKeyJwk.crv);

    final dsaName = DsaName.findByAlias(dsaAlias);
    final dsa = supportedAlgorithms[dsaName]!;

    return dsa.computePublicKey(privateKeyJwk);
  }

  @override
  Future<Uint8List> sign(String keyAlias, Uint8List payload) async {
    final privateKeyJwkStr = await storage.read(key: keyAlias);

    if (privateKeyJwkStr == null) {
      throw Exception('No key found with alias $keyAlias');
    }

    final privateKeyJwk = Jwk.fromJson(json.decode(privateKeyJwkStr));
    final dsaAlias =
        DsaAlias(algorithm: privateKeyJwk.alg, curve: privateKeyJwk.crv);

    final dsaName = DsaName.findByAlias(dsaAlias);
    final dsa = supportedAlgorithms[dsaName]!;

    return dsa.sign(privateKeyJwk, payload);
  }
}
