class PassengerAppConfig {
  const PassengerAppConfig._();

  static const String defaultTariffId = String.fromEnvironment(
    'PASSENGER_DEFAULT_TARIFF_ID',
    defaultValue: '',
  );
}
