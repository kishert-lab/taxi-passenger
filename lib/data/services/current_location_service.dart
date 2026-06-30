import 'package:geolocator/geolocator.dart';
import 'package:taxi_passenger/core/errors/app_exception.dart';
import 'package:taxi_passenger/domain/models/models.dart';

class CurrentLocationService {
  Future<GeoPoint> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw AppException('Служба геолокации отключена на устройстве');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw AppException('Нет доступа к геолокации');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return GeoPoint(
      lat: position.latitude,
      lng: position.longitude,
      address: 'Текущее местоположение',
    );
  }
}
