part of 'order_realtime_bloc.dart';

class OrderRealtimeState extends Equatable {
  const OrderRealtimeState({
    this.isConnected = false,
    this.lastEvent,
    this.activeOrder,
    this.lastOrderStatus,
    this.driverLocation,
  });

  final bool isConnected;
  final OrderEvent? lastEvent;
  final Order? activeOrder;
  final OrderStatus? lastOrderStatus;
  final GeoPoint? driverLocation;

  OrderRealtimeState copyWith({
    bool? isConnected,
    OrderEvent? lastEvent,
    Order? activeOrder,
    bool resetActiveOrder = false,
    OrderStatus? lastOrderStatus,
    GeoPoint? driverLocation,
  }) {
    return OrderRealtimeState(
      isConnected: isConnected ?? this.isConnected,
      lastEvent: lastEvent ?? this.lastEvent,
      activeOrder: resetActiveOrder ? null : (activeOrder ?? this.activeOrder),
      lastOrderStatus: lastOrderStatus ?? this.lastOrderStatus,
      driverLocation: driverLocation ?? this.driverLocation,
    );
  }

  @override
  List<Object?> get props => [
        isConnected,
        lastEvent,
        activeOrder,
        lastOrderStatus,
        driverLocation,
      ];
}
