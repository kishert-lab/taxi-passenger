import 'package:taxi_passenger/core/config/passenger_app_config.dart';
import 'package:taxi_passenger/core/errors/app_exception.dart';
import 'package:taxi_passenger/core/storage/token_storage.dart';
import 'package:taxi_passenger/data/api/passenger_orders_api.dart';
import 'package:taxi_passenger/domain/models/models.dart';

class OrderRepository {
  OrderRepository({
    required PassengerOrdersApi ordersApi,
    required TokenStorage tokenStorage,
  })  : _ordersApi = ordersApi,
        _tokenStorage = tokenStorage;

  final PassengerOrdersApi _ordersApi;
  final TokenStorage _tokenStorage;

  Future<RouteEstimate> estimateOrder({
    required GeoPoint pickup,
    required GeoPoint destination,
    String? tariffId,
  }) {
    final cityId = destination.cityId ?? pickup.cityId ?? '';
    final resolvedTariffId = tariffId?.isNotEmpty == true
        ? tariffId!
        : PassengerAppConfig.defaultTariffId;

    return _ordersApi.estimateOrder(
      OrderEstimateRequest(
        cityId: cityId,
        tariffId: resolvedTariffId,
        pickupLocation: pickup,
        destinationLocation: destination,
      ),
    );
  }

  Future<Order> createOrder({
    required GeoPoint pickup,
    required GeoPoint destination,
    required String tariffId,
    String paymentType = 'cash',
    String comment = '',
  }) async {
    final passenger = await _tokenStorage.getPassenger();
    final cityId = destination.cityId ?? pickup.cityId ?? '';
    if (cityId.isEmpty) {
      throw AppException('Backend требует city_id для создания заказа');
    }

    return _ordersApi.createOrder(
      CreateOrderRequest(
        cityId: cityId,
        pickupLocation: pickup,
        pickupAddress: pickup.address,
        destinationLocation: destination,
        destinationAddress: destination.address,
        tariffId: tariffId,
        paymentType: paymentType,
        comment: comment,
        passengerPhone: passenger?.phone ?? '',
      ),
    );
  }

  Future<Order?> loadCurrentOrder() {
    return _ordersApi.loadCurrentOrder();
  }

  Future<Order> cancelOrder(
    String orderId, {
    String reason = 'Passenger cancelled the order',
  }) {
    return _ordersApi.cancelOrder(orderId, reason: reason);
  }

  Future<List<Order>> loadOrders() {
    return _ordersApi.loadOrders();
  }
}
