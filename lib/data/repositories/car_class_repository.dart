import 'package:taxi_passenger/data/api/passenger_car_classes_api.dart';
import 'package:taxi_passenger/domain/models/models.dart';

class CarClassRepository {
  CarClassRepository({required PassengerCarClassesApi carClassesApi})
    : _carClassesApi = carClassesApi;

  final PassengerCarClassesApi _carClassesApi;

  Future<List<CarClass>> loadCarClasses() {
    return _carClassesApi.loadCarClasses();
  }
}
