import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_controller.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class EqubApp extends ConsumerStatefulWidget {
  const EqubApp({super.key});

  @override
  ConsumerState<EqubApp> createState() => _EqubAppState();
}

class _EqubAppState extends ConsumerState<EqubApp> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(authControllerProvider.notifier).bootstrap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Equb',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
