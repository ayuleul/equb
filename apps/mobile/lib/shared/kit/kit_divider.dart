import 'package:flutter/material.dart';

class KitDivider extends StatelessWidget {
  const KitDivider({super.key, this.height = 1});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Divider(height: height, thickness: 0.8);
  }
}
