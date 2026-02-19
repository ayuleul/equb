import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';
import '../../app/router.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'OTP login will be implemented in Phase 1.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'Current session state requires authentication. '
              'Use this screen for login flow in the next phase.',
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                ref.read(sessionExpiredProvider.notifier).state = false;
                ref.invalidate(authBootstrapProvider);
              },
              child: const Text('Re-check session'),
            ),
          ],
        ),
      ),
    );
  }
}
