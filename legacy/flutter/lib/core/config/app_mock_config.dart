class AppMockConfig {
  const AppMockConfig._();

  static const bool enabled = bool.fromEnvironment(
    'PASSENGER_USE_MOCKS',
    defaultValue: false,
  );
}
