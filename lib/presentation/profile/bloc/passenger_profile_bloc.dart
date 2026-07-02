import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:taxi_passenger/data/repositories/profile_repository.dart';
import 'package:taxi_passenger/domain/models/models.dart';

part 'passenger_profile_event.dart';
part 'passenger_profile_state.dart';

class PassengerProfileBloc
    extends Bloc<PassengerProfileEvent, PassengerProfileState> {
  PassengerProfileBloc({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository,
      super(const PassengerProfileState()) {
    on<PassengerProfileLoadRequested>(_onLoadRequested);
    on<PassengerProfileUpdateRequested>(_onUpdateRequested);
  }

  final ProfileRepository _profileRepository;

  Future<void> _onLoadRequested(
    PassengerProfileLoadRequested event,
    Emitter<PassengerProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final passenger = await _profileRepository.loadProfile();
      emit(state.copyWith(isLoading: false, passenger: passenger));
    } catch (_) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Ошибка соединения'));
    }
  }

  Future<void> _onUpdateRequested(
    PassengerProfileUpdateRequested event,
    Emitter<PassengerProfileState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    try {
      final passenger = await _profileRepository.updateProfile(
        name: event.name,
        email: event.email,
      );
      emit(state.copyWith(isSaving: false, passenger: passenger));
    } catch (_) {
      emit(state.copyWith(isSaving: false, errorMessage: 'Ошибка соединения'));
    }
  }
}
