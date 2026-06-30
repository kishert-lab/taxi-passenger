import 'package:taxi_passenger/core/auth/auth_tokens.dart';
import 'package:taxi_passenger/core/storage/token_storage.dart';
import 'package:taxi_passenger/data/api/passenger_auth_api.dart';

class AuthRepository {
  AuthRepository({
    required PassengerAuthApi authApi,
    required TokenStorage tokenStorage,
  })  : _authApi = authApi,
        _tokenStorage = tokenStorage;

  final PassengerAuthApi _authApi;
  final TokenStorage _tokenStorage;

  Future<bool> hasSession() {
    return ensureAuthorizedSession();
  }

  Future<void> requestCode(String phone) {
    return _authApi.requestCode(phone);
  }

  Future<void> confirmCode({
    required String phone,
    required String code,
  }) async {
    final tokens = await _authApi.confirmCode(phone: phone, code: code);
    if (tokens.accessToken.isEmpty || tokens.refreshToken.isEmpty) {
      throw Exception('Пустой access/refresh token в ответе авторизации');
    }

    await _tokenStorage.saveTokens(tokens);
  }

  Future<bool> ensureAuthorizedSession() async {
    if (await _tokenStorage.hasValidAccessToken()) {
      return true;
    }

    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      await refreshTokens();
      return true;
    } catch (_) {
      await _tokenStorage.clear();
      return false;
    }
  }

  Future<AuthTokens> refreshTokens() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Отсутствует refresh token');
    }

    final tokens = await _authApi.refreshTokens(refreshToken);
    await _tokenStorage.saveTokens(tokens);
    return tokens;
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    await _authApi.logout(refreshToken: refreshToken);
    await _tokenStorage.clear();
  }

  Future<void> clearSession() {
    return _tokenStorage.clear();
  }

  Future<String?> getToken() {
    return _tokenStorage.getAccessToken();
  }
}
