import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/kit/kit.dart';
import '../settings_preferences_controller.dart';

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
          KitCard(
            child: Column(
              children: [
                _SettingSwitchTile(
                  title: 'Lottery winner alerts',
                  value: state.lotteryWinnerAlerts,
                  onChanged: (value) => notifier.setLotteryWinnerAlerts(value),
                ),
                _SettingSwitchTile(
                  title: 'Contribution due reminders',
                  value: state.contributionDueReminders,
                  onChanged: (value) =>
                      notifier.setContributionDueReminders(value),
                ),
                _SettingSwitchTile(
                  title: 'Late alerts',
                  value: state.lateAlerts,
                  onChanged: (value) => notifier.setLateAlerts(value),
                ),
                _SettingSwitchTile(
                  title: 'Dispute updates',
                  value: state.disputeUpdates,
                  onChanged: (value) => notifier.setDisputeUpdates(value),
                ),
                _SettingSwitchTile(
                  title: 'Payout notifications',
                  value: state.payoutNotifications,
                  onChanged: (value) => notifier.setPayoutNotifications(value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingSwitchTile extends StatelessWidget {
  const _SettingSwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: SwitchListTile.adaptive(
        title: Text(title),
        value: value,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        onChanged: onChanged,
      ),
    );
  }
}
