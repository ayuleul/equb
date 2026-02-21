import 'package:flutter/material.dart';

import '../kit/kit.dart';

class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> {
  @override
  Widget build(BuildContext context) {
    return KitSkeletonBox(
      height: widget.height,
      width: widget.width,
      borderRadius: widget.borderRadius,
    );
  }
}
