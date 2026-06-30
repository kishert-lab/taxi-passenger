class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  DateTime get expiresAt => DateTime.now().add(Duration(seconds: expiresIn));

  factory AuthTokens.fromResponse(Map<String, dynamic> response) {
    final data = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : response;

    return AuthTokens(
      accessToken: data['access_token']?.toString() ??
          data['accessToken']?.toString() ??
          '',
      refreshToken: data['refresh_token']?.toString() ??
          data['refreshToken']?.toString() ??
          '',
      tokenType: data['token_type']?.toString() ??
          data['tokenType']?.toString() ??
          'Bearer',
      expiresIn: (data['expires_in'] as num?)?.toInt() ??
          (data['expiresIn'] as num?)?.toInt() ??
          900,
    );
  }
}
