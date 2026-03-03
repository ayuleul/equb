import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/kit/kit.dart';

class DataPrivacySettingsScreen extends StatelessWidget {
  const DataPrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return KitScaffold(
      appBar: const KitAppBar(title: 'Data & Privacy', showAvatar: false),
      child: ListView(
        children: [
          KitCard(
            child: Column(
              children: [
                _ActionRow(
                  title: 'Download my data',
                  icon: Icons.download_rounded,
                  onTap: () => _showSnack(
                    context,
                    'Data export request was received. This flow will be connected to backend export.',
                  ),
                ),
                _ActionRow(
                  title: 'Terms',
                  icon: Icons.description_outlined,
                  onTap: () => _showSnack(
                    context,
                    'Terms will be available in a dedicated web view.',
                  ),
                ),
                _ActionRow(
                  title: 'Privacy policy',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () => _showSnack(
                    context,
                    'Privacy policy will be available in a dedicated web view.',
                  ),
                ),
              ],
            ),
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

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
