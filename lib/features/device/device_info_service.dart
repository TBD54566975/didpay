import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final deviceInfoServiceProvider = Provider((ref) => DeviceInfoService());

class DeviceInfoService {
  Future<bool> isPhysicalDevice() async {
    final deviceInfo = DeviceInfoPlugin();
    return Platform.isIOS
        ? (await deviceInfo.iosInfo).isPhysicalDevice
        : Platform.isAndroid && (await deviceInfo.androidInfo).isPhysicalDevice;
  }
}
