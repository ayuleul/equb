import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../data/settings/settings_local_store.dart';

final settingsPreferencesControllerProvider =
    StateNotifierProvider<
      SettingsPreferencesController,
      SettingsPreferencesState
    >((ref) {
      final localStore = ref.watch(settingsLocalStoreProvider);
      final controller = SettingsPreferencesController(localStore);
      controller.initialize();
      return controller;
    });

class SettingsPreferencesController
    extends StateNotifier<SettingsPreferencesState> {
  SettingsPreferencesController(this._localStore)
    : super(const SettingsPreferencesState());

  final SettingsLocalStore _localStore;
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
    final prefs = await _localStore.readNotificationPreferences();
    state = state.copyWith(
      initialized: true,
      lotteryWinnerAlerts: prefs.lotteryWinnerAlerts,
      contributionDueReminders: prefs.contributionDueReminders,
      lateAlerts: prefs.lateAlerts,
      disputeUpdates: prefs.disputeUpdates,
      payoutNotifications: prefs.payoutNotifications,
    );
    _initializeFuture = null;
  }

  Future<void> setLotteryWinnerAlerts(bool enabled) async {
    await _localStore.writeLotteryWinnerAlerts(enabled);
    state = state.copyWith(lotteryWinnerAlerts: enabled);
  }

  Future<void> setContributionDueReminders(bool enabled) async {
    await _localStore.writeContributionDueReminders(enabled);
    state = state.copyWith(contributionDueReminders: enabled);
  }

  Future<void> setLateAlerts(bool enabled) async {
    await _localStore.writeLateAlerts(enabled);
    state = state.copyWith(lateAlerts: enabled);
  }

  Future<void> setDisputeUpdates(bool enabled) async {
    await _localStore.writeDisputeUpdates(enabled);
    state = state.copyWith(disputeUpdates: enabled);
  }

  Future<void> setPayoutNotifications(bool enabled) async {
    await _localStore.writePayoutNotifications(enabled);
    state = state.copyWith(payoutNotifications: enabled);
  }
}

@immutable
class SettingsPreferencesState {
  const SettingsPreferencesState({
    this.initialized = false,
    this.lotteryWinnerAlerts = true,
    this.contributionDueReminders = true,
    this.lateAlerts = true,
    this.disputeUpdates = true,
    this.payoutNotifications = true,
  });

  final bool initialized;
  final bool lotteryWinnerAlerts;
  final bool contributionDueReminders;
  final bool lateAlerts;
  final bool disputeUpdates;
  final bool payoutNotifications;

  SettingsPreferencesState copyWith({
    bool? initialized,
    bool? lotteryWinnerAlerts,
    bool? contributionDueReminders,
    bool? lateAlerts,
    bool? disputeUpdates,
    bool? payoutNotifications,
  }) {
    return SettingsPreferencesState(
      initialized: initialized ?? this.initialized,
      lotteryWinnerAlerts: lotteryWinnerAlerts ?? this.lotteryWinnerAlerts,
      contributionDueReminders:
          contributionDueReminders ?? this.contributionDueReminders,
      lateAlerts: lateAlerts ?? this.lateAlerts,
      disputeUpdates: disputeUpdates ?? this.disputeUpdates,
      payoutNotifications: payoutNotifications ?? this.payoutNotifications,
    );
  }
}
