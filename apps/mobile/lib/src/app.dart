import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/core_providers.dart';
import 'routing/app_router.dart';

class EqubApp extends ConsumerWidget {
  const EqubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);

    if (!config.isConfigured) {
      return MaterialApp(
        title: 'Equb',
        theme: _buildTheme(),
        home: const _ConfigErrorScreen(),
      );
    }

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Equb',
      theme: _buildTheme(),
      routerConfig: router,
    );
  }

  ThemeData _buildTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0D5E56),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF5F7F8),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _ConfigErrorScreen extends StatelessWidget {
  const _ConfigErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equb Configuration')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'API_BASE_URL is not configured. Run the app with '
          '--dart-define=API_BASE_URL=<your-api-url>.',
        ),
      ),
    );
  }
}
