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
                onTap: () => _showSnack(
                  context,
                  'Data export request was received. This flow will be connected to backend export.',
                ),
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
                onTap: () => _showSnack(
                  context,
                  'Terms will be available in a dedicated web view.',
                ),
              ),
              SettingsNavRow(
                title: 'Privacy policy',
                icon: Icons.privacy_tip_outlined,
                onTap: () => _showSnack(
                  context,
                  'Privacy policy will be available in a dedicated web view.',
                ),
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
