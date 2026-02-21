import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

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
    const contentHeight = 72.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Material(
        color: colorScheme.surface,
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
  static const double _selectedSize = 52;
  static const double _unselectedSize = 48;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final inactiveColor = colorScheme.outline;

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
          borderRadius: BorderRadius.circular(26),
          splashColor: Colors.transparent,
          highlightColor: colorScheme.primary.withValues(alpha: 0.05),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              width: selected ? _selectedSize : _unselectedSize,
              height: selected ? _selectedSize : _unselectedSize,
              decoration: BoxDecoration(
                color: selected ? colorScheme.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                selected ? item.selectedIcon : item.icon,
                size: selected ? 28 : 30,
                color: selected ? colorScheme.onPrimary : inactiveColor,
              ),
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
