// Copyright (C) 2026 Víctor Carreras
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';

class HomeTheme extends ThemeExtension<HomeTheme> {
  final Color dropZoneShadowColor;
  final Color sidebarBackgroundColor;
  final Color mainBackgroundColor;
  final Color cardBackgroundColor;
  final Color borderColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final Color progressGreenColor;
  final Color progressOrangeColor;
  final Color progressBlueColor;
  final Color studyAiCardColor;
  final Color quizAiCardColor;
  final Color dragHintBackgroundColor;

  const HomeTheme({
    required this.dropZoneShadowColor,
    required this.sidebarBackgroundColor,
    required this.mainBackgroundColor,
    required this.cardBackgroundColor,
    required this.borderColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.progressGreenColor,
    required this.progressOrangeColor,
    required this.progressBlueColor,
    required this.studyAiCardColor,
    required this.quizAiCardColor,
    required this.dragHintBackgroundColor,
  });

  @override
  HomeTheme copyWith({
    Color? dropZoneShadowColor,
    Color? sidebarBackgroundColor,
    Color? mainBackgroundColor,
    Color? cardBackgroundColor,
    Color? borderColor,
    Color? textPrimaryColor,
    Color? textSecondaryColor,
    Color? progressGreenColor,
    Color? progressOrangeColor,
    Color? progressBlueColor,
    Color? studyAiCardColor,
    Color? quizAiCardColor,
    Color? dragHintBackgroundColor,
  }) {
    return HomeTheme(
      dropZoneShadowColor: dropZoneShadowColor ?? this.dropZoneShadowColor,
      sidebarBackgroundColor:
          sidebarBackgroundColor ?? this.sidebarBackgroundColor,
      mainBackgroundColor: mainBackgroundColor ?? this.mainBackgroundColor,
      cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      borderColor: borderColor ?? this.borderColor,
      textPrimaryColor: textPrimaryColor ?? this.textPrimaryColor,
      textSecondaryColor: textSecondaryColor ?? this.textSecondaryColor,
      progressGreenColor: progressGreenColor ?? this.progressGreenColor,
      progressOrangeColor: progressOrangeColor ?? this.progressOrangeColor,
      progressBlueColor: progressBlueColor ?? this.progressBlueColor,
      studyAiCardColor: studyAiCardColor ?? this.studyAiCardColor,
      quizAiCardColor: quizAiCardColor ?? this.quizAiCardColor,
      dragHintBackgroundColor:
          dragHintBackgroundColor ?? this.dragHintBackgroundColor,
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
      sidebarBackgroundColor: Color.lerp(
        sidebarBackgroundColor,
        other.sidebarBackgroundColor,
        t,
      )!,
      mainBackgroundColor: Color.lerp(
        mainBackgroundColor,
        other.mainBackgroundColor,
        t,
      )!,
      cardBackgroundColor: Color.lerp(
        cardBackgroundColor,
        other.cardBackgroundColor,
        t,
      )!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      textPrimaryColor: Color.lerp(
        textPrimaryColor,
        other.textPrimaryColor,
        t,
      )!,
      textSecondaryColor: Color.lerp(
        textSecondaryColor,
        other.textSecondaryColor,
        t,
      )!,
      progressGreenColor: Color.lerp(
        progressGreenColor,
        other.progressGreenColor,
        t,
      )!,
      progressOrangeColor: Color.lerp(
        progressOrangeColor,
        other.progressOrangeColor,
        t,
      )!,
      progressBlueColor: Color.lerp(
        progressBlueColor,
        other.progressBlueColor,
        t,
      )!,
      studyAiCardColor: Color.lerp(
        studyAiCardColor,
        other.studyAiCardColor,
        t,
      )!,
      quizAiCardColor: Color.lerp(quizAiCardColor, other.quizAiCardColor, t)!,
      dragHintBackgroundColor: Color.lerp(
        dragHintBackgroundColor,
        other.dragHintBackgroundColor,
        t,
      )!,
    );
  }
}

extension HomeThemeContext on BuildContext {
  HomeTheme get homeTheme => Theme.of(this).extension<HomeTheme>()!;
}
