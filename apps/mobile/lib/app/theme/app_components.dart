import 'package:flutter/material.dart';

import 'app_spacing.dart';

class AppComponents {
  const AppComponents._();

  static ElevatedButtonThemeData elevatedButtonTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final baseStyle = ElevatedButton.styleFrom(
      elevation: 0,
      minimumSize: const Size(double.infinity, 46),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.inputRounded),
      textStyle: textTheme.labelLarge,
    );

    return ElevatedButtonThemeData(
      style: baseStyle.copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: 0.12);
          }
          if (states.contains(WidgetState.pressed)) {
            return colorScheme.primary.withValues(alpha: 0.9);
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
    final baseStyle = FilledButton.styleFrom(
      minimumSize: const Size(double.infinity, 46),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.inputRounded),
      textStyle: textTheme.labelLarge,
    );

    return FilledButtonThemeData(
      style: baseStyle.copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: 0.12);
          }
          if (states.contains(WidgetState.pressed)) {
            return colorScheme.primary.withValues(alpha: 0.9);
          }
          return colorScheme.primary;
        }),
      ),
    );
  }

  static OutlinedButtonThemeData outlinedButtonTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final baseStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(double.infinity, 46),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      side: BorderSide(color: colorScheme.outlineVariant),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.inputRounded),
      textStyle: textTheme.labelLarge,
    );

    return OutlinedButtonThemeData(
      style: baseStyle.copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return colorScheme.primary.withValues(alpha: 0.08);
          }
          return colorScheme.surface;
        }),
      ),
    );
  }

  static TextButtonThemeData textButtonTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
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
    const radius = AppRadius.inputRounded;

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
        vertical: 10,
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      border: border(colorScheme.outlineVariant),
      enabledBorder: border(colorScheme.outlineVariant),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
      ),
      errorBorder: border(colorScheme.error),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: colorScheme.error, width: 1.4),
      ),
    );
  }

  static AppBarTheme appBarTheme(ColorScheme colorScheme, TextTheme textTheme) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface.withValues(alpha: 0.96),
      foregroundColor: colorScheme.onSurface,
      centerTitle: false,
      titleSpacing: AppSpacing.md,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
      surfaceTintColor: Colors.transparent,
    );
  }

  static CardThemeData cardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      margin: const EdgeInsets.all(0),
      elevation: 0,
      shadowColor: Colors.transparent,
      color: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardRounded,
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
    );
  }

  static ChipThemeData chipTheme(ColorScheme colorScheme, TextTheme textTheme) {
    return ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.card + 4),
        ),
      ),
      showDragHandle: true,
      dragHandleColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
    );
  }

  static SnackBarThemeData snackBarTheme(ColorScheme colorScheme) {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      actionTextColor: colorScheme.primary,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.inputRounded),
      elevation: 1,
      insetPadding: const EdgeInsets.all(AppSpacing.md),
    );
  }

  static DividerThemeData dividerTheme(ColorScheme colorScheme) {
    return DividerThemeData(
      color: colorScheme.outlineVariant,
      space: 1,
      thickness: 0.8,
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

  static IconButtonThemeData iconButtonTheme(ColorScheme colorScheme) {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        backgroundColor: colorScheme.surfaceContainerLow,
        minimumSize: const Size(40, 40),
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.inputRounded,
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
    );
  }

  static ListTileThemeData listTileTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      iconColor: colorScheme.onSurfaceVariant,
      textColor: colorScheme.onSurface,
      titleTextStyle: textTheme.titleMedium,
      subtitleTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.inputRounded,
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      tileColor: colorScheme.surface,
    );
  }
}
