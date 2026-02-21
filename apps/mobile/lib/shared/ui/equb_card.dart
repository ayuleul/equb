import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../kit/kit.dart';

class EqubCard extends StatelessWidget {
  const EqubCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return KitCard(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: child,
    );
  }
}
