import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_components.dart';
import 'app_theme_extensions.dart';
import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          surfaceContainer: isDark
              ? AppColors.darkSurfaceAlt
              : AppColors.lightSurfaceAlt,
          surfaceContainerLow: isDark
              ? const Color(0xFF1F2C3A)
              : const Color(0xFFFBFCFD),
          surfaceContainerHigh: isDark
              ? const Color(0xFF223040)
              : const Color(0xFFEEF1F5),
          surfaceContainerHighest: isDark
              ? const Color(0xFF29394A)
              : const Color(0xFFE6EAF0),
          outline: isDark ? const Color(0xFF3D4D5F) : AppColors.lightOutline,
          outlineVariant: isDark
              ? const Color(0xFF324252)
              : AppColors.lightOutlineVariant,
          shadow: Colors.black.withValues(alpha: isDark ? 0.20 : 0.08),
        );

    final textTheme = AppTypography.textTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      canvasColor: isDark ? AppColors.darkSurface : AppColors.lightBackground,
      textTheme: textTheme,
      appBarTheme: AppComponents.appBarTheme(colorScheme, textTheme),
      elevatedButtonTheme: AppComponents.elevatedButtonTheme(
        colorScheme,
        textTheme,
      ),
      filledButtonTheme: AppComponents.filledButtonTheme(
        colorScheme,
        textTheme,
      ),
      outlinedButtonTheme: AppComponents.outlinedButtonTheme(
        colorScheme,
        textTheme,
      ),
      textButtonTheme: AppComponents.textButtonTheme(colorScheme, textTheme),
      inputDecorationTheme: AppComponents.inputDecorationTheme(
        colorScheme,
        textTheme,
      ),
      cardTheme: AppComponents.cardTheme(colorScheme),
      chipTheme: AppComponents.chipTheme(colorScheme, textTheme),
      bottomSheetTheme: AppComponents.bottomSheetTheme(colorScheme),
      snackBarTheme: AppComponents.snackBarTheme(colorScheme),
      dividerTheme: AppComponents.dividerTheme(colorScheme),
      progressIndicatorTheme: AppComponents.progressIndicatorTheme(colorScheme),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
        elevation: 1,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      extensions: <ThemeExtension<dynamic>>[
        isDark ? AppSemanticColors.dark : AppSemanticColors.light,
      ],
    );
  }
}
