import 'dart:convert';

import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/app/app.dart';
import 'package:didpay/features/countries/countries_notifier.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/pfis/pfis_service.dart';
import 'package:didpay/features/vcs/vcs_notifier.dart';
import 'package:didpay/shared/constants.dart';
import 'package:didpay/shared/logger.dart';
import 'package:didpay/shared/storage/storage_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web5/web5.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  logger.d('Initializing app');

  final sharedPreferences = await SharedPreferences.getInstance();
  var secureStorage = const FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  await Hive.initFlutter();

  final did = await getOrCreateDid(secureStorage);
  // final vc = await storage.read(key: Constants.verifiableCredentialKey);

  final overrides = await notifierOverrides();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        secureStorageProvider.overrideWithValue(secureStorage),
        didProvider.overrideWithValue(did),
        ...overrides,
      ],
      child: const App(),
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

  final did = await DidDht.create(publish: true);
  final portableDid = await did.export();
  final portableDidJson = jsonEncode(portableDid.map);

  await storage.write(
    key: Constants.portableDidKey,
    value: portableDidJson,
  );
  return did;
}

Future<List<Override>> notifierOverrides() async {
  final pfisBox = await Hive.openBox(PfisNotifier.storageKey);
  final pfisNofitier = await PfisNotifier.create(pfisBox, PfisService());

  final countriesBox = await Hive.openBox(CountriesNotifier.storageKey);
  final countriesNotifier = await CountriesNotifier.create(countriesBox);

  final vcsBox = await Hive.openBox(VcsNotifier.storageKey);
  final vcsNotifier = await VcsNotifier.create(vcsBox);

  return [
    pfisProvider.overrideWith((ref) => pfisNofitier),
    countriesProvider.overrideWith((ref) => countriesNotifier),
    vcsProvider.overrideWith((ref) => vcsNotifier),
  ];
}
