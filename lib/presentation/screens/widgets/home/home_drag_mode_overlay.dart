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

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/core/theme/extensions/custom_colors.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';

class HomeDragModeOverlay extends StatelessWidget {
  final QuizMode? hoveredMode;

  const HomeDragModeOverlay({super.key, required this.hoveredMode});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customColors = Theme.of(context).extension<CustomColors>()!;

    final studyColor = Theme.of(context).colorScheme.primary;
    final quizColor = customColors.onWarningContainer!;

    final studyZone = _DragZone(
      icon: LucideIcons.bookOpen,
      label: localizations.studyModeLabel,
      hint: localizations.dropHereToStudy,
      accentColor: studyColor,
      gradientColors: [
        studyColor.withValues(alpha: isDark ? 0.5 : 0.6),
        studyColor.withValues(alpha: isDark ? 0.15 : 0.2),
      ],
      isHighlighted: hoveredMode == QuizMode.study,
    );

    final quizZone = _DragZone(
      icon: LucideIcons.trophy,
      label: localizations.quizModeTitle,
      hint: localizations.dropHereToQuiz,
      accentColor: quizColor,
      gradientColors: [
        quizColor.withValues(alpha: isDark ? 0.5 : 0.6),
        quizColor.withValues(alpha: isDark ? 0.15 : 0.2),
      ],
      isHighlighted: hoveredMode == QuizMode.quiz,
    );

    final dividerColor = isDark ? AppTheme.zinc700 : AppTheme.zinc200;

    if (isMobile) {
      return Column(
        children: [
          Expanded(child: studyZone),
          Container(height: 2, color: dividerColor),
          Expanded(child: quizZone),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: studyZone),
        Container(width: 2, color: dividerColor),
        Expanded(child: quizZone),
      ],
    );
  }
}

class _DragZone extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final Color accentColor;
  final List<Color> gradientColors;
  final bool isHighlighted;

  const _DragZone({
    required this.icon,
    required this.label,
    required this.hint,
    required this.accentColor,
    required this.gradientColors,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isHighlighted ? 1.0 : 0.5,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 48, color: accentColor),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hint,
                    style: TextStyle(
                      fontSize: 14,
                      color: accentColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
