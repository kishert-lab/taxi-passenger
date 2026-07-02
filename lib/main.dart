import 'package:flutter/material.dart';
import 'package:taxi_passenger/app.dart';
import 'package:taxi_passenger/core/app_dependencies.dart';
import 'package:taxi_passenger/core/config/firebase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dependencies = AppDependencies.create();
  dependencies.backendAvailabilityService.startMonitoring();
  if (FirebaseConfig.pushEnabled) {
    await dependencies.pushNotificationService.initialize();
  }

  runApp(PassengerApp(dependencies: dependencies));
}
