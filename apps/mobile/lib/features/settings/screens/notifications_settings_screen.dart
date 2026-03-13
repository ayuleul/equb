import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/kit/kit.dart';
import '../settings_preferences_controller.dart';
import '../widgets/settings_list.dart';

class NotificationsSettingsScreen extends ConsumerWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsPreferencesControllerProvider);
    final notifier = ref.read(settingsPreferencesControllerProvider.notifier);

    return KitScaffold(
      appBar: const KitAppBar(title: 'Notifications', showAvatar: false),
      child: ListView(
        children: [
          SettingsListCard(
            children: [
              SettingsSwitchRow(
                title: 'Lottery winner alerts',
                value: state.lotteryWinnerAlerts,
                onChanged: (value) => notifier.setLotteryWinnerAlerts(value),
              ),
              SettingsSwitchRow(
                title: 'Payout notifications',
                value: state.payoutNotifications,
                onChanged: (value) => notifier.setPayoutNotifications(value),
              ),
              SettingsSwitchRow(
                title: 'Dispute updates',
                value: state.disputeUpdates,
                onChanged: (value) => notifier.setDisputeUpdates(value),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SettingsListCard(
            children: [
              SettingsSwitchRow(
                title: 'Contribution due reminders',
                value: state.contributionDueReminders,
                onChanged: (value) =>
                    notifier.setContributionDueReminders(value),
              ),
              SettingsSwitchRow(
                title: 'Late alerts',
                value: state.lateAlerts,
                onChanged: (value) => notifier.setLateAlerts(value),
                showDivider: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
