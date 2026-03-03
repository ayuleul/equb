import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsLocalStore {
  SettingsLocalStore(this._storage);

  static const _biometricEnabledKey = 'biometric_enabled';
  static const _lockTimeoutSecondsKey = 'lock_timeout_seconds';
  static const _lotteryAlertsEnabledKey = 'notifications_lottery_winner';
  static const _dueRemindersEnabledKey = 'notifications_due_reminders';
  static const _lateAlertsEnabledKey = 'notifications_late_alerts';
  static const _disputeUpdatesEnabledKey = 'notifications_dispute_updates';
  static const _payoutNotificationsEnabledKey = 'notifications_payouts';

  static const int defaultLockTimeoutSeconds = 30;

  final FlutterSecureStorage _storage;

  Future<bool> readBiometricEnabled() async {
    return _readBool(_biometricEnabledKey, fallback: false);
  }

  Future<void> writeBiometricEnabled(bool enabled) {
    return _writeBool(_biometricEnabledKey, enabled);
  }

  Future<int> readLockTimeoutSeconds() async {
    final raw = await _storage.read(key: _lockTimeoutSecondsKey);
    final parsed = int.tryParse(raw ?? '');
    if (parsed == null || parsed < 0) {
      return defaultLockTimeoutSeconds;
    }
    return parsed;
  }

  Future<void> writeLockTimeoutSeconds(int seconds) async {
    await _storage.write(key: _lockTimeoutSecondsKey, value: '$seconds');
  }

  Future<NotificationPreferences> readNotificationPreferences() async {
    return NotificationPreferences(
      lotteryWinnerAlerts: await _readBool(
        _lotteryAlertsEnabledKey,
        fallback: true,
      ),
      contributionDueReminders: await _readBool(
        _dueRemindersEnabledKey,
        fallback: true,
      ),
      lateAlerts: await _readBool(_lateAlertsEnabledKey, fallback: true),
      disputeUpdates: await _readBool(
        _disputeUpdatesEnabledKey,
        fallback: true,
      ),
      payoutNotifications: await _readBool(
        _payoutNotificationsEnabledKey,
        fallback: true,
      ),
    );
  }

  Future<void> writeLotteryWinnerAlerts(bool enabled) {
    return _writeBool(_lotteryAlertsEnabledKey, enabled);
  }

  Future<void> writeContributionDueReminders(bool enabled) {
    return _writeBool(_dueRemindersEnabledKey, enabled);
  }

  Future<void> writeLateAlerts(bool enabled) {
    return _writeBool(_lateAlertsEnabledKey, enabled);
  }

  Future<void> writeDisputeUpdates(bool enabled) {
    return _writeBool(_disputeUpdatesEnabledKey, enabled);
  }

  Future<void> writePayoutNotifications(bool enabled) {
    return _writeBool(_payoutNotificationsEnabledKey, enabled);
  }

  Future<bool> _readBool(String key, {required bool fallback}) async {
    final raw = await _storage.read(key: key);
    if (raw == null) {
      return fallback;
    }
    return raw.toLowerCase() == 'true';
  }

  Future<void> _writeBool(String key, bool value) {
    return _storage.write(key: key, value: '$value');
  }
}

class NotificationPreferences {
  const NotificationPreferences({
    required this.lotteryWinnerAlerts,
    required this.contributionDueReminders,
    required this.lateAlerts,
    required this.disputeUpdates,
    required this.payoutNotifications,
  });

  final bool lotteryWinnerAlerts;
  final bool contributionDueReminders;
  final bool lateAlerts;
  final bool disputeUpdates;
  final bool payoutNotifications;
}
