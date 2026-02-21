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
    final baseScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    );
    final colorScheme = baseScheme.copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: isDark ? const Color(0xFFFFBE78) : AppColors.secondary,
      onSecondary: isDark ? const Color(0xFF341F00) : Colors.white,
      surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      surfaceContainer: isDark
          ? AppColors.darkSurfaceAlt
          : AppColors.lightSurfaceAlt,
      surfaceContainerLow: isDark
          ? const Color(0xFF162434)
          : const Color(0xFFF8FBFF),
      surfaceContainerHigh: isDark
          ? const Color(0xFF1B2B3D)
          : const Color(0xFFEFF4FA),
      surfaceContainerHighest: isDark
          ? const Color(0xFF223244)
          : const Color(0xFFE5ECF4),
      outline: isDark ? const Color(0xFF3A4E62) : AppColors.lightOutline,
      outlineVariant: isDark
          ? const Color(0xFF314457)
          : AppColors.lightOutlineVariant,
      shadow: Colors.black.withValues(alpha: isDark ? 0.28 : 0.10),
      scrim: Colors.black.withValues(alpha: isDark ? 0.56 : 0.42),
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
      iconButtonTheme: AppComponents.iconButtonTheme(colorScheme),
      inputDecorationTheme: AppComponents.inputDecorationTheme(
        colorScheme,
        textTheme,
      ),
      cardTheme: AppComponents.cardTheme(colorScheme),
      listTileTheme: AppComponents.listTileTheme(colorScheme, textTheme),
      chipTheme: AppComponents.chipTheme(colorScheme, textTheme),
      bottomSheetTheme: AppComponents.bottomSheetTheme(colorScheme),
      snackBarTheme: AppComponents.snackBarTheme(colorScheme),
      dividerTheme: AppComponents.dividerTheme(colorScheme),
      progressIndicatorTheme: AppComponents.progressIndicatorTheme(colorScheme),
      splashFactory: InkRipple.splashFactory,
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
        isDark ? AppBrandDecor.dark : AppBrandDecor.light,
      ],
    );
  }
}
