import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:taxi_passenger/core/errors/app_exception.dart';
import 'package:taxi_passenger/data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState()) {
    on<AuthBootstrapRequested>(_onBootstrapRequested);
    on<AuthRequestCodeSubmitted>(_onRequestCodeSubmitted);
    on<AuthConfirmCodeSubmitted>(_onConfirmCodeSubmitted);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSessionExpired>(_onSessionExpired);
  }

  final AuthRepository _authRepository;

  Future<void> _onBootstrapRequested(
    AuthBootstrapRequested event,
    Emitter<AuthState> emit,
  ) async {
    final hasSession = await _authRepository.hasSession();
    emit(
      state.copyWith(
        status: hasSession
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
      ),
    );
  }

  Future<void> _onRequestCodeSubmitted(
    AuthRequestCodeSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      await _authRepository.requestCode(event.phone);
      emit(
        state.copyWith(status: AuthStatus.codeRequested, phone: event.phone),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: _messageFromError(error),
        ),
      );
    }
  }

  Future<void> _onConfirmCodeSubmitted(
    AuthConfirmCodeSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    try {
      await _authRepository.confirmCode(
        phone: event.phone,
        code: event.code,
        name: event.name,
      );
      emit(
        state.copyWith(status: AuthStatus.authenticated, phone: event.phone),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.codeRequested,
          errorMessage: _messageFromError(error),
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    await _authRepository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.clearSession();
    emit(
      const AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Сессия истекла. Войдите снова.',
      ),
    );
  }

  String _messageFromError(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return 'Ошибка соединения';
  }
}
