/// Base Custom Exception Class for API & Network errors
class AppException implements Exception {
  final String? message;
  final String? prefix;
  final int? statusCode;

  AppException([this.message, this.prefix, this.statusCode]);

  @override
  String toString() {
    return '$prefix$message';
  }
}

class FetchDataException extends AppException {
  FetchDataException([String? message, int? statusCode])
      : super(message ?? 'Error occurred while communicating with server', 'Error: ', statusCode);
}

class BadRequestException extends AppException {
  BadRequestException([String? message, int? statusCode])
      : super(message ?? 'Invalid request', 'Bad Request: ', statusCode);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String? message, int? statusCode])
      : super(message ?? 'Unauthorized access', 'Unauthorized: ', statusCode);
}

class NotFoundException extends AppException {
  NotFoundException([String? message, int? statusCode])
      : super(message ?? 'Requested resource was not found', 'Not Found: ', statusCode);
}

class InternalServerException extends AppException {
  InternalServerException([String? message, int? statusCode])
      : super(message ?? 'Internal server error occurred', 'Server Error: ', statusCode);
}

class NoInternetException extends AppException {
  NoInternetException([String? message])
      : super(message ?? 'No internet connection detected', 'Network Error: ', 0);
}

class TimeoutException extends AppException {
  TimeoutException([String? message])
      : super(message ?? 'Request timed out. Please try again.', 'Timeout: ', 408);
}
