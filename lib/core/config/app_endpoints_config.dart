class AppEndpointsConfig {
  const AppEndpointsConfig._();

  static const String httpBaseUrl = String.fromEnvironment(
    'PASSENGER_HTTP_BASE_URL',
    defaultValue: 'http://192.168.0.50:8080',
  );

  static const String wsBaseUrl = String.fromEnvironment(
    'PASSENGER_WS_BASE_URL',
    defaultValue: 'ws://192.168.0.50:8080',
  );
}
