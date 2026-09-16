import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:taxi_passenger/data/api/public_legal_api.dart';

enum BackendAvailabilityStatus { checking, available, unavailable }

class BackendAvailabilityService extends ChangeNotifier {
  BackendAvailabilityService({required PublicLegalApi publicLegalApi})
    : _publicLegalApi = publicLegalApi;

  static const Duration probeInterval = Duration(minutes: 5);

  final PublicLegalApi _publicLegalApi;

  BackendAvailabilityStatus _status = BackendAvailabilityStatus.checking;
  Timer? _timer;
  bool _isChecking = false;
  String? _errorMessage;
  DateTime? _lastCheckedAt;

  BackendAvailabilityStatus get status => _status;
  String? get errorMessage => _errorMessage;
  DateTime? get lastCheckedAt => _lastCheckedAt;
  bool get isUnavailable => _status == BackendAvailabilityStatus.unavailable;

  void startMonitoring() {
    _timer ??= Timer.periodic(probeInterval, (_) {
      unawaited(checkNow());
    });
    unawaited(checkNow());
  }

  Future<void> checkNow() async {
    if (_isChecking) {
      return;
    }

    _isChecking = true;
    if (_status == BackendAvailabilityStatus.checking) {
      notifyListeners();
    }

    try {
      await _publicLegalApi.loadConsent();
      _status = BackendAvailabilityStatus.available;
      _errorMessage = null;
    } catch (error) {
      _status = BackendAvailabilityStatus.unavailable;
      _errorMessage = error.toString();
    } finally {
      _lastCheckedAt = DateTime.now();
      _isChecking = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
