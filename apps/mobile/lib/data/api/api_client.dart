import 'dart:async';

import 'package:dio/dio.dart';

import '../auth/token_store.dart';
import '../models/health_status.dart';
import 'api_error.dart';

typedef SessionExpiredCallback = FutureOr<void> Function();

const _authorizationHeader = 'Authorization';

class ApiClient {
  ApiClient({
    required String baseUrl,
    required Duration timeout,
    required TokenStore tokenStore,
    SessionExpiredCallback? onSessionExpired,
    Dio? dio,
    Dio? refreshDio,
  }) : _tokenStore = tokenStore,
       _onSessionExpired = onSessionExpired {
    final baseOptions = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      headers: const <String, dynamic>{
        Headers.contentTypeHeader: Headers.jsonContentType,
        Headers.acceptHeader: Headers.jsonContentType,
      },
    );

    _dio = dio ?? Dio(baseOptions);
    _refreshDio = refreshDio ?? Dio(baseOptions);

    _applyBaseOptions(_dio, baseOptions);
    _applyBaseOptions(_refreshDio, baseOptions);

    _dio.interceptors.add(
      AuthRefreshInterceptor(
        dio: _dio,
        refreshDio: _refreshDio,
        tokenStore: _tokenStore,
        onSessionExpired: _onSessionExpired,
      ),
    );
  }

  late final Dio _dio;
  late final Dio _refreshDio;
  final TokenStore _tokenStore;
  final SessionExpiredCallback? _onSessionExpired;

  Dio get dio => _dio;

  Future<HealthStatus> getHealth() async {
    final payload = await getMap('/health');
    return HealthStatus.fromJson(payload);
  }

  Future<Map<String, dynamic>> getMap(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );

      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      throw _toApiError(error);
    }
  }

  Future<Object?> getObject(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
      );

      return response.data;
    } on DioException catch (error) {
      throw _toApiError(error);
    }
  }

  Future<Map<String, dynamic>> postMap(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      throw _toApiError(error);
    }
  }

  Future<List<dynamic>> postList(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post<List<dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return response.data ?? <dynamic>[];
    } on DioException catch (error) {
      throw _toApiError(error);
    }
  }

  Future<List<dynamic>> patchList(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.patch<List<dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return response.data ?? <dynamic>[];
    } on DioException catch (error) {
      throw _toApiError(error);
    }
  }

  Future<Map<String, dynamic>> patchMap(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      throw _toApiError(error);
    }
  }

  Future<List<dynamic>> getList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        path,
        queryParameters: queryParameters,
      );

      return response.data ?? <dynamic>[];
    } on DioException catch (error) {
      throw _toApiError(error);
    }
  }

  void _applyBaseOptions(Dio client, BaseOptions baseOptions) {
    final mergedHeaders = <String, dynamic>{
      ...client.options.headers,
      ...baseOptions.headers,
    };

    client.options = client.options.copyWith(
      baseUrl: baseOptions.baseUrl,
      connectTimeout: baseOptions.connectTimeout,
      receiveTimeout: baseOptions.receiveTimeout,
      sendTimeout: baseOptions.sendTimeout,
      headers: mergedHeaders,
    );
  }

  ApiError _toApiError(DioException error) {
    final inner = error.error;
    if (inner is ApiError) {
      return inner;
    }

    return ApiError.fromDioException(error);
  }
}

class AuthRefreshInterceptor extends Interceptor {
  AuthRefreshInterceptor({
    required Dio dio,
    required Dio refreshDio,
    required TokenStore tokenStore,
    SessionExpiredCallback? onSessionExpired,
  }) : _dio = dio,
       _refreshDio = refreshDio,
       _tokenStore = tokenStore,
       _onSessionExpired = onSessionExpired;

  static const String _retriedKey = 'auth_retried';
  static const String _refreshPath = '/auth/refresh';

  final Dio _dio;
  final Dio _refreshDio;
  final TokenStore _tokenStore;
  final SessionExpiredCallback? _onSessionExpired;
  Completer<bool>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _tokenStore.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers[_authorizationHeader] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;
    final isRefreshRequest = _isRefreshRequest(err.requestOptions);

    if (!isUnauthorized || alreadyRetried || isRefreshRequest) {
      handler.next(err);
      return;
    }

    final refreshed = await _attemptTokenRefresh();
    if (!refreshed) {
      await _tokenStore.clearAll();
      if (_onSessionExpired != null) {
        await _onSessionExpired();
      }

      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: DioExceptionType.badResponse,
          error: const ApiError(
            type: ApiErrorType.sessionExpired,
            message: 'Session expired. Please log in again.',
          ),
        ),
      );
      return;
    }

    final retryHeaders = <String, dynamic>{...err.requestOptions.headers};
    retryHeaders.remove(_authorizationHeader);

    final retryRequest = err.requestOptions.copyWith(
      headers: retryHeaders,
      extra: <String, dynamic>{...err.requestOptions.extra, _retriedKey: true},
    );

    try {
      final response = await _dio.fetch<dynamic>(retryRequest);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _isRefreshRequest(RequestOptions options) {
    return options.path.endsWith(_refreshPath) ||
        options.uri.path.endsWith(_refreshPath);
  }

  Future<bool> _attemptTokenRefresh() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final refreshToken = await _tokenStore.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        _refreshCompleter!.complete(false);
        return false;
      }

      final response = await _refreshDio.post<Map<String, dynamic>>(
        _refreshPath,
        data: <String, dynamic>{'refreshToken': refreshToken},
      );

      final data = response.data;
      final accessToken = data?['accessToken'];
      final rotatedRefreshToken = data?['refreshToken'];
      final user = data?['user'];

      String? userId;
      if (user is Map<String, dynamic>) {
        final id = user['id'];
        if (id is String && id.isNotEmpty) {
          userId = id;
        }
      }

      if (accessToken is! String || rotatedRefreshToken is! String) {
        _refreshCompleter!.complete(false);
        return false;
      }

      await _tokenStore.saveSession(
        accessToken: accessToken,
        refreshToken: rotatedRefreshToken,
        userId: userId,
        issuedAt: DateTime.now().toUtc(),
      );

      _refreshCompleter!.complete(true);
      return true;
    } catch (_) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      final current = _refreshCompleter;
      Future<void>.microtask(() {
        if (identical(current, _refreshCompleter)) {
          _refreshCompleter = null;
        }
      });
    }
  }
}
