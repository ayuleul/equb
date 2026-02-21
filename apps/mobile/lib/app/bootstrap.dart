import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/api_client.dart';
import '../data/auth/auth_api.dart';
import '../data/auth/auth_repository.dart';
import '../data/contributions/contributions_api.dart';
import '../data/contributions/contributions_repository.dart';
import '../data/cycles/cycles_api.dart';
import '../data/cycles/cycles_repository.dart';
import '../data/files/files_api.dart';
import '../data/files/files_repository.dart';
import '../data/groups/groups_api.dart';
import '../data/groups/groups_repository.dart';
import '../data/notifications/device_token_store.dart';
import '../data/notifications/devices_api.dart';
import '../data/notifications/devices_repository.dart';
import '../data/notifications/notifications_api.dart';
import '../data/notifications/notifications_repository.dart';
import '../data/payouts/payouts_api.dart';
import '../data/payouts/payouts_repository.dart';
import '../data/profile/profile_api.dart';
import '../data/profile/profile_repository.dart';
import '../data/auth/token_store.dart';
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
  return TokenStore.fromSecureStorage(storage);
});

final deviceTokenStoreProvider = Provider<DeviceTokenStore>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return DeviceTokenStore.fromSecureStorage(storage);
});

final sessionExpiredProvider = StateProvider<bool>((ref) => false);

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appBootstrapConfigProvider);
  final tokenStore = ref.watch(tokenStoreProvider);
  final logger = ref.watch(appLoggerProvider);

  return ApiClient(
    baseUrl: config.apiBaseUrl,
    timeout: config.apiTimeout,
    tokenStore: tokenStore,
    onSessionExpired: () {
      logger.info('Session expired after refresh failure. Routing to /login.');
      ref.read(sessionExpiredProvider.notifier).state = true;
    },
  );
});

final authApiProvider = Provider<AuthApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthApi(apiClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authApi = ref.watch(authApiProvider);
  final profileApi = ref.watch(profileApiProvider);
  final tokenStore = ref.watch(tokenStoreProvider);
  return AuthRepository(
    authApi: authApi,
    profileApi: profileApi,
    tokenStore: tokenStore,
  );
});

final profileApiProvider = Provider<ProfileApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DioProfileApi(apiClient);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final profileApi = ref.watch(profileApiProvider);
  return ProfileRepository(profileApi);
});

final groupsApiProvider = Provider<GroupsApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DioGroupsApi(apiClient);
});

final groupsRepositoryProvider = Provider<GroupsRepository>((ref) {
  final groupsApi = ref.watch(groupsApiProvider);
  return GroupsRepository(groupsApi);
});

final cyclesApiProvider = Provider<CyclesApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DioCyclesApi(apiClient);
});

final cyclesRepositoryProvider = Provider<CyclesRepository>((ref) {
  final cyclesApi = ref.watch(cyclesApiProvider);
  return CyclesRepository(cyclesApi);
});

final contributionsApiProvider = Provider<ContributionsApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DioContributionsApi(apiClient);
});

final contributionsRepositoryProvider = Provider<ContributionsRepository>((
  ref,
) {
  final api = ref.watch(contributionsApiProvider);
  return ContributionsRepository(api);
});

final filesApiProvider = Provider<FilesApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DioFilesApi(apiClient);
});

final filesRepositoryProvider = Provider<FilesRepository>((ref) {
  final config = ref.watch(appBootstrapConfigProvider);
  final api = ref.watch(filesApiProvider);
  return FilesRepository(api, timeout: config.apiTimeout);
});

final payoutsApiProvider = Provider<PayoutsApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DioPayoutsApi(apiClient);
});

final payoutsRepositoryProvider = Provider<PayoutsRepository>((ref) {
  final api = ref.watch(payoutsApiProvider);
  return PayoutsRepository(api);
});

final devicesApiProvider = Provider<DevicesApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DioDevicesApi(apiClient);
});

final devicesRepositoryProvider = Provider<DevicesRepository>((ref) {
  final api = ref.watch(devicesApiProvider);
  return DevicesRepository(api);
});

final notificationsApiProvider = Provider<NotificationsApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DioNotificationsApi(apiClient);
});

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  final api = ref.watch(notificationsApiProvider);
  return NotificationsRepository(api);
});
