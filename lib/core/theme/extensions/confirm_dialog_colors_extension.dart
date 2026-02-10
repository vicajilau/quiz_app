import 'package:flutter/material.dart';

/// General-purpose semantic color tokens resolved by theme.
///
/// Eliminates the repeated `isDark ? X : Y` pattern across views.
/// Access via `context.appColors.title`, `context.appColors.subtitle`, etc.
class ConfirmingDialogColorsExtension
    extends ThemeExtension<ConfirmingDialogColorsExtension> {
  /// Card / dialog background color.
  final Color card;

  /// Primary heading text color.
  final Color title;

  /// Secondary text, close-button icons, labels.
  final Color subtitle;

  /// Elevated surface within a card (controls, close buttons, toggle sections).
  final Color surface;

  /// Standard border color.
  final Color border;

  const ConfirmingDialogColorsExtension({
    required this.card,
    required this.title,
    required this.subtitle,
    required this.surface,
    required this.border,
  });

  @override
  ConfirmingDialogColorsExtension copyWith({
    Color? card,
    Color? title,
    Color? subtitle,
    Color? surface,
    Color? border,
  }) {
    return ConfirmingDialogColorsExtension(
      card: card ?? this.card,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      surface: surface ?? this.surface,
      border: border ?? this.border,
    );
  }

  @override
  ConfirmingDialogColorsExtension lerp(
    ThemeExtension<ConfirmingDialogColorsExtension>? other,
    double t,
  ) {
    if (other is! ConfirmingDialogColorsExtension) {
      return this;
    }
    return ConfirmingDialogColorsExtension(
      card: Color.lerp(card, other.card, t)!,
      title: Color.lerp(title, other.title, t)!,
      subtitle: Color.lerp(subtitle, other.subtitle, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  ConfirmingDialogColorsExtension get appColors =>
      Theme.of(this).extension<ConfirmingDialogColorsExtension>()!;
}
