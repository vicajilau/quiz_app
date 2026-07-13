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
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/core/theme/extensions/custom_colors.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';

class HomeDragModeOverlay extends StatelessWidget {
  final QuizMode? hoveredMode;
  final bool isImportMode;

  const HomeDragModeOverlay({
    super.key,
    required this.hoveredMode,
    this.isImportMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final customColors = Theme.of(context).extension<CustomColors>()!;

    final studyColor = Theme.of(context).colorScheme.primary;
    final quizColor = customColors.onWarningContainer!;

    if (isImportMode) {
      return _DragZone(
        icon: LucideIcons.upload,
        label: localizations.dropToImportTitle,
        hint: localizations.dropToImportHint,
        accentColor: studyColor,
        gradientColors: [
          studyColor.withValues(alpha: isDark ? 0.5 : 0.6),
          studyColor.withValues(alpha: isDark ? 0.15 : 0.2),
        ],
        isHighlighted: true,
      );
    }

    final studyZone = _DragZone(
      icon: LucideIcons.book_open,
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

    if (context.isMobile) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentBgColor = isDark
        ? Colors.black.withValues(alpha: 0.35)
        : Colors.black.withValues(alpha: 0.2);

    final cardBgColor = isHighlighted
        ? accentColor
        : (isDark ? AppTheme.zinc800 : Colors.white);

    final currentBorderColor = isHighlighted
        ? accentColor
        : (isDark ? Colors.white12 : Colors.black12);

    final currentTextColor = isHighlighted
        ? Colors.white
        : (isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87);

    final currentIconColor = isHighlighted
        ? Colors.white
        : (isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black54);

    final hintColor = isHighlighted
        ? Colors.white.withValues(alpha: 0.7)
        : (isDark ? Colors.white.withValues(alpha: 0.38) : Colors.black45);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          color: currentBgColor,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: currentBorderColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 44, color: currentIconColor),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: currentTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: hintColor,
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
