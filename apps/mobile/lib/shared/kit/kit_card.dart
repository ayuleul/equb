import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme_extensions.dart';

class KitCard extends StatefulWidget {
  const KitCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  State<KitCard> createState() => _KitCardState();
}

class _KitCardState extends State<KitCard> {
  bool _isHovered = false;

  void _setHovered(bool value) {
    if (_isHovered == value || widget.onTap == null) {
      return;
    }
    setState(() => _isHovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brand = context.brand;
    final shadowStrength = _isHovered ? 0.08 : 0.045;
    final liftY = _isHovered ? -2.0 : 0.0;
    final content = Padding(
      padding: widget.padding ?? const EdgeInsets.all(14),
      child: widget.child,
    );

    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOutCubic,
        margin: widget.margin,
        transform: Matrix4.translationValues(0, liftY, 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerLow.withValues(alpha: 0.22),
            ],
          ),
          borderRadius: AppRadius.cardRounded,
          border: Border.all(
            color: _isHovered
                ? colorScheme.primary.withValues(alpha: 0.32)
                : colorScheme.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: shadowStrength),
              blurRadius: _isHovered ? 20 : 14,
              offset: Offset(0, _isHovered ? 8 : 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: AppRadius.cardRounded,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        brand.cardAccentStart.withValues(alpha: 0.62),
                        brand.cardAccentEnd.withValues(alpha: 0.58),
                      ],
                    ),
                  ),
                  child: const SizedBox(height: 1.5),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: widget.onTap == null
                    ? content
                    : InkWell(
                        onTap: widget.onTap,
                        splashColor: colorScheme.primary.withValues(
                          alpha: 0.08,
                        ),
                        highlightColor: colorScheme.primary.withValues(
                          alpha: 0.03,
                        ),
                        child: content,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
