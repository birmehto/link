abstract class AppException implements Exception {
  const AppException(
    this.message, {
    this.code,
    this.originalException,
    this.stackTrace,
  });
  final String message;
  final String? code;
  final dynamic originalException;
  final StackTrace? stackTrace;

  @override
  String toString() => 'AppException: $message';
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.code,
    super.originalException,
    super.stackTrace,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// Server related exceptions
class ServerException extends AppException {
  const ServerException(
    super.message, {
    super.code,
    super.originalException,
    super.stackTrace,
  });

  @override
  String toString() => 'ServerException: $message';
}

/// Cache related exceptions
class CacheException extends AppException {
  const CacheException(
    super.message, {
    super.code,
    super.originalException,
    super.stackTrace,
  });

  @override
  String toString() => 'CacheException: $message';
}

/// Unknown or unexpected exceptions
class UnknownException extends AppException {
  const UnknownException(
    super.message, {
    super.code,
    super.originalException,
    super.stackTrace,
  });

  @override
  String toString() => 'UnknownException: $message';
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.code,
    super.originalException,
    super.stackTrace,
  });

  @override
  String toString() => 'ValidationException: $message';
}

/// Permission related exceptions
class PermissionException extends AppException {
  const PermissionException(
    super.message, {
    super.code,
    super.originalException,
    super.stackTrace,
  });

  @override
  String toString() => 'PermissionException: $message';
}

String getServerErrorMessage(int? statusCode) {
  switch (statusCode) {
    case 400:
      return 'Bad request. Please check your input.';
    case 401:
      return 'Unauthorized. Please login again.';
    case 403:
      return 'Access forbidden.';
    case 404:
      return 'Resource not found.';
    case 429:
      return 'Too many requests. Please try again later.';
    case 500:
      return 'Internal server error. Please try again later.';
    case 502:
      return 'Bad gateway. Please try again later.';
    case 503:
      return 'Service unavailable. Please try again later.';
    default:
      return 'Server error occurred. Please try again later.';
  }
}
