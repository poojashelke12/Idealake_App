import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';

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

/// Injects Bearer auth token if available into request headers
class _AuthInterceptor extends Interceptor {
  final SharedPreferences _prefs;

  _AuthInterceptor(this._prefs);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _prefs.getString(AppConstants.keyAuthToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      options.headers.remove('Authorization');
    }
    return handler.next(options);
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
