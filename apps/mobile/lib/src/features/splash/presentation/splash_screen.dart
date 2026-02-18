import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../debug_health/presentation/debug_health_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const routePath = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goToDebugScreen();
  }

  Future<void> _goToDebugScreen() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) {
      return;
    }

    context.go(DebugHealthScreen.routePath);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups_rounded, size: 56),
            SizedBox(height: 12),
            Text(
              'Equb',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
