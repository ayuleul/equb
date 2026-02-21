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
      padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      useSafeArea: useSafeArea,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: KitAppBar(title: title, subtitle: subtitle, actions: actions),
      child: child,
    );
  }
}
