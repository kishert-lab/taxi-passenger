import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:taxi_passenger/data/repositories/auth_repository.dart';
import 'package:taxi_passenger/data/repositories/push_repository.dart';

class PassengerPushNotificationService {
  PassengerPushNotificationService({
    required PushRepository pushRepository,
    required AuthRepository authRepository,
  })  : _pushRepository = pushRepository,
        _authRepository = authRepository;

  final PushRepository _pushRepository;
  final AuthRepository _authRepository;
  final StreamController<RemoteMessage> _foregroundMessages =
      StreamController<RemoteMessage>.broadcast();
  FirebaseMessaging? _messaging;
  bool _isInitialized = false;

  Stream<RemoteMessage> get foregroundMessages => _foregroundMessages.stream;

  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _messaging = FirebaseMessaging.instance;
      await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen(_foregroundMessages.add);
      FirebaseMessaging.onMessageOpenedApp.listen((_) {});
      FirebaseMessaging.onBackgroundMessage(passengerFirebaseBackgroundHandler);

      final token = await _messaging!.getToken();
      if (token != null) {
        await _safeSyncToken(token);
      }

      _messaging!.onTokenRefresh.listen((token) async {
        await _safeSyncToken(token);
      });
      _isInitialized = true;
    } catch (error, stackTrace) {
      debugPrint('Firebase push initialization skipped: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> syncToken() async {
    if (!_isInitialized || _messaging == null) {
      return;
    }

    final token = await _messaging!.getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    await _safeSyncToken(token);
  }

  Future<void> _safeSyncToken(String token) async {
    try {
      await _syncTokenIfAuthorized(token);
    } catch (error, stackTrace) {
      debugPrint('Push token sync skipped: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _syncTokenIfAuthorized(String token) async {
    final isAuthorized = await _authRepository.ensureAuthorizedSession();
    if (!isAuthorized) {
      return;
    }

    await _pushRepository.registerPushToken(token);
  }

  Future<void> dispose() async {
    await _foregroundMessages.close();
  }
}

@pragma('vm:entry-point')
Future<void> passengerFirebaseBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
}
