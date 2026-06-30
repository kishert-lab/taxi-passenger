import 'package:flutter/foundation.dart';

class AppMockConfig {
  const AppMockConfig._();

  static const bool enabled =
      kDebugMode &&
      bool.fromEnvironment('PASSENGER_USE_MOCKS', defaultValue: false);
}
