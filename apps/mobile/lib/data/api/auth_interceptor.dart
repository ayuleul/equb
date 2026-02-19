import 'dart:async';

import 'package:dio/dio.dart';

import 'api_error.dart';
import 'token_store.dart';

typedef SessionExpiredCallback = FutureOr<void> Function();

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required Dio refreshDio,
    required TokenStore tokenStore,
    required SessionExpiredCallback onSessionExpired,
  }) : _dio = dio,
       _refreshDio = refreshDio,
       _tokenStore = tokenStore,
       _onSessionExpired = onSessionExpired;

  final Dio _dio;
  final Dio _refreshDio;
  final TokenStore _tokenStore;
  final SessionExpiredCallback _onSessionExpired;

  Completer<bool>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _tokenStore.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra['retried'] == true;
    final isRefreshEndpoint = err.requestOptions.path.endsWith('/auth/refresh');

    if (isUnauthorized && !alreadyRetried && !isRefreshEndpoint) {
      final refreshed = await _attemptTokenRefresh();

      if (refreshed) {
        final retryRequest = err.requestOptions.copyWith(
          extra: {...err.requestOptions.extra, 'retried': true},
        );

        try {
          final response = await _dio.fetch<dynamic>(retryRequest);
          handler.resolve(response);
          return;
        } on DioException catch (retryError) {
          handler.next(retryError);
          return;
        }
      }

      await _tokenStore.clearAll();
      await _onSessionExpired();

      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          type: DioExceptionType.badResponse,
          response: err.response,
          error: const ApiError(
            type: ApiErrorType.sessionExpired,
            message: 'Session expired. Please log in again.',
          ),
        ),
      );
      return;
    }

    handler.next(err);
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
        '/auth/refresh',
        data: <String, dynamic>{'refreshToken': refreshToken},
      );

      final data = response.data;
      final accessToken = data?['accessToken'];
      final rotatedRefreshToken = data?['refreshToken'];

      if (accessToken is! String || rotatedRefreshToken is! String) {
        _refreshCompleter!.complete(false);
        return false;
      }

      await _tokenStore.saveTokenPair(
        accessToken: accessToken,
        refreshToken: rotatedRefreshToken,
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
