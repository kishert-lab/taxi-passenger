part of 'order_bloc.dart';

sealed class OrderEventAction extends Equatable {
  const OrderEventAction();

  @override
  List<Object?> get props => [];
}

class OrderCreateRequested extends OrderEventAction {
  const OrderCreateRequested({
    required this.pickup,
    required this.destination,
    required this.tariffId,
  });

  final GeoPoint pickup;
  final GeoPoint destination;
  final String tariffId;

  @override
  List<Object?> get props => [pickup, destination, tariffId];
}

class OrderCancelRequested extends OrderEventAction {
  const OrderCancelRequested();
}

class OrderHistoryRequested extends OrderEventAction {
  const OrderHistoryRequested();
}

class OrderActiveUpdated extends OrderEventAction {
  const OrderActiveUpdated(this.order);

  final Order order;

  @override
  List<Object?> get props => [order];
}
