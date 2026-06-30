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

  Future<AuthTokens> confirmCode({
    required String phone,
    required String code,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.confirmCode,
      data: {
        'phone': phone,
        'code': code,
      },
      requiresAuthorization: false,
      skipAuthRefresh: true,
    );
    return AuthTokens.fromResponse(response);
  }

  Future<AuthTokens> refreshTokens(String refreshToken) async {
    final response = await _apiClient.post(
      ApiEndpoints.refresh,
      data: {'refresh_token': refreshToken},
      requiresAuthorization: false,
      skipAuthRefresh: true,
    );
    return AuthTokens.fromResponse(response);
  }

  Future<void> logout({String? refreshToken}) async {
    await _apiClient.post(
      ApiEndpoints.logout,
      data: refreshToken != null && refreshToken.isNotEmpty
          ? {'refresh_token': refreshToken}
          : null,
      skipAuthRefresh: true,
    );
  }
}
