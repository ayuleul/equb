import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../logging/app_logger.dart';
import '../network/api_client.dart';
import '../storage/token_store.dart';

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
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

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final tokenStore = ref.watch(tokenStoreProvider);
  final logger = ref.watch(appLoggerProvider);

  return ApiClient(
    baseUrl: config.apiBaseUrl,
    tokenStore: tokenStore,
    logger: logger,
  );
});
