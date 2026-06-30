import 'package:taxi_passenger/core/constants/api_endpoints.dart';
import 'package:taxi_passenger/data/api/api_client.dart';
import 'package:taxi_passenger/domain/models/models.dart';

class PassengerProfileApi {
  PassengerProfileApi(this._apiClient);

  final ApiClient _apiClient;

  Future<Passenger> loadProfile() async {
    final response = await _apiClient.get(ApiEndpoints.me);
    if (response.isNotEmpty) {
      return Passenger.fromJson(response);
    }

    return const Passenger(
      id: 'passenger-1',
      phone: '+79991234567',
      name: 'Пассажир',
      email: 'passenger@example.com',
      avatar: '',
    );
  }

  Future<Passenger> updateProfile({
    required String name,
    required String email,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.me,
      data: {
        'name': name,
        'email': email,
      },
    );

    if (response.isNotEmpty) {
      return Passenger.fromJson(response);
    }

    return Passenger(
      id: 'passenger-1',
      phone: '+79991234567',
      name: name,
      email: email,
      avatar: '',
    );
  }
}
