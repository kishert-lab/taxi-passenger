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

    return ((response as Map<String, dynamic>?)?['results'] as List<dynamic>? ??
            [])
        .whereType<Map<String, dynamic>>()
        .map(GeoPoint.fromAddressSearchJson)
        .toList();
  }

  Future<List<NearbyCar>> loadNearbyCars({
    required GeoPoint pickup,
    required GeoPoint destination,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.nearbyCars,
      data: {
        'pickup_location': pickup.toLocationJson(),
        'destination_location': destination.toLocationJson(),
      },
    );

    if (response == null) {
      return const [];
    }

    final cars = _extractNearbyCarsResponse(response);
    return cars
        .whereType<Map<String, dynamic>>()
        .map(NearbyCar.fromJson)
        .toList();
  }

  Future<RouteEstimate> loadRouteEstimate({
    required String cityId,
    required String tariffId,
    required GeoPoint pickup,
    required GeoPoint destination,
  }) async {
    if (cityId.isEmpty) {
      throw AppException('Backend requires city_id for route estimate');
    }
    if (tariffId.isEmpty) {
      throw AppException(
        'PASSENGER_DEFAULT_TARIFF_ID is not configured and backend requires tariff_id',
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

    if (response is! Map<String, dynamic> || response.isEmpty) {
      throw AppException('Backend returned empty route estimate response');
    }

    return RouteEstimate.fromJson(response);
  }

  List<dynamic> _extractNearbyCarsResponse(dynamic response) {
    if (response is List<dynamic>) {
      return response;
    }

    if (response is! Map<String, dynamic>) {
      throw AppException('Unexpected nearby cars response format');
    }

    final candidates = <dynamic>[
      response['cars'],
      response['items'],
      response['results'],
      response['nearby_cars'],
    ];

    for (final candidate in candidates) {
      if (candidate is List<dynamic>) {
        return candidate;
      }
    }

    return const [];
  }
}
