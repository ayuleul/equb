import 'dart:async';

import 'package:dio/dio.dart';

import '../errors/api_error.dart';
import '../logging/app_logger.dart';
import '../storage/token_store.dart';
import 'auth_tokens.dart';

class ApiClient {
  ApiClient({
    required String baseUrl,
    required TokenStore tokenStore,
    required AppLogger logger,
  }) : _tokenStore = tokenStore,
       _logger = logger,
       _baseUrl = baseUrl,
       _dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: const Duration(seconds: 15),
           receiveTimeout: const Duration(seconds: 15),
           sendTimeout: const Duration(seconds: 15),
           contentType: Headers.jsonContentType,
         ),
       ) {
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        contentType: Headers.jsonContentType,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStore.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          _logger.info('HTTP ${options.method} ${options.uri}');
          handler.next(options);
        },
        onError: (error, handler) async {
          final retried = error.requestOptions.extra['retried'] == true;
          final isUnauthorized = error.response?.statusCode == 401;
          final isRefreshCall = error.requestOptions.path.endsWith(
            '/auth/refresh',
          );

          if (isUnauthorized && !retried && !isRefreshCall) {
            final refreshedTokens = await _refreshTokens();

            if (refreshedTokens != null) {
              final newRequest = error.requestOptions.copyWith(
                headers: {
                  ...error.requestOptions.headers,
                  'Authorization': 'Bearer ${refreshedTokens.accessToken}',
                },
                extra: {...error.requestOptions.extra, 'retried': true},
              );

              try {
                final response = await _dio.fetch<dynamic>(newRequest);
                handler.resolve(response);
                return;
              } on DioException catch (retryError) {
                handler.reject(retryError);
                return;
              }
            }
          }

          _logger.warning(
            'HTTP error ${error.requestOptions.method} ${error.requestOptions.uri}',
            error: error,
            stackTrace: error.stackTrace,
          );
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  late final Dio _refreshDio;
  final TokenStore _tokenStore;
  final AppLogger _logger;
  final String _baseUrl;

  Completer<AuthTokens?>? _refreshCompleter;

  Future<Map<String, dynamic>> getMap(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    _assertConfigured();

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return response.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    _assertConfigured();

    try {
      final response = await _dio.get<List<dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return response.data ?? <dynamic>[];
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> postMap(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    _assertConfigured();

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data ?? <String, dynamic>{};
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  Future<AuthTokens?> _refreshTokens() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<AuthTokens?>();

    try {
      final refreshToken = await _tokenStore.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _tokenStore.clear();
        _refreshCompleter!.complete(null);
        return _refreshCompleter!.future;
      }

      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: <String, dynamic>{'refreshToken': refreshToken},
      );

      final payload = response.data;
      if (payload == null ||
          payload['accessToken'] is! String ||
          payload['refreshToken'] is! String) {
        await _tokenStore.clear();
        _refreshCompleter!.complete(null);
        return _refreshCompleter!.future;
      }

      final tokens = AuthTokens.fromJson(payload);
      await _tokenStore.saveTokens(tokens);
      _logger.info('Refresh token rotation succeeded.');
      _refreshCompleter!.complete(tokens);
    } catch (error, stackTrace) {
      _logger.warning(
        'Refresh token rotation failed. Clearing stored tokens.',
        error: error,
        stackTrace: stackTrace,
      );
      await _tokenStore.clear();
      _refreshCompleter!.complete(null);
    } finally {
      final completer = _refreshCompleter;
      Future<void>.microtask(() {
        if (identical(_refreshCompleter, completer)) {
          _refreshCompleter = null;
        }
      });
    }

    return _refreshCompleter!.future;
  }

  void _assertConfigured() {
    if (_baseUrl.trim().isEmpty) {
      throw const ApiError(
        type: ApiErrorType.configuration,
        message: 'API_BASE_URL is not configured.',
      );
    }
  }
}
