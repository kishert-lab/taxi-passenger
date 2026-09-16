class FirebaseConfig {
  const FirebaseConfig._();

  static const bool pushEnabled = bool.fromEnvironment(
    'PASSENGER_PUSH_ENABLED',
    defaultValue: true,
  );
}
