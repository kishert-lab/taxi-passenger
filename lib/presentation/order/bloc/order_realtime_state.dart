part of 'order_realtime_bloc.dart';

class OrderRealtimeState extends Equatable {
  const OrderRealtimeState({
    this.isConnected = false,
    this.lastEvent,
    this.lastOrderStatus,
    this.driverLocation,
  });

  final bool isConnected;
  final OrderEvent? lastEvent;
  final OrderStatus? lastOrderStatus;
  final GeoPoint? driverLocation;

  OrderRealtimeState copyWith({
    bool? isConnected,
    OrderEvent? lastEvent,
    OrderStatus? lastOrderStatus,
    GeoPoint? driverLocation,
  }) {
    return OrderRealtimeState(
      isConnected: isConnected ?? this.isConnected,
      lastEvent: lastEvent ?? this.lastEvent,
      lastOrderStatus: lastOrderStatus ?? this.lastOrderStatus,
      driverLocation: driverLocation ?? this.driverLocation,
    );
  }

  @override
  List<Object?> get props => [
        isConnected,
        lastEvent,
        lastOrderStatus,
        driverLocation,
      ];
}
