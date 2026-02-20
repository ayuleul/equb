import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

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
    final canNavigateBack = Navigator.of(context).canPop();
    final bodyContent = Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: child,
    );

    return PopScope(
      child: Scaffold(
        backgroundColor: backgroundColor,
        floatingActionButton: floatingActionButton,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: canNavigateBack ? const BackButton() : null,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              if (subtitle != null && subtitle!.trim().isNotEmpty)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          actions: actions,
        ),
        body: useSafeArea ? SafeArea(child: bodyContent) : bodyContent,
      ),
    );
  }
}
