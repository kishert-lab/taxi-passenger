part of 'passenger_profile_bloc.dart';

sealed class PassengerProfileEvent extends Equatable {
  const PassengerProfileEvent();

  @override
  List<Object?> get props => [];
}

class PassengerProfileLoadRequested extends PassengerProfileEvent {
  const PassengerProfileLoadRequested();
}

class PassengerProfileUpdateRequested extends PassengerProfileEvent {
  const PassengerProfileUpdateRequested({
    required this.name,
    required this.email,
  });

  final String name;
  final String email;

  @override
  List<Object?> get props => [name, email];
}
