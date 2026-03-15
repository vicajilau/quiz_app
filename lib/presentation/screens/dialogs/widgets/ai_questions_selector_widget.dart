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
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/core/theme/extensions/confirm_dialog_colors_extension.dart';
import 'package:quizdy/domain/models/quiz/question.dart';
import 'package:quizdy/presentation/widgets/quizdy_switch.dart';

class AiQuestionsSelectorWidget extends StatelessWidget {
  final List<Question> questions;
  final bool enabled;
  final Set<int> selectedIndices;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onQuestionToggled;

  const AiQuestionsSelectorWidget({
    super.key,
    required this.questions,
    required this.enabled,
    required this.selectedIndices,
    required this.onToggle,
    required this.onQuestionToggled,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localizations.aiSelectQuestionsTitle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.title,
              ),
            ),
            QuizdySwitch(value: enabled, onChanged: onToggle),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          localizations.aiSelectQuestionsSubtitle,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: colors.subtitle,
          ),
        ),
        if (enabled) ...[
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(questions.length, (i) {
                    final question = questions[i];
                    final isSelected = selectedIndices.contains(i);
                    return _QuestionItem(
                      question: question,
                      isSelected: isSelected,
                      onTap: () => onQuestionToggled(i),
                      isLast: i == questions.length - 1,
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _QuestionItem extends StatelessWidget {
  final Question question;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLast;

  const _QuestionItem({
    required this.question,
    required this.isSelected,
    required this.onTap,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark
                        ? AppTheme.primaryColor.withValues(alpha: 0.15)
                        : AppTheme.primaryColor.withValues(alpha: 0.08))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.primaryColor, width: 2),
                  ),
                  child: isSelected
                      ? const Icon(
                          LucideIcons.check,
                          size: 12,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Tooltip(
                    message: question.text,
                    waitDuration: const Duration(milliseconds: 400),
                    child: Text(
                      question.text,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w500
                            : FontWeight.normal,
                        color: isSelected ? colors.title : colors.subtitle,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            color: colors.border.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}
