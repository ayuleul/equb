import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/api_client.dart';
import '../data/api/auth_interceptor.dart';
import '../data/api/token_store.dart';
import '../shared/utils/app_logger.dart';

class AppBootstrapConfig {
  const AppBootstrapConfig({
    required this.apiBaseUrl,
    required this.apiTimeoutMs,
  });

  final String apiBaseUrl;
  final int apiTimeoutMs;

  Duration get apiTimeout => Duration(milliseconds: apiTimeoutMs);

  static Future<AppBootstrapConfig> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (error) {
      throw StateError(
        'Could not load apps/mobile/.env. Copy .env.example to .env. ($error)',
      );
    }

    return fromMap(dotenv.env);
  }

  static AppBootstrapConfig fromMap(Map<String, String> env) {
    final apiBaseUrl = (env['API_BASE_URL'] ?? '').trim();
    if (apiBaseUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL is missing in .env. Example: API_BASE_URL=http://localhost:3000',
      );
    }

    final timeoutRaw = (env['API_TIMEOUT_MS'] ?? '15000').trim();
    final parsedTimeout = int.tryParse(timeoutRaw);
    if (parsedTimeout == null || parsedTimeout <= 0) {
      throw StateError(
        'API_TIMEOUT_MS must be a positive integer. Got: $timeoutRaw',
      );
    }

    return AppBootstrapConfig(
      apiBaseUrl: apiBaseUrl,
      apiTimeoutMs: parsedTimeout,
    );
  }
}

final appBootstrapConfigProvider = Provider<AppBootstrapConfig>((ref) {
  throw UnimplementedError('AppBootstrapConfig must be overridden in main().');
});

final appLoggerProvider = Provider<AppLogger>((ref) {
  return const AppLogger();
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final tokenStoreProvider = Provider<TokenStore>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return TokenStore(storage);
});

final sessionExpiredProvider = StateProvider<bool>((ref) => false);

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appBootstrapConfigProvider);
  final tokenStore = ref.watch(tokenStoreProvider);
  final logger = ref.watch(appLoggerProvider);

  final baseOptions = BaseOptions(
    baseUrl: config.apiBaseUrl,
    connectTimeout: config.apiTimeout,
    receiveTimeout: config.apiTimeout,
    sendTimeout: config.apiTimeout,
    headers: {
      Headers.contentTypeHeader: Headers.jsonContentType,
      Headers.acceptHeader: Headers.jsonContentType,
    },
  );

  final dio = Dio(baseOptions);
  final refreshDio = Dio(baseOptions);

  dio.interceptors.add(
    AuthInterceptor(
      dio: dio,
      refreshDio: refreshDio,
      tokenStore: tokenStore,
      onSessionExpired: () async {
        logger.info(
          'Session expired after refresh failure. Routing to /login.',
        );
        ref.read(sessionExpiredProvider.notifier).state = true;
      },
    ),
  );

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});
