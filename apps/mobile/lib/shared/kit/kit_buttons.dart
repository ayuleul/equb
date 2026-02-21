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
      style: expand
          ? null
          : _compactButtonStyle(FilledButtonTheme.of(context).style),
      onPressed: isLoading ? null : onPressed,
      child: _KitButtonContent(label: label, icon: icon, isLoading: isLoading),
    );
    return expand ? _KitExpandedButtonFrame(child: button) : button;
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
      style: expand
          ? null
          : _compactButtonStyle(OutlinedButtonTheme.of(context).style),
      onPressed: isLoading ? null : onPressed,
      child: _KitButtonContent(label: label, icon: icon, isLoading: isLoading),
    );
    return expand ? _KitExpandedButtonFrame(child: button) : button;
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
    return expand ? _KitExpandedButtonFrame(child: button) : button;
  }
}

class _KitExpandedButtonFrame extends StatelessWidget {
  const _KitExpandedButtonFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
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
    final progressColor =
        IconTheme.of(context).color ?? Theme.of(context).colorScheme.onPrimary;
    final labelText = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final boundedWidth = constraints.maxWidth.isFinite;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading) ...[
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
            ] else if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: AppSpacing.xs),
            ],
            if (boundedWidth) Flexible(child: labelText) else labelText,
          ],
        );
      },
    );
  }
}

ButtonStyle _compactButtonStyle(ButtonStyle? baseStyle) {
  final base = baseStyle ?? const ButtonStyle();
  return base.copyWith(
    minimumSize: const WidgetStatePropertyAll(Size(0, 46)),
    fixedSize: const WidgetStatePropertyAll<Size?>(null),
  );
}
