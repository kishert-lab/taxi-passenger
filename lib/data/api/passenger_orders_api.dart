import 'package:taxi_passenger/core/constants/api_endpoints.dart';
import 'package:taxi_passenger/data/api/api_client.dart';
import 'package:taxi_passenger/domain/models/models.dart';

class PassengerOrdersApi {
  PassengerOrdersApi(this._apiClient);

  final ApiClient _apiClient;

  Future<Order> createOrder({
    required GeoPoint pickup,
    required GeoPoint destination,
    required String tariffId,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.orders,
      data: {
        'pickup': pickup.toJson(),
        'destination': destination.toJson(),
        'tariffId': tariffId,
      },
    );

    if (response.isNotEmpty) {
      return Order.fromJson(response);
    }

    return Order(
      id: 'demo-order',
      status: OrderStatus.searching,
      pickup: pickup,
      destination: destination,
      tariffId: tariffId,
      price: 420,
      driver: null,
      car: null,
      createdAt: DateTime.now(),
      paymentMethod: 'Наличные',
      etaMinutes: 6,
      distanceMeters: 900,
    );
  }

  Future<void> cancelOrder(String orderId) async {
    await _apiClient.post('${ApiEndpoints.orders}/$orderId/cancel');
  }

  Future<List<Order>> loadOrders() async {
    final response = await _apiClient.get(ApiEndpoints.orderHistory);
    final items = (response['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Order.fromJson)
        .toList();

    if (items.isNotEmpty) {
      return items;
    }

    return [
      Order(
        id: 'hist-1',
        status: OrderStatus.completed,
        pickup: const GeoPoint(
          lat: 56.84,
          lng: 60.60,
          address: 'ул. Ленина, 1',
        ),
        destination: const GeoPoint(
          lat: 56.85,
          lng: 60.61,
          address: 'ул. Малышева, 20',
        ),
        tariffId: 'comfort',
        price: 560,
        driver: const Driver(
          id: 'driver-1',
          name: 'Алексей',
          phone: '+79990000000',
          rating: 4.9,
          avatar: '',
        ),
        car: const Car(
          id: 'car-1',
          brand: 'Toyota',
          model: 'Camry',
          color: 'Белый',
          plateNumber: 'А123АА 96',
          className: 'Комфорт',
        ),
        createdAt: DateTime(2026, 6, 20),
        paymentMethod: 'Карта',
        etaMinutes: 0,
        distanceMeters: 0,
      ),
    ];
  }
}
