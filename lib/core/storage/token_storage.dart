import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taxi_passenger/core/auth/auth_tokens.dart';

class TokenStorage {
  TokenStorage([FlutterSecureStorage? secureStorage])
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'passenger_access_token';
  static const _refreshTokenKey = 'passenger_refresh_token';
  static const _accessTokenExpiresAtKey = 'passenger_access_token_expires_at';

  final FlutterSecureStorage _secureStorage;

  Future<void> saveTokens(AuthTokens tokens) async {
    await _secureStorage.write(key: _accessTokenKey, value: tokens.accessToken);
    await _secureStorage.write(
      key: _refreshTokenKey,
      value: tokens.refreshToken,
    );
    await _secureStorage.write(
      key: _accessTokenExpiresAtKey,
      value: tokens.expiresAt.toIso8601String(),
    );
  }

  Future<String?> getAccessToken() {
    return _secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  Future<DateTime?> getAccessTokenExpiresAt() async {
    final value = await _secureStorage.read(key: _accessTokenExpiresAtKey);
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  Future<bool> hasValidAccessToken() async {
    final accessToken = await getAccessToken();
    final expiresAt = await getAccessTokenExpiresAt();
    if (accessToken == null || accessToken.isEmpty || expiresAt == null) {
      return false;
    }

    return expiresAt.isAfter(DateTime.now().add(const Duration(seconds: 30)));
  }

  Future<void> clear() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _accessTokenExpiresAtKey);
  }
}
