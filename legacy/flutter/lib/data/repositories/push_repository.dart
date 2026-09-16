import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:taxi_passenger/data/api/passenger_push_api.dart';

class PushRepository {
  PushRepository({required PassengerPushApi pushApi}) : _pushApi = pushApi;

  final PassengerPushApi _pushApi;
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  Future<void> registerPushToken(String token) async {
    final platform = Platform.isIOS ? 'ios' : 'android';
    final deviceId = await _resolveDeviceId();
    return _pushApi.registerPushToken(
      token: token,
      platform: platform,
      deviceId: deviceId,
    );
  }

  Future<String> _resolveDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return androidInfo.id;
      }
      if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.identifierForVendor ?? iosInfo.name;
      }
    } catch (_) {
      return 'unknown-device';
    }

    return 'unknown-device';
  }
}
