import 'package:taxi_passenger/data/api/passenger_orders_api.dart';
import 'package:taxi_passenger/domain/models/models.dart';

class OrderRepository {
  OrderRepository({required PassengerOrdersApi ordersApi})
    : _ordersApi = ordersApi;

  final PassengerOrdersApi _ordersApi;

  Future<RouteEstimate> estimateOrder({
    required GeoPoint pickup,
    required GeoPoint destination,
    required String carClassId,
  }) {
    return _ordersApi.estimateOrder(
      OrderEstimateRequest(
        pickupLocation: pickup,
        destinationLocation: destination,
        carClassId: carClassId,
      ),
    );
  }

  Future<Order> createOrder({
    required GeoPoint pickup,
    required GeoPoint destination,
    required String carClassId,
    String paymentType = 'cash',
    String comment = '',
    String pickupEntrance = '',
    String pickupComment = '',
    bool passengerLocationSharingEnabled = true,
  }) async {
    return _ordersApi.createOrder(
      CreateOrderRequest(
        pickupLocation: pickup,
        pickupAddress: pickup.address,
        pickupEntrance: pickupEntrance,
        pickupComment: pickupComment,
        destinationLocation: destination,
        destinationAddress: destination.address,
        carClassId: carClassId,
        paymentType: paymentType,
        comment: comment,
        passengerLocationSharingEnabled: passengerLocationSharingEnabled,
      ),
    );
  }

  Future<Order?> loadCurrentOrder() {
    return _ordersApi.loadCurrentOrder();
  }

  Future<Order> loadOrderDetails(String orderId) {
    return _ordersApi.loadOrderDetails(orderId);
  }

  Future<Order> cancelOrder(
    String orderId, {
    String reason = 'Passenger cancelled the order',
  }) {
    return _ordersApi.cancelOrder(orderId, reason: reason);
  }

  Future<void> rateOrder({
    required String orderId,
    required int rating,
    String? comment,
  }) {
    return _ordersApi.rateOrder(
      orderId: orderId,
      rating: rating,
      comment: comment,
    );
  }

  Future<List<Order>> loadOrders() {
    return _ordersApi.loadOrders();
  }
}
