import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import 'kit_card.dart';

class KitSkeletonList extends StatelessWidget {
  const KitSkeletonList({super.key, this.itemCount = 4, this.itemHeight = 86});

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        return KitCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KitSkeletonBox(height: 16, width: 160),
              const SizedBox(height: AppSpacing.sm),
              KitSkeletonBox(height: 14, width: itemHeight),
            ],
          ),
        );
      },
    );
  }
}

class KitSkeletonBox extends StatefulWidget {
  const KitSkeletonBox({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.borderRadius,
  });

  final double height;
  final double width;
  final BorderRadius? borderRadius;

  @override
  State<KitSkeletonBox> createState() => _KitSkeletonBoxState();
}

class _KitSkeletonBoxState extends State<KitSkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final base = colorScheme.surfaceContainerHigh;
        final highlight = colorScheme.surfaceContainerLow;
        final color = Color.lerp(base, highlight, _controller.value) ?? base;

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: widget.borderRadius ?? AppRadius.inputRounded,
          ),
        );
      },
    );
  }
}
