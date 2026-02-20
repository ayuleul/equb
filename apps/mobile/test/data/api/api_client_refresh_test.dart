import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/api/api_client.dart';
import 'package:mobile/data/auth/token_store.dart';

void main() {
  group('AuthRefreshInterceptor', () {
    test('refreshes once and retries original request', () async {
      final tokenStore = TokenStore(_InMemorySecureStore());
      await tokenStore.saveSession(
        accessToken: 'expired-access',
        refreshToken: 'refresh-token-1',
        userId: 'user-1',
      );

      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      final refreshDio = Dio(BaseOptions(baseUrl: 'https://example.test'));

      var refreshCalls = 0;
      var protectedCalls = 0;

      refreshDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            refreshCalls += 1;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{
                  'accessToken': 'fresh-access',
                  'refreshToken': 'refresh-token-2',
                  'user': <String, dynamic>{
                    'id': 'user-1',
                    'phone': '+251911223344',
                    'fullName': null,
                  },
                },
              ),
            );
          },
        ),
      );

      dio.interceptors.add(
        AuthRefreshInterceptor(
          dio: dio,
          refreshDio: refreshDio,
          tokenStore: tokenStore,
        ),
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == '/protected') {
              protectedCalls += 1;
              final authorization = options.headers['Authorization'];
              if (authorization == 'Bearer fresh-access') {
                handler.resolve(
                  Response<Map<String, dynamic>>(
                    requestOptions: options,
                    statusCode: 200,
                    data: <String, dynamic>{'ok': true},
                  ),
                );
                return;
              }

              handler.reject(
                DioException(
                  requestOptions: options,
                  response: Response<Map<String, dynamic>>(
                    requestOptions: options,
                    statusCode: 401,
                    data: <String, dynamic>{'message': 'Unauthorized'},
                  ),
                  type: DioExceptionType.badResponse,
                ),
                true,
              );
              return;
            }

            handler.next(options);
          },
        ),
      );

      final response = await dio.get<Map<String, dynamic>>('/protected');

      expect(response.data?['ok'], isTrue);
      expect(protectedCalls, 2);
      expect(refreshCalls, 1);
      expect(await tokenStore.getAccessToken(), 'fresh-access');
      expect(await tokenStore.getRefreshToken(), 'refresh-token-2');
    });

    test('does not refresh more than once per failed request', () async {
      final tokenStore = TokenStore(_InMemorySecureStore());
      await tokenStore.saveSession(
        accessToken: 'expired-access',
        refreshToken: 'refresh-token-1',
      );

      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      final refreshDio = Dio(BaseOptions(baseUrl: 'https://example.test'));

      var refreshCalls = 0;

      refreshDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            refreshCalls += 1;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: <String, dynamic>{
                  'accessToken': 'fresh-access',
                  'refreshToken': 'refresh-token-2',
                  'user': <String, dynamic>{
                    'id': 'user-1',
                    'phone': '+251911223344',
                    'fullName': null,
                  },
                },
              ),
            );
          },
        ),
      );

      dio.interceptors.add(
        AuthRefreshInterceptor(
          dio: dio,
          refreshDio: refreshDio,
          tokenStore: tokenStore,
        ),
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response<Map<String, dynamic>>(
                  requestOptions: options,
                  statusCode: 401,
                  data: <String, dynamic>{'message': 'Unauthorized'},
                ),
                type: DioExceptionType.badResponse,
              ),
              true,
            );
          },
        ),
      );

      await expectLater(
        () => dio.get<Map<String, dynamic>>('/protected'),
        throwsA(isA<DioException>()),
      );

      expect(refreshCalls, 1);
    });
  });
}

class _InMemorySecureStore implements SecureKeyValueStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<String?> read(String key) async {
    return _values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }
}
