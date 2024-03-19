import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  Future<bool> isPhysicalDevice() async {
    final deviceInfo = DeviceInfoPlugin();
    return Platform.isIOS
        ? (await deviceInfo.iosInfo).isPhysicalDevice
        : Platform.isAndroid && (await deviceInfo.androidInfo).isPhysicalDevice;
  }
}
