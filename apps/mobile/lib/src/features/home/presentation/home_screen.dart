import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../debug_health/presentation/debug_health_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routePath = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equb Home')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: ListTile(
            title: const Text('Debug health endpoint'),
            subtitle: const Text('Phase 0 connectivity check'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.go(DebugHealthScreen.routePath);
            },
          ),
        ),
      ),
    );
  }
}
