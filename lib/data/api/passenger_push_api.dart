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
    await _apiClient.post(
      ApiEndpoints.pushToken,
      data: {
        'token': token,
        'platform': platform,
        'device_id': deviceId,
      },
    );
  }
}
