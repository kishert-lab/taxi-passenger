import 'package:taxi_passenger/core/auth/auth_tokens.dart';
import 'package:taxi_passenger/core/constants/api_endpoints.dart';
import 'package:taxi_passenger/data/api/api_client.dart';

class PassengerAuthApi {
  PassengerAuthApi(this._apiClient);

  final ApiClient _apiClient;

  Future<void> requestCode(String phone) async {
    await _apiClient.post(
      ApiEndpoints.requestCode,
      data: {'phone': phone},
      requiresAuthorization: false,
      skipAuthRefresh: true,
    );
  }

  Future<PassengerAuthSession> confirmCode({
    required String phone,
    required String code,
    String? name,
  }) async {
    final response = await _apiClient.postRaw(
      ApiEndpoints.confirmCode,
      data: {
        'phone': phone,
        'code': code,
        if (name != null && name.isNotEmpty) 'name': name,
      },
      requiresAuthorization: false,
      skipAuthRefresh: true,
    );

    return PassengerAuthSession.fromResponse(response);
  }

  Future<AuthTokens> refreshTokens(String refreshToken) async {
    final response = await _apiClient.postRaw(
      ApiEndpoints.refresh,
      data: {'refresh_token': refreshToken},
      requiresAuthorization: false,
      skipAuthRefresh: true,
    );

    return AuthTokens.fromResponse(response);
  }

  Future<void> logout({required String refreshToken}) async {
    // Passenger app uses a dedicated auth namespace, so logout must stay on
    // the passenger endpoint alongside request-code/confirm-code/refresh.
    await _apiClient.post(
      ApiEndpoints.logout,
      data: {'refresh_token': refreshToken},
      skipAuthRefresh: true,
    );
  }
}
