import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:get/get.dart' as getx;

import 'package:link/core/constants/api_constants.dart';
import 'package:link/core/error/exceptions.dart';

/// HTTP client wrapper using Dio with caching, logging, and error handling
class ApiClient extends getx.GetxService {
  late final Dio _dio;
  late final CacheStore _cacheStore;

  Future<ApiClient> init() async {
    await _initializeDio();
    return this;
  }

  Future<void> _initializeDio() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Initialize cache
    _cacheStore = MemCacheStore();
    final cacheOptions = CacheOptions(
      store: _cacheStore,
      maxStale: const Duration(days: 7),
    );
    // Add interceptors
    _dio.interceptors.addAll([DioCacheInterceptor(options: cacheOptions)]);
  }

  /// GET request with optional query parameters
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// POST request
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// PUT request
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// DELETE request
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Download file
  Future<void> download(
    String urlPath,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    Options? options,
  }) async {
    try {
      await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _cacheStore.clean();
  }

  /// Convert DioException to custom exceptions
  AppException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.badResponse:
        return ServerException(_getServerErrorMessage(e.response?.statusCode));
      case DioExceptionType.cancel:
        return const NetworkException('Request was cancelled');
      case DioExceptionType.connectionError:
        return const NetworkException('No internet connection');
      default:
        return UnknownException('An unexpected error occurred: ${e.message}');
    }
  }

  String _getServerErrorMessage(int? statusCode) {
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
}
