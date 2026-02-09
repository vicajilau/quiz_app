import 'package:flutter/material.dart';

class QuestionDialogTheme extends ThemeExtension<QuestionDialogTheme> {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final Color closeButtonColor;
  final Color closeIconColor;
  final Color shadowColor;

  const QuestionDialogTheme({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.closeButtonColor,
    required this.closeIconColor,
    required this.shadowColor,
  });

  @override
  QuestionDialogTheme copyWith({
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    Color? closeButtonColor,
    Color? closeIconColor,
    Color? shadowColor,
  }) {
    return QuestionDialogTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      borderColor: borderColor ?? this.borderColor,
      closeButtonColor: closeButtonColor ?? this.closeButtonColor,
      closeIconColor: closeIconColor ?? this.closeIconColor,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }

  @override
  QuestionDialogTheme lerp(
    ThemeExtension<QuestionDialogTheme>? other,
    double t,
  ) {
    if (other is! QuestionDialogTheme) {
      return this;
    }
    return QuestionDialogTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      closeButtonColor: Color.lerp(
        closeButtonColor,
        other.closeButtonColor,
        t,
      )!,
      closeIconColor: Color.lerp(closeIconColor, other.closeIconColor, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
    );
  }
}
