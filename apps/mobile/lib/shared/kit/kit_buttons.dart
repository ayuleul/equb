import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

class KitPrimaryButton extends StatelessWidget {
  const KitPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: _KitButtonContent(label: label, icon: icon, isLoading: isLoading),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class KitSecondaryButton extends StatelessWidget {
  const KitSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      child: _KitButtonContent(label: label, icon: icon, isLoading: isLoading),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class KitTertiaryButton extends StatelessWidget {
  const KitTertiaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = TextButton(
      onPressed: isLoading ? null : onPressed,
      child: _KitButtonContent(label: label, icon: icon, isLoading: isLoading),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class _KitButtonContent extends StatelessWidget {
  const _KitButtonContent({
    required this.label,
    required this.icon,
    required this.isLoading,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: AppSpacing.xs),
        ] else if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.xs),
        ],
        Text(label),
      ],
    );
  }
}
