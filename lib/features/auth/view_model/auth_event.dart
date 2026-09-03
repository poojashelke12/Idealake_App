import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginSubmitted extends AuthEvent {
  final String username;
  final String password;
  final bool rememberMe;

  const AuthLoginSubmitted({
    required this.username,
    required this.password,
    this.rememberMe = true,
  });

  @override
  List<Object?> get props => [username, password, rememberMe];
}

class AuthCheckStatusEvent extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}
