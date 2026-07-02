import 'package:taxi_passenger/data/api/passenger_geo_api.dart';
import 'package:taxi_passenger/data/services/current_location_service.dart';
import 'package:taxi_passenger/domain/models/models.dart';

class GeoRepository {
  GeoRepository({
    required PassengerGeoApi geoApi,
    required CurrentLocationService currentLocationService,
  }) : _geoApi = geoApi,
       _currentLocationService = currentLocationService;

  final PassengerGeoApi _geoApi;
  final CurrentLocationService _currentLocationService;

  Future<GeoPoint> loadCurrentLocation() {
    return _currentLocationService.getCurrentLocation();
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
    required String carClassId,
    required GeoPoint pickup,
    required GeoPoint destination,
  }) {
    return _geoApi.loadRouteEstimate(
      carClassId: carClassId,
      pickup: pickup,
      destination: destination,
    );
  }
}
