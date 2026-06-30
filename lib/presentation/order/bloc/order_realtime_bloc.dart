import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:taxi_passenger/data/services/passenger_websocket_service.dart';
import 'package:taxi_passenger/domain/models/models.dart';

part 'order_realtime_event.dart';
part 'order_realtime_state.dart';

class OrderRealtimeBloc extends Bloc<OrderRealtimeEvent, OrderRealtimeState> {
  OrderRealtimeBloc({required PassengerWebSocketService webSocketService})
      : _webSocketService = webSocketService,
        super(const OrderRealtimeState()) {
    on<OrderRealtimeConnectRequested>(_onConnectRequested);
    on<OrderRealtimeDisconnectRequested>(_onDisconnectRequested);
    on<OrderRealtimeEventReceived>(_onEventReceived);
  }

  final PassengerWebSocketService _webSocketService;
  StreamSubscription<OrderEvent>? _subscription;

  Future<void> _onConnectRequested(
    OrderRealtimeConnectRequested event,
    Emitter<OrderRealtimeState> emit,
  ) async {
    emit(state.copyWith(isConnected: false));
    await _webSocketService.connect();
    await _subscription?.cancel();
    _subscription = _webSocketService.stream.listen(
      (event) => add(OrderRealtimeEventReceived(event)),
    );
    emit(state.copyWith(isConnected: true));
  }

  Future<void> _onDisconnectRequested(
    OrderRealtimeDisconnectRequested event,
    Emitter<OrderRealtimeState> emit,
  ) async {
    await _subscription?.cancel();
    await _webSocketService.disconnect();
    emit(const OrderRealtimeState());
  }

  Future<void> _onEventReceived(
    OrderRealtimeEventReceived event,
    Emitter<OrderRealtimeState> emit,
  ) async {
    emit(
      state.copyWith(
        lastEvent: event.event,
        lastOrderStatus: event.event.order.status,
        driverLocation: event.event.driverLocation,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await _webSocketService.disconnect();
    return super.close();
  }
}
