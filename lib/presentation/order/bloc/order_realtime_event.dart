part of 'order_realtime_bloc.dart';

sealed class OrderRealtimeEvent extends Equatable {
  const OrderRealtimeEvent();

  @override
  List<Object?> get props => [];
}

class OrderRealtimeConnectRequested extends OrderRealtimeEvent {
  const OrderRealtimeConnectRequested();
}

class OrderRealtimeDisconnectRequested extends OrderRealtimeEvent {
  const OrderRealtimeDisconnectRequested();
}

class OrderRealtimeEventReceived extends OrderRealtimeEvent {
  const OrderRealtimeEventReceived(this.event);

  final OrderEvent event;

  @override
  List<Object?> get props => [event];
}
