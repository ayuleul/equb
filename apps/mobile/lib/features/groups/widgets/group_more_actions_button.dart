import 'package:flutter/material.dart';

import '../../../shared/kit/kit.dart';

enum _GroupMoreAction { edit, report, boost, leave }

class GroupMoreActionsButton extends StatelessWidget {
  const GroupMoreActionsButton({
    super.key,
    required this.groupName,
    this.isAdmin = false,
    this.iconColor,
  });

  final String groupName;
  final bool isAdmin;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedIconColor = iconColor ?? colorScheme.onSurfaceVariant;
    final items = <PopupMenuEntry<_GroupMoreAction>>[
      if (isAdmin)
        const PopupMenuItem(
          value: _GroupMoreAction.edit,
          child: _ActionMenuRow(icon: Icons.edit_outlined, label: 'Edit group'),
        ),
      const PopupMenuItem(
        value: _GroupMoreAction.report,
        child: _ActionMenuRow(icon: Icons.flag_outlined, label: 'Report group'),
      ),
      const PopupMenuItem(
        value: _GroupMoreAction.boost,
        child: _ActionMenuRow(
          icon: Icons.rocket_launch_outlined,
          label: 'Boost group',
        ),
      ),
      const PopupMenuItem(
        value: _GroupMoreAction.leave,
        child: _ActionMenuRow(
          icon: Icons.logout_rounded,
          label: 'Leave group',
          isDestructive: true,
        ),
      ),
    ];

    return PopupMenuButton<_GroupMoreAction>(
      tooltip: 'More actions',
      offset: const Offset(0, 10),
      onSelected: (value) => _handleAction(context, value),
      itemBuilder: (context) => items,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Icon(
          Icons.grid_view_rounded,
          color: resolvedIconColor,
          size: 24,
        ),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    _GroupMoreAction action,
  ) async {
    switch (action) {
      case _GroupMoreAction.edit:
        KitToast.info(context, 'Edit group for "$groupName" is coming soon.');
        return;
      case _GroupMoreAction.report:
        final reason = await promptText(
          context: context,
          title: 'Report group',
          label: 'Reason',
          hint: 'Tell us what happened.',
          submitLabel: 'Submit report',
        );
        if (!context.mounted || reason == null || reason.trim().isEmpty) {
          return;
        }
        KitToast.success(context, 'Report submitted for "$groupName".');
        return;
      case _GroupMoreAction.boost:
        KitToast.info(context, 'Boost for "$groupName" is coming soon.');
        return;
      case _GroupMoreAction.leave:
        final confirmed = await KitDialog.confirm(
          context: context,
          title: 'Leave this group?',
          message:
              'You will stop receiving cycle updates for this group until you join again.',
          confirmLabel: 'Leave group',
          isDestructive: true,
        );
        if (!context.mounted || confirmed != true) {
          return;
        }
        KitToast.warning(context, 'Leave group flow will be enabled soon.');
        return;
    }
  }
}

class _ActionMenuRow extends StatelessWidget {
  const _ActionMenuRow({
    required this.icon,
    required this.label,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isDestructive ? colorScheme.error : colorScheme.onSurface;

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
