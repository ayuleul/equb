import 'package:flutter/material.dart';

import '../kit/kit.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return KitEmptyState(
      icon: Icons.error_outline,
      title: 'Something went wrong',
      message: message,
      ctaLabel: onRetry == null ? null : 'Retry',
      onCtaPressed: onRetry,
    );
  }
}
