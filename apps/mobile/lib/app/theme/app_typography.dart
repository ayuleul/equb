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
  static const String headingFamily = 'Avenir Next';
  static const String bodyFamily = 'Nunito';
  static const List<String> fallbackFonts = <String>[
    'Noto Sans Ethiopic',
    'Avenir Next',
    'Segoe UI',
    'Helvetica Neue',
    'Trebuchet MS',
  ];

  static TextTheme textTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: const TextStyle(
        fontSize: 52,
        height: 1.08,
        fontWeight: AppFontWeight.bold,
        letterSpacing: -0.5,
        fontFamily: headingFamily,
        fontFamilyFallback: fallbackFonts,
      ),
      displayMedium: const TextStyle(
        fontSize: 44,
        height: 1.12,
        fontWeight: AppFontWeight.bold,
        fontFamily: headingFamily,
        fontFamilyFallback: fallbackFonts,
      ),
      displaySmall: const TextStyle(
        fontSize: 36,
        height: 1.16,
        fontWeight: AppFontWeight.semiBold,
        fontFamily: headingFamily,
        fontFamilyFallback: fallbackFonts,
      ),
      headlineLarge: const TextStyle(
        fontSize: 32,
        height: 1.2,
        fontWeight: AppFontWeight.bold,
        fontFamily: headingFamily,
        fontFamilyFallback: fallbackFonts,
      ),
      headlineMedium: const TextStyle(
        fontSize: 28,
        height: 1.2,
        fontWeight: AppFontWeight.semiBold,
        fontFamily: headingFamily,
        fontFamilyFallback: fallbackFonts,
      ),
      headlineSmall: const TextStyle(
        fontSize: 24,
        height: 1.24,
        fontWeight: AppFontWeight.semiBold,
        fontFamily: headingFamily,
        fontFamilyFallback: fallbackFonts,
      ),
      titleLarge: const TextStyle(
        fontSize: 21,
        height: 1.28,
        fontWeight: AppFontWeight.semiBold,
        fontFamily: headingFamily,
        fontFamilyFallback: fallbackFonts,
      ),
      titleMedium: const TextStyle(
        fontSize: 16,
        height: 1.35,
        fontWeight: AppFontWeight.semiBold,
        letterSpacing: 0.1,
        fontFamily: headingFamily,
        fontFamilyFallback: fallbackFonts,
      ),
      titleSmall: const TextStyle(
        fontSize: 14,
        height: 1.35,
        fontWeight: AppFontWeight.semiBold,
        letterSpacing: 0.1,
        fontFamily: headingFamily,
        fontFamilyFallback: fallbackFonts,
      ),
      bodyLarge: const TextStyle(
        fontSize: bodyComfortable,
        height: 1.45,
        fontWeight: AppFontWeight.regular,
        fontFamily: bodyFamily,
        fontFamilyFallback: fallbackFonts,
      ),
      bodyMedium: const TextStyle(
        fontSize: bodyBase,
        height: 1.45,
        fontWeight: AppFontWeight.regular,
        letterSpacing: 0.15,
        fontFamily: bodyFamily,
        fontFamilyFallback: fallbackFonts,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        height: 1.4,
        fontWeight: AppFontWeight.regular,
        letterSpacing: 0.2,
        fontFamily: bodyFamily,
        fontFamilyFallback: fallbackFonts,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        height: 1.35,
        fontWeight: AppFontWeight.semiBold,
        letterSpacing: 0.2,
        fontFamily: headingFamily,
        fontFamilyFallback: fallbackFonts,
      ),
      labelMedium: const TextStyle(
        fontSize: 12,
        height: 1.3,
        fontWeight: AppFontWeight.semiBold,
        letterSpacing: 0.3,
        fontFamily: headingFamily,
        fontFamilyFallback: fallbackFonts,
      ),
      labelSmall: const TextStyle(
        fontSize: 11,
        height: 1.3,
        fontWeight: AppFontWeight.medium,
        letterSpacing: 0.3,
        fontFamily: headingFamily,
        fontFamilyFallback: fallbackFonts,
      ),
    ).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
  }
}
