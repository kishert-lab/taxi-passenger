import 'dart:async';
import 'dart:convert';

import 'package:taxi_passenger/core/constants/api_endpoints.dart';
import 'package:taxi_passenger/core/storage/token_storage.dart';
import 'package:taxi_passenger/domain/models/models.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PassengerWebSocketService {
  PassengerWebSocketService({
    required TokenStorage tokenStorage,
    required String wsBaseUrl,
  })  : _tokenStorage = tokenStorage,
        _wsBaseUrl = wsBaseUrl;

  final TokenStorage _tokenStorage;
  final String _wsBaseUrl;
  WebSocketChannel? _channel;
  final _controller = StreamController<OrderEvent>.broadcast();

  Stream<OrderEvent> get stream => _controller.stream;

  Future<void> connect() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      return;
    }

    final uri = Uri.parse('$_wsBaseUrl${ApiEndpoints.webSocket}?token=$token');

    await disconnect();
    _channel = WebSocketChannel.connect(uri);
    _channel!.stream.listen(
      (dynamic rawMessage) {
        final data = jsonDecode(rawMessage as String) as Map<String, dynamic>;
        _controller.add(OrderEvent.fromJson(data));
      },
      onDone: () {},
      onError: (_) {},
    );
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    _channel?.sink.close();
    _controller.close();
  }
}
