import 'dart:io';
import 'package:dio/dio.dart';

import 'api_exceptions.dart';
import 'base_api_service.dart';
import 'dio_client.dart';

/// Concrete Network Service implementation using Dio
class NetworkApiService implements BaseApiService {
  final DioClient _dioClient;

  NetworkApiService(this._dioClient);

  Dio get _dio => _dioClient.dio;

  @override
  Future<dynamic> getGetApiResponse(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return _returnResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on SocketException {
      throw NoInternetException('No internet connection');
    } catch (e) {
      throw FetchDataException(e.toString());
    }
  }

  @override
  Future<dynamic> getPostApiResponse(
    String url,
    dynamic data, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      return _returnResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on SocketException {
      throw NoInternetException('No internet connection');
    } catch (e) {
      throw FetchDataException(e.toString());
    }
  }

  @override
  Future<dynamic> getPutApiResponse(
    String url,
    dynamic data, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return _returnResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on SocketException {
      throw NoInternetException('No internet connection');
    } catch (e) {
      throw FetchDataException(e.toString());
    }
  }

  @override
  Future<dynamic> getPatchApiResponse(
    String url,
    dynamic data, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.patch(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return _returnResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on SocketException {
      throw NoInternetException('No internet connection');
    } catch (e) {
      throw FetchDataException(e.toString());
    }
  }

  @override
  Future<dynamic> getDeleteApiResponse(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return _returnResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on SocketException {
      throw NoInternetException('No internet connection');
    } catch (e) {
      throw FetchDataException(e.toString());
    }
  }

  dynamic _returnResponse(Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 202:
        return response.data;
      case 400:
        throw BadRequestException(
          _extractErrorMessage(response.data) ?? 'Invalid request',
          response.statusCode,
        );
      case 401:
      case 403:
        throw UnauthorizedException(
          _extractErrorMessage(response.data) ?? 'Unauthorized access',
          response.statusCode,
        );
      case 404:
        throw NotFoundException(
          _extractErrorMessage(response.data) ?? 'Resource not found',
          response.statusCode,
        );
      case 500:
      case 502:
      case 503:
        throw InternalServerException(
          _extractErrorMessage(response.data) ?? 'Internal server error',
          response.statusCode,
        );
      default:
        throw FetchDataException(
          'Error occurred with status code: ${response.statusCode}',
          response.statusCode,
        );
    }
  }

  AppException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Connection timed out. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = _extractErrorMessage(e.response?.data);
        if (statusCode == 400) return BadRequestException(message, statusCode);
        if (statusCode == 401 || statusCode == 403) {
          return UnauthorizedException(message, statusCode);
        }
        if (statusCode == 404) return NotFoundException(message, statusCode);
        if (statusCode != null && statusCode >= 500) {
          return InternalServerException(message, statusCode);
        }
        return FetchDataException(
          message ?? 'Unexpected server error',
          statusCode,
        );
      case DioExceptionType.cancel:
        return FetchDataException('Request was cancelled');
      case DioExceptionType.connectionError:
        return NoInternetException(
          'No internet connection or server is unreachable',
        );
      case DioExceptionType.badCertificate:
        return FetchDataException('Security certificate verification failed');
      case DioExceptionType.unknown:
      default:
        if (e.error is SocketException) {
          return NoInternetException('No internet connection detected');
        }
        return FetchDataException(e.message ?? 'An unknown error occurred');
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      if (data.containsKey('error_description') && data['error_description'] is String) {
        return data['error_description'] as String;
      }
      if (data.containsKey('message') && data['message'] is String) {
        return data['message'] as String;
      }
      if (data.containsKey('error') && data['error'] is String) {
        return data['error'] as String;
      }
      if (data.containsKey('msg') && data['msg'] is String) {
        return data['msg'] as String;
      }
    }
    if (data is String) return data;
    return null;
  }
}
