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

/// Theme extension for Study Components (Timeline, Reminder, Warning, etc.)
///
/// Centralizes all specific colors used in study components to support
/// consistency and easy theme switching without hardcoded values in widgets.
class StudyThemeExtension extends ThemeExtension<StudyThemeExtension> {
  // General Card styling
  final Color cardBackground;
  final Color cardBorder;
  final Color cardTitle;
  final Color cardSubtitle;
  final Color cardDivider;

  // Table specific
  final Color tableHeaderBackground;

  // Warning component
  final Color warningBackground;
  final Color warningBorder;
  final Color warningIcon;

  // Reminder component
  final Color reminderBackground;
  final Color reminderBorder;
  final Color reminderIcon;

  // Pros/Cons component
  final Color prosBackground;
  final Color prosBorder;
  final Color prosIcon;
  final Color consBackground;
  final Color consBorder;
  final Color consIcon;

  // Formula component
  final Color formulaBackground;
  final Color formulaText;
  final Color formulaLabel;

  // Timeline component
  final Color timelineIndicator;
  final Color timelineLine;

  const StudyThemeExtension({
    required this.cardBackground,
    required this.cardBorder,
    required this.cardTitle,
    required this.cardSubtitle,
    required this.cardDivider,
    required this.tableHeaderBackground,
    required this.warningBackground,
    required this.warningBorder,
    required this.warningIcon,
    required this.reminderBackground,
    required this.reminderBorder,
    required this.reminderIcon,
    required this.prosBackground,
    required this.prosBorder,
    required this.prosIcon,
    required this.consBackground,
    required this.consBorder,
    required this.consIcon,
    required this.formulaBackground,
    required this.formulaText,
    required this.formulaLabel,
    required this.timelineIndicator,
    required this.timelineLine,
  });

  @override
  StudyThemeExtension copyWith({
    Color? cardBackground,
    Color? cardBorder,
    Color? cardTitle,
    Color? cardSubtitle,
    Color? cardDivider,
    Color? tableHeaderBackground,
    Color? warningBackground,
    Color? warningBorder,
    Color? warningIcon,
    Color? reminderBackground,
    Color? reminderBorder,
    Color? reminderIcon,
    Color? prosBackground,
    Color? prosBorder,
    Color? prosIcon,
    Color? consBackground,
    Color? consBorder,
    Color? consIcon,
    Color? formulaBackground,
    Color? formulaText,
    Color? formulaLabel,
    Color? timelineIndicator,
    Color? timelineLine,
  }) {
    return StudyThemeExtension(
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      cardTitle: cardTitle ?? this.cardTitle,
      cardSubtitle: cardSubtitle ?? this.cardSubtitle,
      cardDivider: cardDivider ?? this.cardDivider,
      tableHeaderBackground:
          tableHeaderBackground ?? this.tableHeaderBackground,
      warningBackground: warningBackground ?? this.warningBackground,
      warningBorder: warningBorder ?? this.warningBorder,
      warningIcon: warningIcon ?? this.warningIcon,
      reminderBackground: reminderBackground ?? this.reminderBackground,
      reminderBorder: reminderBorder ?? this.reminderBorder,
      reminderIcon: reminderIcon ?? this.reminderIcon,
      prosBackground: prosBackground ?? this.prosBackground,
      prosBorder: prosBorder ?? this.prosBorder,
      prosIcon: prosIcon ?? this.prosIcon,
      consBackground: consBackground ?? this.consBackground,
      consBorder: consBorder ?? this.consBorder,
      consIcon: consIcon ?? this.consIcon,
      formulaBackground: formulaBackground ?? this.formulaBackground,
      formulaText: formulaText ?? this.formulaText,
      formulaLabel: formulaLabel ?? this.formulaLabel,
      timelineIndicator: timelineIndicator ?? this.timelineIndicator,
      timelineLine: timelineLine ?? this.timelineLine,
    );
  }

  @override
  StudyThemeExtension lerp(
    ThemeExtension<StudyThemeExtension>? other,
    double t,
  ) {
    if (other is! StudyThemeExtension) return this;
    return StudyThemeExtension(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      cardTitle: Color.lerp(cardTitle, other.cardTitle, t)!,
      cardSubtitle: Color.lerp(cardSubtitle, other.cardSubtitle, t)!,
      cardDivider: Color.lerp(cardDivider, other.cardDivider, t)!,
      tableHeaderBackground:
          Color.lerp(tableHeaderBackground, other.tableHeaderBackground, t)!,
      warningBackground: Color.lerp(warningBackground, other.warningBackground, t)!,
      warningBorder: Color.lerp(warningBorder, other.warningBorder, t)!,
      warningIcon: Color.lerp(warningIcon, other.warningIcon, t)!,
      reminderBackground: Color.lerp(reminderBackground, other.reminderBackground, t)!,
      reminderBorder: Color.lerp(reminderBorder, other.reminderBorder, t)!,
      reminderIcon: Color.lerp(reminderIcon, other.reminderIcon, t)!,
      prosBackground: Color.lerp(prosBackground, other.prosBackground, t)!,
      prosBorder: Color.lerp(prosBorder, other.prosBorder, t)!,
      prosIcon: Color.lerp(prosIcon, other.prosIcon, t)!,
      consBackground: Color.lerp(consBackground, other.consBackground, t)!,
      consBorder: Color.lerp(consBorder, other.consBorder, t)!,
      consIcon: Color.lerp(consIcon, other.consIcon, t)!,
      formulaBackground: Color.lerp(formulaBackground, other.formulaBackground, t)!,
      formulaText: Color.lerp(formulaText, other.formulaText, t)!,
      formulaLabel: Color.lerp(formulaLabel, other.formulaLabel, t)!,
      timelineIndicator: Color.lerp(timelineIndicator, other.timelineIndicator, t)!,
      timelineLine: Color.lerp(timelineLine, other.timelineLine, t)!,
    );
  }
}

extension StudyThemeContext on BuildContext {
  StudyThemeExtension get studyTheme =>
      Theme.of(this).extension<StudyThemeExtension>()!;
}
