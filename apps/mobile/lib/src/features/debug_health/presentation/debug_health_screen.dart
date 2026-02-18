import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/api_error.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/primary_button.dart';
import '../data/health_providers.dart';
import '../data/health_response.dart';

class DebugHealthScreen extends ConsumerWidget {
  const DebugHealthScreen({super.key});

  static const routePath = '/debug/health';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Debug Health')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: config.isConfigured
            ? _HealthContent(config: config)
            : const ErrorView(
                message:
                    'API_BASE_URL is missing. Start the app with --dart-define=API_BASE_URL=<url>.',
              ),
      ),
    );
  }
}

class _HealthContent extends ConsumerWidget {
  const _HealthContent({required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncHealth = ref.watch(healthStatusProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('API Base URL', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        SelectableText(config.apiBaseUrl),
        const SizedBox(height: 16),
        Expanded(
          child: asyncHealth.when(
            loading: () => const LoadingView(message: 'Checking /health ...'),
            error: (error, _) => ErrorView(
              message: _readableError(error),
              onRetry: () => ref.invalidate(healthStatusProvider),
            ),
            data: (health) => _HealthSuccessView(
              health: health,
              onRefresh: () => ref.invalidate(healthStatusProvider),
            ),
          ),
        ),
      ],
    );
  }

  String _readableError(Object error) {
    if (error is ApiError) {
      return error.message;
    }

    return 'Unable to load health status. $error';
  }
}

class _HealthSuccessView extends StatelessWidget {
  const _HealthSuccessView({required this.health, required this.onRefresh});

  final HealthResponse health;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd().add_jms();

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Status: ${health.status.toUpperCase()}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('Database: ${health.checks.database}'),
                Text('Redis: ${health.checks.redis}'),
                const SizedBox(height: 8),
                Text(
                  'Timestamp: ${dateFormat.format(health.timestamp.toLocal())}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: PrimaryButton(
            label: 'Refresh Health',
            onPressed: onRefresh,
            icon: Icons.refresh,
          ),
        ),
      ],
    );
  }
}
