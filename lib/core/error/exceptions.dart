/// Base application exception
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
