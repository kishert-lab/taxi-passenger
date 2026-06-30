import 'package:taxi_passenger/core/constants/api_endpoints.dart';
import 'package:taxi_passenger/data/api/api_client.dart';
import 'package:taxi_passenger/domain/models/models.dart';

class PassengerProfileApi {
  PassengerProfileApi(this._apiClient);

  final ApiClient _apiClient;

  Future<Passenger> loadProfile() async {
    final response = await _apiClient.get(ApiEndpoints.me);
    return Passenger.fromJson(
      response as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }

  Future<Passenger> updateProfile({
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.me,
      data: {
        'name': name,
        'email': email,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      },
    );

    return Passenger.fromJson(
      response as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }
}
