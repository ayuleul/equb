import 'package:flutter/material.dart';

import 'app_colors.dart';

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
  });

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;

  static const AppSemanticColors light = AppSemanticColors(
    success: AppColors.success,
    onSuccess: Colors.white,
    successContainer: Color(0xFFDDF4E4),
    onSuccessContainer: Color(0xFF0E3A1D),
    warning: AppColors.warning,
    onWarning: Colors.white,
    warningContainer: Color(0xFFFFEFD6),
    onWarningContainer: Color(0xFF4A2B00),
    info: AppColors.info,
    onInfo: Colors.white,
    infoContainer: Color(0xFFDDEAFF),
    onInfoContainer: Color(0xFF062E5D),
  );

  static const AppSemanticColors dark = AppSemanticColors(
    success: Color(0xFF4ECF7D),
    onSuccess: Color(0xFF06361A),
    successContainer: Color(0xFF103D24),
    onSuccessContainer: Color(0xFFC8F3D7),
    warning: Color(0xFFFFBE57),
    onWarning: Color(0xFF4A2B00),
    warningContainer: Color(0xFF4D3410),
    onWarningContainer: Color(0xFFFFE8C2),
    info: Color(0xFF76B8FF),
    onInfo: Color(0xFF042948),
    infoContainer: Color(0xFF12385F),
    onInfoContainer: Color(0xFFD8EBFF),
  );

  static AppSemanticColors fallback(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) {
      return this;
    }

    return AppSemanticColors(
      success: Color.lerp(success, other.success, t) ?? success,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t) ?? onSuccess,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t) ??
          successContainer,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t) ??
          onSuccessContainer,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      onWarning: Color.lerp(onWarning, other.onWarning, t) ?? onWarning,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t) ??
          warningContainer,
      onWarningContainer:
          Color.lerp(onWarningContainer, other.onWarningContainer, t) ??
          onWarningContainer,
      info: Color.lerp(info, other.info, t) ?? info,
      onInfo: Color.lerp(onInfo, other.onInfo, t) ?? onInfo,
      infoContainer:
          Color.lerp(infoContainer, other.infoContainer, t) ?? infoContainer,
      onInfoContainer:
          Color.lerp(onInfoContainer, other.onInfoContainer, t) ??
          onInfoContainer,
    );
  }
}

extension AppThemeDataExtension on ThemeData {
  AppSemanticColors get semanticColors =>
      extension<AppSemanticColors>() ?? AppSemanticColors.fallback(brightness);
}

extension AppBuildContextThemeExtension on BuildContext {
  AppSemanticColors get semanticColors => Theme.of(this).semanticColors;
}
