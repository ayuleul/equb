import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/bootstrap.dart';
import '../../app/router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Authenticated shell ready.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'Group and cycle screens will be implemented in later phases.',
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                await ref.read(tokenStoreProvider).clearAll();
                ref.read(sessionExpiredProvider.notifier).state = false;
                ref.invalidate(authBootstrapProvider);
                if (context.mounted) {
                  context.go(AppRoutePaths.login);
                }
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
