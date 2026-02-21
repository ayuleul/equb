import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

class KitSearchBar extends StatelessWidget {
  const KitSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText = 'Search',
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: colorScheme.onSurfaceVariant,
          size: 20,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.pillRounded,
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.pillRounded,
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
    );
  }
}
