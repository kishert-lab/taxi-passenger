import 'package:taxi_passenger/data/api/passenger_profile_api.dart';
import 'package:taxi_passenger/domain/models/models.dart';

class ProfileRepository {
  ProfileRepository({required PassengerProfileApi profileApi})
    : _profileApi = profileApi;

  final PassengerProfileApi _profileApi;

  Future<Passenger> loadProfile() {
    return _profileApi.loadProfile();
  }

  Future<Passenger> updateProfile({
    required String name,
    required String email,
    String? avatarUrl,
  }) {
    return _profileApi.updateProfile(
      name: name,
      email: email,
      avatarUrl: avatarUrl,
    );
  }
}
