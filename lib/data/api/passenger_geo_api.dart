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

    final results =
        (response as Map<String, dynamic>?)?['results'] as List<dynamic>? ??
        const [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(GeoPoint.fromAddressSearchJson)
        .toList();
  }

  Future<List<NearbyCar>> loadNearbyCars({
    required GeoPoint pickup,
    required GeoPoint destination,
  }) async {
    return const [];
  }

  Future<RouteEstimate> loadRouteEstimate({
    required String carClassId,
    required GeoPoint pickup,
    required GeoPoint destination,
  }) async {
    if (carClassId.isEmpty) {
      throw AppException('Select a car class before requesting estimate');
    }

    final response = await _apiClient.post(
      ApiEndpoints.routeEstimate,
      data: OrderEstimateRequest(
        pickupLocation: pickup,
        destinationLocation: destination,
        carClassId: carClassId,
      ).toJson(),
    );

    if (response is! Map<String, dynamic> || response.isEmpty) {
      throw AppException('Backend returned empty route estimate response');
    }

    return RouteEstimate.fromJson(response);
  }
}
