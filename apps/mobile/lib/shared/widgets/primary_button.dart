import 'package:flutter/material.dart';

import '../kit/kit.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return KitPrimaryButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      expand: false,
    );
  }
}
