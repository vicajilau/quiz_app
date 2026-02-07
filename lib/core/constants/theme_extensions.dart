import 'package:flutter/material.dart';

/// Extension to add custom colors to the application's [ThemeData].
///
/// Allows defining semantic colors that do not fit into the standard [ColorScheme]
/// and accessing them in a typed and safe way via:
/// `Theme.of(context).extension<CustomColors>()!.aiIconColor`
///
/// Includes support for smooth animations between themes thanks to the [lerp] method.
class CustomColors extends ThemeExtension<CustomColors> {
  /// Specific color for the AI functionality icon.
  ///
  /// Used to visually differentiate the AI state or branding
  /// Used to visually differentiate the AI state or branding
  /// (e.g., Amber in Light mode, Purple in Dark mode).
  final Color? aiIconColor;

  /// Success color (e.g., Green for correct answers).
  final Color? success;

  /// Info color (e.g., Blue for edit actions).
  final Color? info;

  /// Warning color (e.g., Amber for missing explanations).
  final Color? warning;

  /// Warning container background color.
  final Color? warningContainer;

  /// Warning container text/icon color.
  final Color? onWarningContainer;

  const CustomColors({
    required this.aiIconColor,
    this.success,
    this.info,
    this.warning,
    this.warningContainer,
    this.onWarningContainer,
  });

  @override
  CustomColors copyWith({
    Color? aiIconColor,
    Color? success,
    Color? info,
    Color? warning,
    Color? warningContainer,
    Color? onWarningContainer,
  }) {
    return CustomColors(
      aiIconColor: aiIconColor ?? this.aiIconColor,
      success: success ?? this.success,
      info: info ?? this.info,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
    );
  }

  /// Linearly interpolates between two instances of [CustomColors].
  ///
  /// This ensures that when switching themes (e.g. from Light to Dark),
  /// the color change is animated smoothly instead of being abrupt.
  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      aiIconColor: Color.lerp(aiIconColor, other.aiIconColor, t),
      success: Color.lerp(success, other.success, t),
      info: Color.lerp(info, other.info, t),
      warning: Color.lerp(warning, other.warning, t),
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t),
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      ),
    );
  }
}
