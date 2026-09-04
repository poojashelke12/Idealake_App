import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import 'session_manager.dart';

/// Singleton Dio Client with centralized configuration and interceptors
class DioClient {
  late final Dio _dio;
  final SharedPreferences _prefs;

  DioClient(this._prefs) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectionTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        sendTimeout: ApiEndpoints.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(_prefs),
      _LoggingInterceptor(),
    ]);
  }

  Dio get dio => _dio;
}

/// Injects Bearer auth token and Cookie if available into request headers
class _AuthInterceptor extends Interceptor {
  final SharedPreferences _prefs;

  _AuthInterceptor(this._prefs);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 1. Inject Authorization header if token exists in preferences
    final token = _prefs.getString(AppConstants.keyAuthToken);
    if (token != null && token.trim().isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${token.trim()}';
    }

    // 2. Inject Cookie header with SF-TokenId if available
    final sfTokenId = _prefs.getString(AppConstants.keySfTokenId) ?? AppConstants.defaultSfTokenId;
    if (sfTokenId.isNotEmpty && !options.headers.containsKey('Cookie')) {
      options.headers['Cookie'] = 'SF-TokenId=$sfTokenId';
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Check if 200 OK returned an unauthorized payload:
    // e.g. {error: {code: Unauthorized, message: The current user is not allowed access}}
    if (SessionManager.isSessionExpired(
      response.data,
      response.statusCode,
      path: response.requestOptions.path,
    )) {
      SessionManager.handleSessionExpired(prefs: _prefs, errorData: response.data);
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Check if error response has 401/403 or unauthorized payload
    final data = err.response?.data;
    final statusCode = err.response?.statusCode;
    if (SessionManager.isSessionExpired(
      data,
      statusCode,
      path: err.requestOptions.path,
    )) {
      SessionManager.handleSessionExpired(prefs: _prefs, errorData: data);
    }
    return handler.next(err);
  }
}

/// Logs HTTP requests, responses, and errors in debug mode
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('--> ${options.method} ${options.baseUrl}${options.path}');
      if (options.queryParameters.isNotEmpty) {
        debugPrint('Query Params: ${options.queryParameters}');
      }
      if (options.data != null) {
        debugPrint('Request Body: ${options.data}');
      }
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- [${response.statusCode}] ${response.requestOptions.path}');
      debugPrint('Response Body: ${response.data}');
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- ERROR [${err.response?.statusCode}] ${err.requestOptions.path}');
      debugPrint('Error Message: ${err.message}');
      if (err.response?.data != null) {
        debugPrint('Error Data: ${err.response?.data}');
      }
    }
    return handler.next(err);
  }
}
