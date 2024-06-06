import 'package:didpay/features/app/app.dart';
import 'package:didpay/features/countries/countries_notifier.dart';
import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/did/did_storage_service.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/pfis/pfis_service.dart';
import 'package:didpay/features/vcs/vcs_notifier.dart';
import 'package:didpay/shared/logger.dart';
import 'package:didpay/shared/storage/storage_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  logger.d('Initializing app');

  final sharedPreferences = await SharedPreferences.getInstance();
  var secureStorage = const FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final didService = DidStorageService(secureStorage);
  final did = await didService.getOrCreateDid();

  await Hive.initFlutter();

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

Future<List<Override>> notifierOverrides() async {
  final pfisBox = await Hive.openBox(PfisNotifier.storageKey);
  final pfisNofitier = await PfisNotifier.create(pfisBox, PfisService());

  final countriesBox = await Hive.openBox(CountriesNotifier.storageKey);
  final countriesNotifier = await CountriesNotifier.create(countriesBox);

  if (countriesBox.isEmpty) {
    await countriesNotifier.add('MX', 'Mexico');
  }

  final vcsBox = await Hive.openBox(VcsNotifier.storageKey);
  final vcsNotifier = await VcsNotifier.create(vcsBox);

  return [
    pfisProvider.overrideWith((ref) => pfisNofitier),
    countriesProvider.overrideWith((ref) => countriesNotifier),
    vcsProvider.overrideWith((ref) => vcsNotifier),
  ];
}
