import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final secureStorageProvider =
    Provider<FlutterSecureStorage>((ref) => throw UnimplementedError());

final sharedPreferencesProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());

// TODO(ethan-tbd): implement this, https://github.com/TBD54566975/didpay/issues/137
class StorageService {}
