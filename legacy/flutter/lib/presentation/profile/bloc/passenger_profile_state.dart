part of 'passenger_profile_bloc.dart';

class PassengerProfileState extends Equatable {
  const PassengerProfileState({
    this.passenger,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  final Passenger? passenger;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  PassengerProfileState copyWith({
    Passenger? passenger,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
  }) {
    return PassengerProfileState(
      passenger: passenger ?? this.passenger,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [passenger, isLoading, isSaving, errorMessage];
}
