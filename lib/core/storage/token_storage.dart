import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taxi_passenger/core/auth/auth_tokens.dart';
import 'package:taxi_passenger/domain/models/models.dart';

class TokenStorage {
  TokenStorage([FlutterSecureStorage? secureStorage])
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'passenger_access_token';
  static const _refreshTokenKey = 'passenger_refresh_token';
  static const _accessTokenExpiresAtKey = 'passenger_access_token_expires_at';
  static const _passengerIdKey = 'passenger_id';
  static const _passengerPhoneKey = 'passenger_phone';
  static const _passengerNameKey = 'passenger_name';
  static const _passengerEmailKey = 'passenger_email';
  static const _passengerAvatarUrlKey = 'passenger_avatar_url';

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

  Future<void> savePassenger(Passenger passenger) async {
    await _secureStorage.write(key: _passengerIdKey, value: passenger.id);
    await _secureStorage.write(key: _passengerPhoneKey, value: passenger.phone);
    await _secureStorage.write(key: _passengerNameKey, value: passenger.name);
    await _secureStorage.write(key: _passengerEmailKey, value: passenger.email);
    await _secureStorage.write(
      key: _passengerAvatarUrlKey,
      value: passenger.avatarUrl,
    );
  }

  Future<Passenger?> getPassenger() async {
    final id = await _secureStorage.read(key: _passengerIdKey);
    final phone = await _secureStorage.read(key: _passengerPhoneKey);
    if (id == null || id.isEmpty || phone == null || phone.isEmpty) {
      return null;
    }

    return Passenger(
      id: id,
      phone: phone,
      name: await _secureStorage.read(key: _passengerNameKey) ?? '',
      email: await _secureStorage.read(key: _passengerEmailKey) ?? '',
      avatarUrl: await _secureStorage.read(key: _passengerAvatarUrlKey) ?? '',
    );
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
    await _secureStorage.delete(key: _passengerIdKey);
    await _secureStorage.delete(key: _passengerPhoneKey);
    await _secureStorage.delete(key: _passengerNameKey);
    await _secureStorage.delete(key: _passengerEmailKey);
    await _secureStorage.delete(key: _passengerAvatarUrlKey);
  }
}
