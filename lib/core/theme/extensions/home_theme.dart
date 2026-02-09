import 'package:flutter/material.dart';

class HomeTheme extends ThemeExtension<HomeTheme> {
  final Color dropZoneShadowColor;

  const HomeTheme({required this.dropZoneShadowColor});

  @override
  HomeTheme copyWith({Color? dropZoneShadowColor}) {
    return HomeTheme(
      dropZoneShadowColor: dropZoneShadowColor ?? this.dropZoneShadowColor,
    );
  }

  @override
  HomeTheme lerp(ThemeExtension<HomeTheme>? other, double t) {
    if (other is! HomeTheme) {
      return this;
    }
    return HomeTheme(
      dropZoneShadowColor: Color.lerp(
        dropZoneShadowColor,
        other.dropZoneShadowColor,
        t,
      )!,
    );
  }
}

extension HomeThemeContext on BuildContext {
  HomeTheme get homeTheme => Theme.of(this).extension<HomeTheme>()!;
}
