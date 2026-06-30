import 'package:taxi_passenger/data/api/passenger_orders_api.dart';
import 'package:taxi_passenger/domain/models/models.dart';

class OrderRepository {
  OrderRepository({required PassengerOrdersApi ordersApi})
      : _ordersApi = ordersApi;

  final PassengerOrdersApi _ordersApi;

  Future<Order> createOrder({
    required GeoPoint pickup,
    required GeoPoint destination,
    required String tariffId,
  }) {
    return _ordersApi.createOrder(
      pickup: pickup,
      destination: destination,
      tariffId: tariffId,
    );
  }

  Future<void> cancelOrder(String orderId) {
    return _ordersApi.cancelOrder(orderId);
  }

  Future<List<Order>> loadOrders() {
    return _ordersApi.loadOrders();
  }
}
