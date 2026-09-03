import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/network/base_api_service.dart';
import '../models/user_model.dart';

/// Repository handling Sitefinity Authentication, Token Storage & User Session
class AuthRepository {
  final BaseApiService _apiService;
  final SharedPreferences _prefs;

  AuthRepository(this._apiService, this._prefs);

  /// Authenticate with Sitefinity Headless CMS Authentication / OpenID connect
  Future<UserModel> login({
    required String username,
    required String password,
    bool rememberMe = true,
  }) async {
    final response = await _apiService.getPostApiResponse(
      ApiEndpoints.login,
      {
        'username': username,
        'password': password,
        'grant_type': 'password',
        'client_id': 'idea_test_TNM7NAj7tr8DPiY',
        'client_secret': 'ihcTD8qpM1ruxnS8L1OI8TYe',
      },
    );

    dynamic data = response;
    if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {}
    }

    if (data is Map &&
        data['access_token'] != null &&
        data['access_token'].toString().trim().isNotEmpty) {
      final accessToken = data['access_token'].toString().trim();
      final refreshToken = data['refresh_token']?.toString();
      final tokenType = data['token_type']?.toString() ?? 'bearer';
      final expiresIn = data['expires_in']?.toString();

      // Store in local storage
      await _prefs.setString(AppConstants.keyAuthToken, accessToken);
      await _prefs.setBool(AppConstants.keyIsLoggedIn, true);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _prefs.setString(AppConstants.keyRefreshToken, refreshToken);
      }
      if (tokenType.isNotEmpty) {
        await _prefs.setString(AppConstants.keyTokenType, tokenType);
      }
      if (expiresIn != null && expiresIn.isNotEmpty) {
        await _prefs.setString(AppConstants.keyExpiresIn, expiresIn);
      }

      final user = UserModel(
        id: data['id']?.toString() ?? 'usr-101',
        fullName: data['fullName']?.toString() ?? _formatNameFromEmail(username),
        email: username.contains('@') ? username : '$username@idealake.com',
        role: username.toLowerCase().contains('admin')
            ? 'Sitefinity CMS Admin'
            : 'LTFS Enterprise User',
        department: 'Digital Solutions & Content Architecture',
        token: accessToken,
        lastLoginTime: DateTime.now(),
      );

      await _prefs.setString(AppConstants.keyUserData, jsonEncode(user.toJson()));
      return user;
    } else {
      throw FetchDataException(
        'Login failed: Response did not contain a valid access_token.',
      );
    }
  }

  /// Check current active user session
  UserModel? getCurrentUser() {
    final raw = _prefs.getString(AppConstants.keyUserData);
    if (raw != null && raw.isNotEmpty) {
      try {
        return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {}
    }
    return null;
  }

  /// Check if session token exists
  bool isLoggedIn() {
    final token = _prefs.getString(AppConstants.keyAuthToken);
    return token != null && token.trim().isNotEmpty;
  }

  /// Retrieve active authentication token
  String? getAuthToken() {
    return _prefs.getString(AppConstants.keyAuthToken);
  }

  /// Explicitly clear all stored tokens and session data from local storage
  Future<void> clearToken() async {
    await _prefs.remove(AppConstants.keyAuthToken);
    await _prefs.remove(AppConstants.keyRefreshToken);
    await _prefs.remove(AppConstants.keyTokenType);
    await _prefs.remove(AppConstants.keyExpiresIn);
    await _prefs.remove(AppConstants.keyIsLoggedIn);
    await _prefs.remove(AppConstants.keyUserData);
  }

  /// Terminate session and clear stored tokens
  Future<void> logout() async {
    // 1. Immediately wipe all local tokens and session data so the app is logged out instantly
    await clearToken();

    // 2. Best-effort call to backend logout endpoint with short timeout
    try {
      await _apiService
          .getPostApiResponse(ApiEndpoints.logout, {})
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      // Ignored: Local session is already cleared
    }
  }

  String _formatNameFromEmail(String email) {
    if (!email.contains('@')) return email.isNotEmpty ? email : 'Rakesh Sunar';
    final namePart = email.split('@').first.replaceAll('.', ' ').replaceAll('_', ' ');
    return namePart
        .split(' ')
        .map((e) => e.isNotEmpty ? '${e[0].toUpperCase()}${e.substring(1)}' : '')
        .join(' ');
  }
}
