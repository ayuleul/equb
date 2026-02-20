import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Equbs',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onDestinationSelected: (index) {
          if (index == navigationShell.currentIndex) {
            final location = switch (index) {
              0 => AppRoutePaths.home,
              1 => AppRoutePaths.groups,
              _ => AppRoutePaths.settings,
            };
            context.go(location);
            return;
          }

          navigationShell.goBranch(index, initialLocation: false);
        },
      ),
    );
  }
}
