import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import 'kit_app_bar.dart';

class KitScaffold extends StatelessWidget {
  const KitScaffold({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.padding,
    this.useSafeArea = true,
    this.backgroundColor,
    this.floatingActionButton,
    this.appBar,
    this.extendBodyBehindAppBar = false,
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;
  final bool useSafeArea;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      child: child,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar:
          appBar ??
          (title != null ? KitAppBar(title: title!, actions: actions) : null),
      floatingActionButton: floatingActionButton,
      body: useSafeArea ? SafeArea(child: body) : body,
    );
  }
}
