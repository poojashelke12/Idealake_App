import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_response.dart';
import '../repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// ViewModel (BLoC) managing Login, Authentication, and Session states
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(const AuthState()) {
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  void _onCheckStatus(AuthCheckStatusEvent event, Emitter<AuthState> emit) {
    final isLogged = _repository.isLoggedIn();
    final user = _repository.getCurrentUser();
    emit(state.copyWith(
      isAuthenticated: isLogged,
      currentUser: user,
      loginResponse: isLogged && user != null ? ApiResponse.completed(user) : const ApiResponse.initial(),
    ));
  }

  Future<void> _onLoginSubmitted(AuthLoginSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(loginResponse: const ApiResponse.loading()));

    try {
      final user = await _repository.login(
        username: event.username,
        password: event.password,
        rememberMe: event.rememberMe,
      );
      emit(state.copyWith(
        loginResponse: ApiResponse.completed(user),
        isAuthenticated: true,
        currentUser: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        loginResponse: ApiResponse.error(e.toString()),
        isAuthenticated: false,
      ));
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(const AuthState());
  }
}
