import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:taxi_passenger/data/repositories/order_repository.dart';
import 'package:taxi_passenger/data/services/passenger_websocket_service.dart';
import 'package:taxi_passenger/domain/models/models.dart';

part 'order_realtime_event.dart';
part 'order_realtime_state.dart';

class OrderRealtimeBloc extends Bloc<OrderRealtimeEvent, OrderRealtimeState> {
  OrderRealtimeBloc({
    required PassengerWebSocketService webSocketService,
    required OrderRepository orderRepository,
  })  : _webSocketService = webSocketService,
        _orderRepository = orderRepository,
        super(const OrderRealtimeState()) {
    on<OrderRealtimeConnectRequested>(_onConnectRequested);
    on<OrderRealtimeDisconnectRequested>(_onDisconnectRequested);
    on<OrderRealtimeEventReceived>(_onEventReceived);
  }

  final PassengerWebSocketService _webSocketService;
  final OrderRepository _orderRepository;
  StreamSubscription<OrderEvent>? _subscription;

  Future<void> _onConnectRequested(
    OrderRealtimeConnectRequested event,
    Emitter<OrderRealtimeState> emit,
  ) async {
    await _subscription?.cancel();
    await _webSocketService.connect();
    _subscription = _webSocketService.stream.listen(
      (message) => add(OrderRealtimeEventReceived(message)),
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
    var resolvedEvent = event.event;
    Order? resolvedOrder = state.activeOrder;

    if (resolvedEvent.affectsOrderState) {
      try {
        resolvedOrder = await _orderRepository.loadCurrentOrder();
      } catch (_) {}

      if (resolvedOrder == null &&
          state.activeOrder != null &&
          resolvedEvent.orderStatus != null) {
        resolvedOrder = state.activeOrder!.copyWith(status: resolvedEvent.orderStatus);
      }

      resolvedEvent = resolvedEvent.copyWith(order: resolvedOrder);
    }

    emit(
      state.copyWith(
        lastEvent: resolvedEvent,
        activeOrder: resolvedOrder,
        resetActiveOrder: resolvedEvent.isSyncRequired && resolvedOrder == null,
        lastOrderStatus: resolvedOrder?.status ?? resolvedEvent.orderStatus,
        driverLocation: resolvedEvent.driverLocation ?? state.driverLocation,
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
