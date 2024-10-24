import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hooks_riverpod/hooks_riverpod.dart';

final deviceInfoServiceProvider = Provider((ref) => DeviceInfoService());

class DeviceInfoService {
  final _deviceInfo = DeviceInfoPlugin();

  Future<bool> isPhysicalDevice() async {
    if (kIsWeb) {
      return false;
    }
    if (Platform.isIOS) {
      return (await _deviceInfo.iosInfo).isPhysicalDevice;
    }
    if (Platform.isAndroid) {
      return (await _deviceInfo.androidInfo).isPhysicalDevice;
    }

    return false;
  }
}
