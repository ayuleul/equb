import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'theme/app_spacing.dart';
import 'router.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    required this.currentLocation,
  });

  final StatefulNavigationShell navigationShell;
  final String currentLocation;

  static const Set<String> _tabRootPaths = {
    AppRoutePaths.home,
    AppRoutePaths.groups,
    AppRoutePaths.settings,
  };
  static const List<_BottomTabItem> _tabs = [
    _BottomTabItem(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      location: AppRoutePaths.home,
    ),
    _BottomTabItem(
      label: 'Equbs',
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups_rounded,
      location: AppRoutePaths.groups,
    ),
    _BottomTabItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      location: AppRoutePaths.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final showBottomNav = _tabRootPaths.contains(_normalized(currentLocation));

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: showBottomNav
          ? _AppBottomBar(
              selectedIndex: navigationShell.currentIndex,
              tabs: _tabs,
              onTabSelected: (index) {
                if (index == navigationShell.currentIndex) {
                  context.go(_tabs[index].location);
                  return;
                }
                navigationShell.goBranch(index, initialLocation: false);
              },
            )
          : null,
    );
  }

  String _normalized(String path) {
    if (path.length > 1 && path.endsWith('/')) {
      return path.substring(0, path.length - 1);
    }
    return path;
  }
}

class _AppBottomBar extends StatelessWidget {
  const _AppBottomBar({
    required this.selectedIndex,
    required this.tabs,
    required this.onTabSelected,
  });

  final int selectedIndex;
  final List<_BottomTabItem> tabs;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    const contentHeight = 76.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorScheme.surface, colorScheme.surfaceContainerLow],
        ),
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          height: contentHeight + bottomInset,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              12,
              8,
              12,
              bottomInset > 0 ? bottomInset : 8,
            ),
            child: Row(
              children: [
                for (var i = 0; i < tabs.length; i++)
                  Expanded(
                    child: _BottomTabButton(
                      item: tabs[i],
                      selected: i == selectedIndex,
                      onPressed: () => onTabSelected(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomTabButton extends StatelessWidget {
  const _BottomTabButton({
    required this.item,
    required this.selected,
    required this.onPressed,
  });

  final _BottomTabItem item;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final inactiveColor = colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: Tooltip(
        message: item.label,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onPressed();
          },
          borderRadius: AppRadius.mdRounded,
          splashColor: Colors.transparent,
          highlightColor: colorScheme.primary.withValues(alpha: 0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdRounded,
              color: selected
                  ? colorScheme.primary.withValues(alpha: 0.14)
                  : Colors.transparent,
              border: Border.all(
                color: selected
                    ? colorScheme.primary.withValues(alpha: 0.35)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: selected ? 1 : 0.94,
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    selected ? item.selectedIcon : item.icon,
                    size: selected ? 23 : 22,
                    color: selected ? colorScheme.primary : inactiveColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: selected ? colorScheme.primary : inactiveColor,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomTabItem {
  const _BottomTabItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.location,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String location;
}
