import 'package:flutter/material.dart';

import '../../../shared/kit/kit.dart';
import '../widgets/settings_list.dart';

class DataPrivacySettingsScreen extends StatelessWidget {
  const DataPrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return KitScaffold(
      appBar: const KitAppBar(title: 'Data & Privacy', showAvatar: false),
      child: ListView(
        children: [
          SettingsListCard(
            children: [
              SettingsNavRow(
                title: 'Download my data',
                icon: Icons.download_rounded,
                onTap: () =>
                    _showSnack(context, 'Data export is not available yet.'),
                showDivider: false,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SettingsListCard(
            children: [
              SettingsNavRow(
                title: 'Terms',
                icon: Icons.description_outlined,
                onTap: () =>
                    _showSnack(context, 'Terms are not available yet.'),
              ),
              SettingsNavRow(
                title: 'Privacy policy',
                icon: Icons.privacy_tip_outlined,
                onTap: () =>
                    _showSnack(context, 'Privacy policy is not available yet.'),
                showDivider: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}
