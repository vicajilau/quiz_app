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
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/domain/models/quiz/question_type.dart';
import 'package:quizdy/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'package:quizdy/presentation/utils/question_translation_helper.dart';
import 'package:quizdy/presentation/widgets/latex_text.dart';

/// A widget that displays the options for multiple choice or true/false questions.
///
/// It highlights correct and incorrect answers based on the user's selection
/// and the provided results.
class QuizQuestionOptionsResult extends StatelessWidget {
  /// The question result data.
  final QuestionResult result;

  /// Creates a [QuizQuestionOptionsResult] widget.
  const QuizQuestionOptionsResult({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    if (result.question.type == QuestionType.essay) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final isMultipleChoice =
        result.question.type == QuestionType.multipleChoice;

    return Column(
      children: [
        ...result.question.options.asMap().entries.map((entry) {
          final optionIndex = entry.key;
          final optionText = entry.value;
          final isCorrect = result.correctAnswers.contains(optionIndex);
          final wasSelected = result.userAnswers.contains(optionIndex);

          Color? backgroundColor;
          Color? borderColor;
          Color? iconColor;
          Color? textColor;
          Widget? statusBadge;
          FontWeight fontWeight = FontWeight.normal;

          if (isCorrect && wasSelected) {
            backgroundColor = Colors.green.withValues(alpha: 0.15);
            borderColor = Colors.green;
            iconColor = Colors.green;
            textColor = Colors.green.shade800;
            fontWeight = FontWeight.w600;
            statusBadge = _buildStatusBadge(
              localizations.correctSelectedLabel,
              Colors.green,
            );
          } else if (isCorrect && !wasSelected) {
            backgroundColor = theme.colorScheme.onSurface.withValues(
              alpha: 0.05,
            );
            borderColor = theme.colorScheme.onSurface;
            textColor = theme.colorScheme.onSurface;
            fontWeight = FontWeight.w500;
            statusBadge = _buildStatusBadge(
              localizations.correctMissedLabel,
              Colors.green,
            );
          } else if (!isCorrect && wasSelected) {
            backgroundColor = Colors.red.withValues(alpha: 0.1);
            borderColor = Colors.red;
            iconColor = Colors.red;
            textColor = Colors.red.shade800;
            fontWeight = FontWeight.w500;
            statusBadge = _buildStatusBadge(
              localizations.incorrectSelectedLabel,
              Colors.red,
            );
          } else {
            textColor = theme.colorScheme.onSurface;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 4.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: borderColor ?? theme.dividerColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: isMultipleChoice
                        ? BoxShape.rectangle
                        : BoxShape.circle,
                    borderRadius: isMultipleChoice
                        ? BorderRadius.circular(6)
                        : null,
                    border: Border.all(
                      color: borderColor ?? theme.colorScheme.onSurface,
                      width: 2,
                    ),
                    color: Colors.transparent,
                  ),
                  child: iconColor != null
                      ? Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: isMultipleChoice
                                ? BoxShape.rectangle
                                : BoxShape.circle,
                            borderRadius: isMultipleChoice
                                ? BorderRadius.circular(4)
                                : null,
                            color: iconColor,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LaTeXText(
                    QuestionTranslationHelper.translateOption(
                      optionText,
                      localizations,
                    ),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: fontWeight,
                      fontSize: 15,
                    ),
                  ),
                ),
                ?statusBadge,
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
