import 'dart:async';

class AuthSessionNotifier {
  final StreamController<void> _sessionExpiredController =
      StreamController<void>.broadcast();

  Stream<void> get sessionExpiredStream => _sessionExpiredController.stream;

  void notifySessionExpired() {
    if (!_sessionExpiredController.isClosed) {
      _sessionExpiredController.add(null);
    }
  }

  Future<void> dispose() async {
    await _sessionExpiredController.close();
  }
}
