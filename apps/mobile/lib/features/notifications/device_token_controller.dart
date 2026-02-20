import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/models/register_device_token_request.dart';
import '../../data/notifications/device_token_store.dart';
import '../../data/notifications/devices_repository.dart';
import '../../shared/utils/api_error_mapper.dart';
import 'notification_bootstrap_service.dart';

class DeviceTokenState {
  const DeviceTokenState({
    required this.isSyncing,
    this.lastRegisteredToken,
    this.errorMessage,
  });

  const DeviceTokenState.initial() : this(isSyncing: false);

  final bool isSyncing;
  final String? lastRegisteredToken;
  final String? errorMessage;

  DeviceTokenState copyWith({
    bool? isSyncing,
    String? lastRegisteredToken,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DeviceTokenState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastRegisteredToken: lastRegisteredToken ?? this.lastRegisteredToken,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final deviceTokenControllerProvider =
    StateNotifierProvider<DeviceTokenController, DeviceTokenState>((ref) {
      final devicesRepository = ref.watch(devicesRepositoryProvider);
      final tokenStore = ref.watch(deviceTokenStoreProvider);
      final notificationBootstrap = ref.watch(notificationBootstrapProvider);

      return DeviceTokenController(
        devicesRepository: devicesRepository,
        deviceTokenStore: tokenStore,
        notificationBootstrap: notificationBootstrap,
      );
    });

class DeviceTokenController extends StateNotifier<DeviceTokenState> {
  DeviceTokenController({
    required DevicesRepository devicesRepository,
    required DeviceTokenStore deviceTokenStore,
    required NotificationBootstrap notificationBootstrap,
  }) : _devicesRepository = devicesRepository,
       _deviceTokenStore = deviceTokenStore,
       _notificationBootstrap = notificationBootstrap,
       super(const DeviceTokenState.initial());

  final DevicesRepository _devicesRepository;
  final DeviceTokenStore _deviceTokenStore;
  final NotificationBootstrap _notificationBootstrap;
  Future<void>? _syncInFlight;

  Future<void> syncTokenForUser(String userId) {
    final inFlight = _syncInFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final task = _sync(userId);
    _syncInFlight = task;
    task.whenComplete(() => _syncInFlight = null);
    return task;
  }

  Future<void> registerTokenIfChanged({
    required String userId,
    required String token,
  }) async {
    final normalized = token.trim();
    if (normalized.isEmpty) {
      return;
    }

    await _registerIfChanged(userId: userId, token: normalized);
  }

  Future<void> _sync(String userId) async {
    state = state.copyWith(isSyncing: true, clearError: true);

    try {
      final token = await _notificationBootstrap.getDeviceToken();
      if (token == null || token.isEmpty) {
        state = state.copyWith(isSyncing: false, clearError: true);
        return;
      }

      await _registerIfChanged(userId: userId, token: token);
      state = state.copyWith(isSyncing: false, clearError: true);
    } catch (error) {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: mapApiErrorToMessage(error),
      );
    }
  }

  Future<void> _registerIfChanged({
    required String userId,
    required String token,
  }) async {
    final cachedToken = await _deviceTokenStore.getLastRegisteredToken();
    final cachedUserId = await _deviceTokenStore.getLastRegisteredUserId();

    if (cachedToken == token && cachedUserId == userId) {
      state = state.copyWith(lastRegisteredToken: token, clearError: true);
      return;
    }

    await _devicesRepository.registerToken(
      token: token,
      platform: currentDevicePlatform(),
    );

    await _deviceTokenStore.saveRegistration(token: token, userId: userId);
    state = state.copyWith(lastRegisteredToken: token, clearError: true);
  }
}
