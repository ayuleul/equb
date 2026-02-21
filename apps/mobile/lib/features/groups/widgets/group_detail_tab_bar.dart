import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_spacing.dart';

enum GroupDetailTab { members, cycles, payoutOrder }

class GroupDetailTabBar extends StatelessWidget {
  const GroupDetailTabBar({
    super.key,
    required this.selectedTab,
    required this.isAdmin,
    required this.onSelected,
  });

  final GroupDetailTab selectedTab;
  final bool isAdmin;
  final ValueChanged<GroupDetailTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = <_GroupDetailTabItem>[
      _GroupDetailTabItem(
        tab: GroupDetailTab.members,
        label: 'Members',
        isSelected: selectedTab == GroupDetailTab.members,
      ),
      _GroupDetailTabItem(
        tab: GroupDetailTab.cycles,
        label: 'Cycles',
        isSelected: selectedTab == GroupDetailTab.cycles,
      ),
      _GroupDetailTabItem(
        tab: GroupDetailTab.payoutOrder,
        label: 'Payout',
        isSelected: selectedTab == GroupDetailTab.payoutOrder,
        enabled: isAdmin,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              _GroupDetailTabButton(item: items[i], onSelected: onSelected),
              if (i != items.length - 1) const SizedBox(width: AppSpacing.xs),
            ],
          ],
        ),
      ),
    );
  }
}

class _GroupDetailTabItem {
  const _GroupDetailTabItem({
    required this.tab,
    required this.label,
    required this.isSelected,
    this.enabled = true,
  });

  final GroupDetailTab tab;
  final String label;
  final bool isSelected;
  final bool enabled;
}

class _GroupDetailTabButton extends StatelessWidget {
  const _GroupDetailTabButton({required this.item, required this.onSelected});

  final _GroupDetailTabItem item;
  final ValueChanged<GroupDetailTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = item.isSelected
        ? colorScheme.onPrimary
        : item.enabled
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;
    final background = item.isSelected
        ? colorScheme.primary
        : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        key: ValueKey('group-tab-${item.tab.name}'),
        onTap: item.enabled
            ? () {
                HapticFeedback.selectionClick();
                onSelected(item.tab);
              }
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            item.label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
