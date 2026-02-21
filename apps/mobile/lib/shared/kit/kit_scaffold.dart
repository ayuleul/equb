import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme_extensions.dart';
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
    this.maxContentWidth = 620,
    this.showBackgroundDecoration = true,
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
  final double maxContentWidth;
  final bool showBackgroundDecoration;

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: child,
        ),
      ),
    );
    final rootBody = useSafeArea ? SafeArea(child: body) : body;
    final themedBody = showBackgroundDecoration
        ? _KitBackground(child: rootBody)
        : rootBody;

    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.transparent,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar:
          appBar ??
          (title != null ? KitAppBar(title: title!, actions: actions) : null),
      floatingActionButton: floatingActionButton,
      body: themedBody,
    );
  }
}

class _KitBackground extends StatelessWidget {
  const _KitBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final decoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [brand.heroTop, brand.heroBottom],
      ),
    );

    return DecoratedBox(
      decoration: decoration,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _WovenPatternPainter(lineColor: brand.meshLine),
              ),
            ),
          ),
          Positioned(
            top: -110,
            right: -90,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: brand.glowPrimary,
                ),
                child: const SizedBox.square(dimension: 170),
              ),
            ),
          ),
          Positioned(
            top: 156,
            left: -102,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: brand.glowSecondary,
                ),
                child: const SizedBox.square(dimension: 130),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -92,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: brand.glowPrimary.withValues(alpha: 0.34),
                ),
                child: const SizedBox.square(dimension: 190),
              ),
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.985, end: 1),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: child,
            builder: (context, value, animatedChild) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: value,
                  alignment: Alignment.topCenter,
                  child: animatedChild,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WovenPatternPainter extends CustomPainter {
  const _WovenPatternPainter({required this.lineColor});

  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.55
      ..color = lineColor;

    const step = 96.0;
    for (var y = -step; y < size.height + step; y += step) {
      final path = Path()
        ..moveTo(0, y + 10)
        ..quadraticBezierTo(size.width * 0.35, y - 20, size.width * 0.7, y + 8)
        ..quadraticBezierTo(size.width * 0.86, y + 24, size.width, y + 4);
      canvas.drawPath(path, paint);
    }
    for (var x = -step; x < size.width + step; x += step) {
      final path = Path()
        ..moveTo(x + 10, 0)
        ..quadraticBezierTo(
          x - 22,
          size.height * 0.35,
          x + 8,
          size.height * 0.7,
        )
        ..quadraticBezierTo(x + 26, size.height * 0.86, x + 4, size.height);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WovenPatternPainter oldDelegate) {
    return lineColor != oldDelegate.lineColor;
  }
}
