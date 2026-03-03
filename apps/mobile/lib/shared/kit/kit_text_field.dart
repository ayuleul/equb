import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

class KitTextField extends StatelessWidget {
  const KitTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.labelTooltip,
    this.placeholder,
    this.supportText,
    this.errorText,
    this.keyboardType,
    this.onChanged,
    this.obscureText = false,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? labelTooltip;
  final String? placeholder;
  final String? supportText;
  final String? errorText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = (errorText?.isNotEmpty ?? false);
    final input = TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: placeholder,
        helperText: supportText,
        errorText: errorText,
        suffixIcon: hasError
            ? Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 18,
                    color: theme.colorScheme.onError,
                  ),
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 42,
          minHeight: 42,
        ),
      ),
    );

    return _withExternalLabel(context, label, labelTooltip, input);
  }
}

class KitTextArea extends StatelessWidget {
  const KitTextArea({
    super.key,
    this.controller,
    this.label,
    this.labelTooltip,
    this.placeholder,
    this.supportText,
    this.errorText,
    this.onChanged,
    this.maxLines = 4,
  });

  final TextEditingController? controller;
  final String? label;
  final String? labelTooltip;
  final String? placeholder;
  final String? supportText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return KitTextField(
      controller: controller,
      label: label,
      labelTooltip: labelTooltip,
      placeholder: placeholder,
      supportText: supportText,
      errorText: errorText,
      onChanged: onChanged,
      maxLines: maxLines,
    );
  }
}

class KitDropdownField<T> extends StatelessWidget {
  const KitDropdownField({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.label,
    this.labelTooltip,
    this.placeholder,
    this.supportText,
    this.errorText,
  });

  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? labelTooltip;
  final String? placeholder;
  final String? supportText;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final input = DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 22),
      borderRadius: AppRadius.cardRounded,
      dropdownColor: theme.colorScheme.surface,
      menuMaxHeight: 320,
      items: items,
      onChanged: onChanged,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: placeholder,
        helperText: supportText,
        errorText: errorText,
      ),
    );

    return _withExternalLabel(context, label, labelTooltip, input);
  }
}

class KitNumberField extends StatelessWidget {
  const KitNumberField({
    super.key,
    this.controller,
    this.label,
    this.labelTooltip,
    this.placeholder,
    this.supportText,
    this.errorText,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? label;
  final String? labelTooltip;
  final String? placeholder;
  final String? supportText;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return KitTextField(
      controller: controller,
      label: label,
      labelTooltip: labelTooltip,
      placeholder: placeholder,
      supportText: supportText,
      errorText: errorText,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }
}

Widget _withExternalLabel(
  BuildContext context,
  String? label,
  String? labelTooltip,
  Widget field,
) {
  final hasLabel = (label?.trim().isNotEmpty ?? false);
  if (!hasLabel) {
    return field;
  }

  final theme = Theme.of(context);
  final hasTooltip = (labelTooltip?.trim().isNotEmpty ?? false);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        children: [
          Text(
            label!,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: hasTooltip ? AppSpacing.xs : 0),
          if (hasTooltip)
            Tooltip(
              message: labelTooltip!,
              triggerMode: TooltipTriggerMode.tap,
              showDuration: const Duration(days: 1),
              enableTapToDismiss: true,
              preferBelow: false,
              constraints: const BoxConstraints(maxWidth: 260),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              textStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: AppRadius.smRounded,
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      const SizedBox(height: AppSpacing.xs),
      field,
    ],
  );
}
