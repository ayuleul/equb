import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../kit/kit.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions,
    this.padding,
    this.floatingActionButton,
    this.backgroundColor,
    this.useSafeArea = true,
    this.extendBodyBehindAppBar = false,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool useSafeArea;
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    return KitScaffold(
      title: title,
      actions: actions,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      useSafeArea: useSafeArea,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: KitAppBar(title: title, actions: actions, centerTitle: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Expanded(child: child),
        ],
      ),
    );
  }
}
