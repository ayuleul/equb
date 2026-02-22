import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';

class LotteryRevealAnimation extends StatefulWidget {
  const LotteryRevealAnimation({
    super.key,
    required this.child,
    required this.play,
  });

  final Widget child;
  final bool play;

  @override
  State<LotteryRevealAnimation> createState() => _LotteryRevealAnimationState();
}

class _LotteryRevealAnimationState extends State<LotteryRevealAnimation> {
  var _highlightOn = false;
  Timer? _highlightTimer;

  @override
  void initState() {
    super.initState();
    if (widget.play) {
      _triggerHighlight();
    }
  }

  @override
  void didUpdateWidget(covariant LotteryRevealAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play && !oldWidget.play) {
      _triggerHighlight();
    }
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    super.dispose();
  }

  void _triggerHighlight() {
    _highlightTimer?.cancel();
    setState(() => _highlightOn = true);
    _highlightTimer = Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) {
        return;
      }
      setState(() => _highlightOn = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedScale(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      scale: _highlightOn ? 1 : 0.985,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        opacity: 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: _highlightOn
                ? colorScheme.primary.withValues(alpha: 0.14)
                : colorScheme.surfaceContainerLow,
            borderRadius: AppRadius.mdRounded,
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
