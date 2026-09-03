/// Abstract Base API Service defining standard HTTP operations
abstract class BaseApiService {
  Future<dynamic> getGetApiResponse(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<dynamic> getPostApiResponse(
    String url,
    dynamic data, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<dynamic> getPutApiResponse(
    String url,
    dynamic data, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<dynamic> getPatchApiResponse(
    String url,
    dynamic data, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<dynamic> getDeleteApiResponse(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });
}
