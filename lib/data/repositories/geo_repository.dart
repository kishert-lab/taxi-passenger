import 'package:taxi_passenger/data/api/passenger_geo_api.dart';
import 'package:taxi_passenger/domain/models/models.dart';

class GeoRepository {
  GeoRepository({required PassengerGeoApi geoApi}) : _geoApi = geoApi;

  final PassengerGeoApi _geoApi;

  Future<GeoPoint> loadCurrentLocation() async {
    return const GeoPoint(
      lat: 56.8389,
      lng: 60.6057,
      address: 'Текущее местоположение',
    );
  }

  Future<List<GeoPoint>> searchAddresses({
    required String query,
    String? cityId,
    double? lat,
    double? lon,
    int limit = 5,
  }) {
    return _geoApi.searchAddresses(
      query: query,
      cityId: cityId,
      lat: lat,
      lon: lon,
      limit: limit,
    );
  }

  Future<List<NearbyCar>> loadNearbyCars({
    required GeoPoint pickup,
    required GeoPoint destination,
  }) {
    return _geoApi.loadNearbyCars(pickup: pickup, destination: destination);
  }

  Future<RouteEstimate> loadRouteEstimate({
    required GeoPoint pickup,
    required GeoPoint destination,
  }) {
    return _geoApi.loadRouteEstimate(
      pickup: pickup,
      destination: destination,
    );
  }
}
