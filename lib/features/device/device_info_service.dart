import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final deviceInfoServiceProvider = Provider((ref) => DeviceInfoService());

class DeviceInfoService {
  final _deviceInfo = DeviceInfoPlugin();

  Future<bool> isPhysicalDevice() async => Platform.isIOS
      ? (await _deviceInfo.iosInfo).isPhysicalDevice
      : Platform.isAndroid && (await _deviceInfo.androidInfo).isPhysicalDevice;
}
