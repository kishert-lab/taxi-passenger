import 'package:taxi_passenger/core/constants/api_endpoints.dart';
import 'package:taxi_passenger/data/api/api_client.dart';
import 'package:taxi_passenger/domain/models/models.dart';

class PassengerGeoApi {
  PassengerGeoApi(this._apiClient);

  final ApiClient _apiClient;

  Future<List<GeoPoint>> searchAddresses({
    required String query,
    String? cityId,
    double? lat,
    double? lon,
    int limit = 5,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.addressSearch,
      queryParameters: {
        'q': query,
        if (cityId != null && cityId.isNotEmpty) 'city_id': cityId,
        if (lat != null) 'lat': lat,
        if (lon != null) 'lon': lon,
        'limit': limit,
      },
    );

    final data = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : <String, dynamic>{};

    final results = (data['results'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(GeoPoint.fromAddressSearchJson)
        .toList();

    return results;
  }

  Future<List<NearbyCar>> loadNearbyCars({
    required GeoPoint pickup,
    required GeoPoint destination,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.nearbyCars,
      data: {
        'pickup': pickup.toJson(),
        'destination': destination.toJson(),
      },
    );

    final items = (response['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(NearbyCar.fromJson)
        .toList();

    if (items.isNotEmpty) {
      return items;
    }

    return const [
      NearbyCar(
        driverId: 'd1',
        carId: 'c1',
        lat: 56.8392,
        lng: 60.6071,
        distanceMeters: 350,
        etaMinutes: 3,
        carClass: 'Эконом',
      ),
      NearbyCar(
        driverId: 'd2',
        carId: 'c2',
        lat: 56.8379,
        lng: 60.6031,
        distanceMeters: 620,
        etaMinutes: 5,
        carClass: 'Комфорт',
      ),
    ];
  }

  Future<RouteEstimate> loadRouteEstimate({
    required GeoPoint pickup,
    required GeoPoint destination,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.routeEstimate,
      data: {
        'pickup': pickup.toJson(),
        'destination': destination.toJson(),
      },
    );

    if (response.isNotEmpty) {
      return RouteEstimate.fromJson(response);
    }

    return const RouteEstimate(
      price: 420,
      etaMinutes: 6,
      tariffs: [
        Tariff(
          id: 'econom',
          name: 'Эконом',
          description: 'Быстро и доступно',
        ),
        Tariff(
          id: 'comfort',
          name: 'Комфорт',
          description: 'Просторный салон',
        ),
        Tariff(
          id: 'minivan',
          name: 'Минивэн',
          description: 'Для компании и багажа',
        ),
      ],
    );
  }
}
