import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../app/bootstrap.dart';
import '../../data/settings/settings_local_store.dart';

final appLockControllerProvider =
    StateNotifierProvider<AppLockController, AppLockState>((ref) {
      final store = ref.watch(settingsLocalStoreProvider);
      final localAuthentication = ref.watch(localAuthenticationProvider);
      return AppLockController(
        store: store,
        localAuthentication: localAuthentication,
      );
    });

class AppLockController extends StateNotifier<AppLockState> {
  AppLockController({
    required SettingsLocalStore store,
    required LocalAuthentication localAuthentication,
  }) : _store = store,
       _localAuthentication = localAuthentication,
       super(const AppLockState());

  final SettingsLocalStore _store;
  final LocalAuthentication _localAuthentication;

  Future<void>? _initializeFuture;

  Future<void> initialize() {
    final inFlight = _initializeFuture;
    if (inFlight != null) {
      return inFlight;
    }
    final task = _runInitialize();
    _initializeFuture = task;
    return task;
  }

  Future<void> _runInitialize() async {
    final biometricAvailable = await _checkBiometricAvailability();
    final lockTimeoutSeconds = await _store.readLockTimeoutSeconds();
    final storedEnabled = await _store.readBiometricEnabled();
    final biometricEnabled = biometricAvailable ? storedEnabled : false;

    if (storedEnabled && !biometricAvailable) {
      await _store.writeBiometricEnabled(false);
    }

    state = state.copyWith(
      initialized: true,
      biometricAvailable: biometricAvailable,
      biometricEnabled: biometricEnabled,
      lockTimeoutSeconds: lockTimeoutSeconds,
      isLocked: biometricEnabled,
      clearError: true,
    );

    if (biometricEnabled) {
      unawaited(unlockWithBiometrics());
    }

    _initializeFuture = null;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final biometricAvailable = await _checkBiometricAvailability();
    if (enabled && !biometricAvailable) {
      state = state.copyWith(
        biometricAvailable: biometricAvailable,
        biometricEnabled: false,
      );
      await _store.writeBiometricEnabled(false);
      return;
    }

    await _store.writeBiometricEnabled(enabled);
    state = state.copyWith(
      biometricAvailable: biometricAvailable,
      biometricEnabled: enabled,
      isLocked: enabled ? true : false,
      clearError: true,
    );

    if (enabled) {
      unawaited(unlockWithBiometrics());
    }
  }

  Future<void> setLockTimeoutSeconds(int seconds) async {
    await _store.writeLockTimeoutSeconds(seconds);
    state = state.copyWith(lockTimeoutSeconds: seconds);
  }

  void handleLifecycleChange(AppLifecycleState lifecycleState) {
    if (!state.initialized || !state.biometricEnabled) {
      return;
    }

    switch (lifecycleState) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        state = state.copyWith(lastBackgroundedAt: DateTime.now());
        return;
      case AppLifecycleState.resumed:
        final lastBackgroundedAt = state.lastBackgroundedAt;
        if (lastBackgroundedAt == null || state.isLocked) {
          return;
        }
        final elapsed = DateTime.now().difference(lastBackgroundedAt);
        final shouldLock =
            state.lockTimeoutSeconds == 0 ||
            elapsed.inSeconds >= state.lockTimeoutSeconds;
        if (!shouldLock) {
          return;
        }
        state = state.copyWith(isLocked: true, clearError: true);
        unawaited(unlockWithBiometrics());
    }
  }

  Future<void> unlockWithBiometrics() async {
    if (!state.biometricEnabled ||
        state.isAuthenticating ||
        !state.biometricAvailable) {
      return;
    }

    state = state.copyWith(isAuthenticating: true, clearError: true);

    try {
      final authenticated = await _localAuthentication.authenticate(
        localizedReason: 'Unlock Equb with biometrics',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: false,
        ),
      );

      if (authenticated) {
        state = state.copyWith(
          isLocked: false,
          isAuthenticating: false,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          isLocked: true,
          isAuthenticating: false,
          errorMessage: 'Authentication failed. Please try again.',
        );
      }
    } catch (_) {
      state = state.copyWith(
        isLocked: true,
        isAuthenticating: false,
        errorMessage: 'Biometric authentication is required to continue.',
      );
    }
  }

  Future<bool> _checkBiometricAvailability() async {
    if (kIsWeb) {
      return false;
    }

    try {
      final canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
      final isDeviceSupported = await _localAuthentication.isDeviceSupported();
      if (!canCheckBiometrics || !isDeviceSupported) {
        return false;
      }

      final availableBiometrics = await _localAuthentication
          .getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

@immutable
class AppLockState {
  const AppLockState({
    this.initialized = false,
    this.biometricEnabled = false,
    this.biometricAvailable = false,
    this.lockTimeoutSeconds = SettingsLocalStore.defaultLockTimeoutSeconds,
    this.isLocked = false,
    this.isAuthenticating = false,
    this.errorMessage,
    this.lastBackgroundedAt,
  });

  final bool initialized;
  final bool biometricEnabled;
  final bool biometricAvailable;
  final int lockTimeoutSeconds;
  final bool isLocked;
  final bool isAuthenticating;
  final String? errorMessage;
  final DateTime? lastBackgroundedAt;

  AppLockState copyWith({
    bool? initialized,
    bool? biometricEnabled,
    bool? biometricAvailable,
    int? lockTimeoutSeconds,
    bool? isLocked,
    bool? isAuthenticating,
    String? errorMessage,
    DateTime? lastBackgroundedAt,
    bool clearError = false,
  }) {
    return AppLockState(
      initialized: initialized ?? this.initialized,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      lockTimeoutSeconds: lockTimeoutSeconds ?? this.lockTimeoutSeconds,
      isLocked: isLocked ?? this.isLocked,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastBackgroundedAt: lastBackgroundedAt ?? this.lastBackgroundedAt,
    );
  }
}
