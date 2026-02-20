import 'package:flutter/material.dart';

class AppFontWeight {
  const AppFontWeight._();

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

class AppTypography {
  const AppTypography._();

  static const double bodyBase = 14;
  static const double bodyComfortable = 16;

  static TextTheme textTheme(ColorScheme colorScheme) {
    const fallbackFonts = <String>['SF Pro Text', 'Roboto', 'Helvetica Neue'];

    return TextTheme(
      displayLarge: const TextStyle(
        fontSize: 52,
        height: 1.08,
        fontWeight: AppFontWeight.bold,
        letterSpacing: -0.5,
        fontFamilyFallback: fallbackFonts,
      ),
      displayMedium: const TextStyle(
        fontSize: 44,
        height: 1.12,
        fontWeight: AppFontWeight.bold,
        fontFamilyFallback: fallbackFonts,
      ),
      displaySmall: const TextStyle(
        fontSize: 36,
        height: 1.16,
        fontWeight: AppFontWeight.semiBold,
        fontFamilyFallback: fallbackFonts,
      ),
      headlineLarge: const TextStyle(
        fontSize: 32,
        height: 1.2,
        fontWeight: AppFontWeight.bold,
        fontFamilyFallback: fallbackFonts,
      ),
      headlineMedium: const TextStyle(
        fontSize: 28,
        height: 1.2,
        fontWeight: AppFontWeight.semiBold,
        fontFamilyFallback: fallbackFonts,
      ),
      headlineSmall: const TextStyle(
        fontSize: 24,
        height: 1.24,
        fontWeight: AppFontWeight.semiBold,
        fontFamilyFallback: fallbackFonts,
      ),
      titleLarge: const TextStyle(
        fontSize: 22,
        height: 1.28,
        fontWeight: AppFontWeight.semiBold,
        fontFamilyFallback: fallbackFonts,
      ),
      titleMedium: const TextStyle(
        fontSize: 16,
        height: 1.35,
        fontWeight: AppFontWeight.semiBold,
        fontFamilyFallback: fallbackFonts,
      ),
      titleSmall: const TextStyle(
        fontSize: 14,
        height: 1.35,
        fontWeight: AppFontWeight.semiBold,
        fontFamilyFallback: fallbackFonts,
      ),
      bodyLarge: const TextStyle(
        fontSize: bodyComfortable,
        height: 1.45,
        fontWeight: AppFontWeight.regular,
        fontFamilyFallback: fallbackFonts,
      ),
      bodyMedium: const TextStyle(
        fontSize: bodyBase,
        height: 1.45,
        fontWeight: AppFontWeight.regular,
        fontFamilyFallback: fallbackFonts,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        height: 1.4,
        fontWeight: AppFontWeight.regular,
        fontFamilyFallback: fallbackFonts,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        height: 1.35,
        fontWeight: AppFontWeight.semiBold,
        fontFamilyFallback: fallbackFonts,
      ),
      labelMedium: const TextStyle(
        fontSize: 12,
        height: 1.3,
        fontWeight: AppFontWeight.semiBold,
        fontFamilyFallback: fallbackFonts,
      ),
      labelSmall: const TextStyle(
        fontSize: 11,
        height: 1.3,
        fontWeight: AppFontWeight.medium,
        fontFamilyFallback: fallbackFonts,
      ),
    ).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
  }
}
