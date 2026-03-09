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
import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_progress_bar.dart';

class StudyExecutionBottomBar extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final int currentIndex;
  final int totalCount;
  final double progressPercentage;
  final AppLocalizations localizations;

  const StudyExecutionBottomBar({
    super.key,
    this.onPrevious,
    this.onNext,
    required this.currentIndex,
    required this.totalCount,
    required this.progressPercentage,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final backgroundColor = theme.cardColor;

    final isMobile = context.isMobile;

    return Container(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: theme.dividerColor, width: 1)),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: StudyProgressBar(progressPercentage: progressPercentage),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: QuizdyButton(
                      title: isMobile
                          ? ''
                          : localizations.studyScreenPreviousSection,
                      icon: LucideIcons.chevronLeft,
                      type: QuizdyButtonType.secondary,
                      onPressed: onPrevious,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          localizations.studyScreenSectionIndicator(
                            currentIndex + 1,
                            totalCount,
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${progressPercentage.toStringAsFixed(0)}% ${localizations.studyScreenCoverage}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppTheme.zinc500 : AppTheme.zinc400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: QuizdyButton(
                      title: isMobile
                          ? ''
                          : localizations.studyScreenNextSection,
                      icon: LucideIcons.chevronRight,
                      onPressed: onNext,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
