import 'package:taxi_passenger/core/config/passenger_app_config.dart';
import 'package:taxi_passenger/core/constants/api_endpoints.dart';
import 'package:taxi_passenger/core/errors/app_exception.dart';
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

    return ((response as Map<String, dynamic>?)?['results'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(GeoPoint.fromAddressSearchJson)
        .toList();
  }

  Future<List<NearbyCar>> loadNearbyCars({
    required GeoPoint pickup,
    required GeoPoint destination,
  }) async {
    if (PassengerAppConfig.mockEnabled) {
      return const [
        NearbyCar(
          driverId: 'mock-driver-1',
          carId: 'mock-car-1',
          lat: 56.8392,
          lng: 60.6071,
          distanceMeters: 350,
          etaMinutes: 3,
          carClass: 'Эконом',
        ),
      ];
    }

    return const [];
  }

  Future<RouteEstimate> loadRouteEstimate({
    required String cityId,
    required String tariffId,
    required GeoPoint pickup,
    required GeoPoint destination,
  }) async {
    if (cityId.isEmpty) {
      throw AppException('Backend требует city_id для расчета стоимости');
    }
    if (tariffId.isEmpty) {
      throw AppException(
        'Не настроен tariff_id. Передайте PASSENGER_DEFAULT_TARIFF_ID или добавьте источник тарифов.',
      );
    }

    final response = await _apiClient.post(
      ApiEndpoints.routeEstimate,
      data: OrderEstimateRequest(
        cityId: cityId,
        tariffId: tariffId,
        pickupLocation: pickup,
        destinationLocation: destination,
      ).toJson(),
    );

    return RouteEstimate.fromJson(
      response as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }
}
