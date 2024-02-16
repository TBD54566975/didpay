import 'package:didpay/services/device_info_service.dart';
import 'package:didpay/services/idv_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final secureStorageProvider =
    Provider<FlutterSecureStorage>((ref) => throw UnimplementedError());

final sharedPreferencesProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());

final idvServiceProvider = Provider((ref) => IdvService());

final deviceInfoServiceProvider = Provider((ref) => DeviceInfoService());
