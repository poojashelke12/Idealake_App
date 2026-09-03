import 'package:equatable/equatable.dart';
import '../../../core/network/api_response.dart';
import '../models/user_model.dart';

class AuthState extends Equatable {
  final ApiResponse<UserModel> loginResponse;
  final bool isAuthenticated;
  final UserModel? currentUser;

  const AuthState({
    this.loginResponse = const ApiResponse.initial(),
    this.isAuthenticated = false,
    this.currentUser,
  });

  AuthState copyWith({
    ApiResponse<UserModel>? loginResponse,
    bool? isAuthenticated,
    UserModel? currentUser,
  }) {
    return AuthState(
      loginResponse: loginResponse ?? this.loginResponse,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentUser: currentUser ?? this.currentUser,
    );
  }

  @override
  List<Object?> get props => [loginResponse, isAuthenticated, currentUser];
}
