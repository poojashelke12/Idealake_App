import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/view_model/auth_bloc.dart';
import '../../features/auth/view_model/auth_event.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../routes/app_router.dart';
import '../routes/app_routes.dart';
import '../utils/ui_helpers.dart';

/// Centralized Session Manager handling token expiration and automatic logout
class SessionManager {
  SessionManager._();

  static bool _isLoggingOut = false;

  /// Determines if an HTTP response indicates that the user's session/token has expired
  /// or returned: {error: {code: Unauthorized, message: The current user is not allowed access}}
  static bool isSessionExpired(dynamic data, int? statusCode, {String? path}) {
    // 1. Never treat login / token acquisition requests as session expiration
    if (path != null) {
      final normalizedPath = path.toLowerCase();
      if (normalizedPath.contains(ApiEndpoints.login.toLowerCase()) ||
          normalizedPath.contains('oauth/token') ||
          normalizedPath.contains('/auth/token')) {
        return false;
      }
    }

    // 2. HTTP 401 Unauthorized or 403 Forbidden
    if (statusCode == 401 || statusCode == 403) {
      return true;
    }

    // 3. Inspect response body payload
    if (data == null) return false;

    if (data is Map) {
      // Check for nested error object: {error: {code: Unauthorized, message: ...}}
      final error = data['error'];
      if (error is Map) {
        final code = error['code']?.toString().toLowerCase();
        final message = error['message']?.toString().toLowerCase();
        if (code == 'unauthorized') return true;
        if (message != null &&
            (message.contains('not allowed access') ||
                message.contains('unauthorized') ||
                message.contains('token expired') ||
                message.contains('invalid token'))) {
          return true;
        }
      } else if (error is String) {
        final errStr = error.toLowerCase();
        if (errStr == 'unauthorized' || errStr.contains('unauthorized')) {
          return true;
        }
      }

      // Check root level properties
      final code = data['code']?.toString().toLowerCase();
      if (code == 'unauthorized') return true;

      final message = data['message']?.toString().toLowerCase();
      if (message != null &&
          (message.contains('not allowed access') ||
              message.contains('unauthorized') ||
              message.contains('token expired'))) {
        return true;
      }

      final errorDesc = data['error_description']?.toString().toLowerCase();
      if (errorDesc != null &&
          (errorDesc.contains('token expired') ||
              errorDesc.contains('invalid token') ||
              errorDesc.contains('unauthorized'))) {
        return true;
      }
    }

    return false;
  }

  /// Extracts the specific unauthorized message from backend error payload
  static String extractUnauthorizedMessage(dynamic data) {
    if (data is Map) {
      final error = data['error'];
      if (error is Map && error['message'] != null) {
        return error['message'].toString();
      }
      if (data['message'] != null) {
        return data['message'].toString();
      }
    }
    return 'The current user is not allowed access. Please log in again.';
  }

  /// Triggers automatic logout: wipes local session tokens, notifies AuthBloc,
  /// redirects to LoginScreen, and displays a session expiration notice.
  static Future<void> handleSessionExpired({
    SharedPreferences? prefs,
    dynamic errorData,
  }) async {
    // Guard against multiple concurrent 401 triggers
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      final message = errorData != null
          ? extractUnauthorizedMessage(errorData)
          : 'Session expired. The current user is not allowed access.';

      // 1. Wipe all local auth tokens and session flags
      final sp = prefs ?? await SharedPreferences.getInstance();
      await sp.remove(AppConstants.keyAuthToken);
      await sp.remove(AppConstants.keyRefreshToken);
      await sp.remove(AppConstants.keyTokenType);
      await sp.remove(AppConstants.keyExpiresIn);
      await sp.remove(AppConstants.keySfTokenId);
      await sp.remove(AppConstants.keyIsLoggedIn);
      await sp.remove(AppConstants.keyUserData);

      // 2. Perform navigation to Login screen
      final navState = AppRouter.navigatorKey.currentState;
      final navContext = AppRouter.navigatorKey.currentContext;

      // Notify AuthBloc if context is accessible and mounted
      if (navContext != null && navContext.mounted) {
        try {
          navContext.read<AuthBloc>().add(AuthLogoutRequested());
        } catch (_) {}
      }

      if (navState != null) {
        // Post frame to avoid navigating during an active build phase
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // If we are already on the login screen, do not re-push
          navState.pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false,
          );

          // Show floating expiration message to the user
          final ctx = AppRouter.navigatorKey.currentContext;
          if (ctx != null && ctx.mounted) {
            UIHelpers.showSnackBar(
              ctx,
              message,
              isError: true,
              duration: const Duration(seconds: 4),
            );
          }
        });
      }
    } catch (_) {
      // Best-effort cleanup
    } finally {
      // Reset debounce lock after delay
      Future.delayed(const Duration(seconds: 3), () {
        _isLoggingOut = false;
      });
    }
  }
}
