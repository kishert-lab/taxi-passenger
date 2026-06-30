class PassengerAppConfig {
  const PassengerAppConfig._();

  static const bool mockEnabled = bool.fromEnvironment(
    'PASSENGER_MOCK_ENABLED',
    defaultValue: false,
  );

  static const String defaultTariffId = String.fromEnvironment(
    'PASSENGER_DEFAULT_TARIFF_ID',
    defaultValue: '',
  );
}
