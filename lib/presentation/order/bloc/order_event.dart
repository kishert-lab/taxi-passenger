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
    required this.carClassId,
    this.paymentType = 'cash',
    this.comment = '',
    this.pickupEntrance = '',
    this.pickupComment = '',
    this.passengerLocationSharingEnabled = true,
  });

  final GeoPoint pickup;
  final GeoPoint destination;
  final String carClassId;
  final String paymentType;
  final String comment;
  final String pickupEntrance;
  final String pickupComment;
  final bool passengerLocationSharingEnabled;

  @override
  List<Object?> get props => [
    pickup,
    destination,
    carClassId,
    paymentType,
    comment,
    pickupEntrance,
    pickupComment,
    passengerLocationSharingEnabled,
  ];
}

class OrderCurrentRequested extends OrderEventAction {
  const OrderCurrentRequested();
}

class OrderCancelRequested extends OrderEventAction {
  const OrderCancelRequested({this.reason = 'Passenger cancelled the order'});

  final String reason;

  @override
  List<Object?> get props => [reason];
}

class OrderHistoryRequested extends OrderEventAction {
  const OrderHistoryRequested();
}

class OrderActiveUpdated extends OrderEventAction {
  const OrderActiveUpdated(this.order);

  final Order? order;

  @override
  List<Object?> get props => [order];
}
