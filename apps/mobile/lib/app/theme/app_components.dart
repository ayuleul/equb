import 'package:flutter/material.dart';

import 'app_spacing.dart';

class AppComponents {
  const AppComponents._();

  static ElevatedButtonThemeData elevatedButtonTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return ElevatedButtonThemeData(
      style:
          ElevatedButton.styleFrom(
            elevation: 0,
            minimumSize: const Size(double.infinity, 48),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.mdRounded,
            ),
            textStyle: textTheme.labelLarge,
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return colorScheme.onSurface.withValues(alpha: 0.12);
              }

              return colorScheme.primary;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return colorScheme.onSurface.withValues(alpha: 0.38);
              }

              return colorScheme.onPrimary;
            }),
          ),
    );
  }

  static FilledButtonThemeData filledButtonTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdRounded),
        textStyle: textTheme.labelLarge,
      ),
    );
  }

  static OutlinedButtonThemeData outlinedButtonTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdRounded),
        textStyle: textTheme.labelLarge,
      ),
    );
  }

  static TextButtonThemeData textButtonTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        foregroundColor: colorScheme.primary,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdRounded),
        textStyle: textTheme.labelLarge,
      ),
    );
  }

  static InputDecorationTheme inputDecorationTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    const radius = AppRadius.mdRounded;

    OutlineInputBorder border(Color color) {
      return OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: color),
      );
    }

    return InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: colorScheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      border: border(colorScheme.outlineVariant),
      enabledBorder: border(colorScheme.outlineVariant),
      focusedBorder: border(colorScheme.primary),
      errorBorder: border(colorScheme.error),
      focusedErrorBorder: border(colorScheme.error),
    );
  }

  static AppBarTheme appBarTheme(ColorScheme colorScheme, TextTheme textTheme) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
      surfaceTintColor: Colors.transparent,
    );
  }

  static CardThemeData cardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      margin: const EdgeInsets.all(0),
      elevation: 0,
      color: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgRounded),
      clipBehavior: Clip.antiAlias,
    );
  }

  static ChipThemeData chipTheme(ColorScheme colorScheme, TextTheme textTheme) {
    return ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      selectedColor: colorScheme.primaryContainer,
      secondarySelectedColor: colorScheme.primaryContainer,
      disabledColor: colorScheme.onSurface.withValues(alpha: 0.08),
      side: BorderSide(color: colorScheme.outlineVariant),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillRounded),
      labelStyle: textTheme.labelMedium,
      secondaryLabelStyle: textTheme.labelMedium?.copyWith(
        color: colorScheme.onPrimaryContainer,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 18),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      showCheckmark: false,
      brightness: colorScheme.brightness,
    );
  }

  static BottomSheetThemeData bottomSheetTheme(ColorScheme colorScheme) {
    return BottomSheetThemeData(
      backgroundColor: colorScheme.surface,
      modalBackgroundColor: colorScheme.surface,
      elevation: 0,
      modalElevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      showDragHandle: true,
      dragHandleColor: colorScheme.onSurfaceVariant,
    );
  }

  static SnackBarThemeData snackBarTheme(ColorScheme colorScheme) {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      actionTextColor: colorScheme.primary,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdRounded),
      elevation: 0,
      insetPadding: const EdgeInsets.all(AppSpacing.md),
    );
  }

  static DividerThemeData dividerTheme(ColorScheme colorScheme) {
    return DividerThemeData(
      color: colorScheme.outlineVariant,
      space: 1,
      thickness: 1,
    );
  }

  static ProgressIndicatorThemeData progressIndicatorTheme(
    ColorScheme colorScheme,
  ) {
    return ProgressIndicatorThemeData(
      color: colorScheme.primary,
      linearTrackColor: colorScheme.surfaceContainerHighest,
      circularTrackColor: colorScheme.surfaceContainerHighest,
    );
  }
}
