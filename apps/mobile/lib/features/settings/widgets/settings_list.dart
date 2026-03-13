import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../shared/kit/kit.dart';

class SettingsListCard extends StatelessWidget {
  const SettingsListCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return KitCard(child: Column(children: children));
  }
}

class SettingsNavRow extends StatelessWidget {
  const SettingsNavRow({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.showDivider = true,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final tile = Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs, top: AppSpacing.xs),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );

    if (!showDivider) {
      return tile;
    }

    return Column(children: [tile, const Divider(height: 1)]);
  }
}

class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final tile = Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs, top: AppSpacing.xs),
      child: SwitchListTile.adaptive(
        title: Text(title),
        value: value,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        onChanged: onChanged,
      ),
    );

    if (!showDivider) {
      return tile;
    }

    return Column(children: [tile, const Divider(height: 1)]);
  }
}

class SettingsActionRow extends StatelessWidget {
  const SettingsActionRow({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.showDivider = true,
    this.isDestructive = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool showDivider;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Theme.of(context).colorScheme.error : null;
    final tile = Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs, top: AppSpacing.xs),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: color == null ? null : TextStyle(color: color),
        ),
        onTap: onTap,
      ),
    );

    if (!showDivider) {
      return tile;
    }

    return Column(children: [tile, const Divider(height: 1)]);
  }
}
