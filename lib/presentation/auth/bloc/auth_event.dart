part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthBootstrapRequested extends AuthEvent {
  const AuthBootstrapRequested();
}

class AuthRequestCodeSubmitted extends AuthEvent {
  const AuthRequestCodeSubmitted(this.phone);

  final String phone;

  @override
  List<Object?> get props => [phone];
}

class AuthConfirmCodeSubmitted extends AuthEvent {
  const AuthConfirmCodeSubmitted({
    required this.phone,
    required this.code,
  });

  final String phone;
  final String code;

  @override
  List<Object?> get props => [phone, code];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}
