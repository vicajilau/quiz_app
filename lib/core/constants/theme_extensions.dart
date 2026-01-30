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
  /// (e.g., Amber in Light mode, Purple in Dark mode).
  final Color? aiIconColor;

  const CustomColors({required this.aiIconColor});

  @override
  CustomColors copyWith({Color? aiIconColor}) {
    return CustomColors(aiIconColor: aiIconColor ?? this.aiIconColor);
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
    );
  }
}
