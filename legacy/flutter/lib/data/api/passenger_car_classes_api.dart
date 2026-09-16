import 'package:taxi_passenger/core/constants/api_endpoints.dart';
import 'package:taxi_passenger/data/api/api_client.dart';
import 'package:taxi_passenger/domain/models/models.dart';

class PassengerCarClassesApi {
  PassengerCarClassesApi(this._apiClient);

  final ApiClient _apiClient;

  Future<List<CarClass>> loadCarClasses() async {
    final response = await _apiClient.get(ApiEndpoints.carClasses);
    final responseMap =
        response as Map<String, dynamic>? ?? <String, dynamic>{};
    final items = response is List<dynamic>
        ? response
        : responseMap['items'] as List<dynamic>? ??
              responseMap['car_classes'] as List<dynamic>? ??
              const [];

    final carClasses = (items as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(CarClass.fromJson)
        .toList();

    carClasses.sort((left, right) => left.sortOrder.compareTo(right.sortOrder));
    return carClasses;
  }
}
