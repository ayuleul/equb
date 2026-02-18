import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import 'health_repository.dart';
import 'health_response.dart';

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HealthRepository(apiClient);
});

final healthStatusProvider = FutureProvider<HealthResponse>((ref) {
  final repository = ref.watch(healthRepositoryProvider);
  return repository.getHealth();
});
