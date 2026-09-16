import 'package:flutter/foundation.dart';
import 'package:taxi_passenger/core/errors/app_exception.dart';
import 'package:taxi_passenger/core/constants/api_endpoints.dart';
import 'package:taxi_passenger/data/api/api_client.dart';

class PassengerPushApi {
  PassengerPushApi(this._apiClient);

  final ApiClient _apiClient;

  Future<void> registerPushToken({
    required String token,
    required String platform,
    required String deviceId,
  }) async {
    try {
      await _apiClient.post(
        ApiEndpoints.pushToken,
        data: {
          'provider': 'fcm',
          'token': token,
          'platform': platform,
          'device_id': deviceId,
        },
      );
    } on AppException catch (error) {
      if (error.statusCode == 404) {
        if (kDebugMode) {
          debugPrint(
            'Warning: backend does not support ${ApiEndpoints.pushToken}; push token sync skipped.',
          );
        }
        return;
      }

      rethrow;
    }
  }
}
