import 'package:flutter/material.dart';

import '../kit/kit.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.ctaLabel,
    this.onCtaPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;

  @override
  Widget build(BuildContext context) {
    return KitEmptyState(
      icon: icon,
      title: title,
      message: message,
      ctaLabel: ctaLabel,
      onCtaPressed: onCtaPressed,
    );
  }
}
