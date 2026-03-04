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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizdy/domain/models/quiz/question_type.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/presentation/blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import 'package:quizdy/presentation/blocs/quiz_execution_bloc/quiz_execution_event.dart';
import 'package:quizdy/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'package:quizdy/presentation/utils/question_translation_helper.dart';
import 'package:quizdy/presentation/widgets/latex_text.dart';

/// A widget representing a single option in a quiz question.
///
/// It handles the display of the option text (supporting LaTeX), as well as
/// visual feedback for selection state and correctness (in Study Mode).
///
/// This widget adapts its appearance based on [questionType] (Checkbox for
/// multiple choice, Radio for others).
class QuestionOptionTile extends StatelessWidget {
  /// The type of the question (e.g., multiple choice, single choice).
  final QuestionType questionType;

  /// The text content of the option.
  final String option;

  /// The index of this option in the question's option list.
  final int index;

  /// Whether this option is currently selected by the user.
  final bool isSelected;

  /// Whether the quiz is currently in Study Mode (which shows immediate feedback).
  final bool isStudyMode;

  /// The current execution state of the quiz.
  final QuizExecutionInProgress state;

  /// Creates a [QuestionOptionTile].
  const QuestionOptionTile({
    super.key,
    required this.questionType,
    required this.option,
    required this.index,
    required this.isSelected,
    required this.isStudyMode,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final translatedOption = QuestionTranslationHelper.translateOption(
      option,
      localizations,
    );

    final isValidatedStudyMode =
        isStudyMode && state.isCurrentQuestionValidated;
    final isCorrect = isValidatedStudyMode
        ? state.currentQuestion.correctAnswers.contains(index)
        : false;

    FontWeight fontWeight = isSelected ? FontWeight.w600 : FontWeight.normal;
    Color borderColor = Theme.of(context).dividerColor.withValues(alpha: 0.5);
    Color backgroundColor = Theme.of(context).cardColor;
    Color? iconColor;

    Icon? indicatorIcon;
    Widget? statusBadge;

    if (isValidatedStudyMode) {
      if (isCorrect && isSelected) {
        // Correct answer selected - Bright green
        backgroundColor = Colors.green.withValues(alpha: 0.15);
        borderColor = Colors.green;
        iconColor = Colors.green;
        fontWeight = FontWeight.w600;
        indicatorIcon = Icon(
          questionType == QuestionType.multipleChoice
              ? Icons.square_rounded
              : Icons.circle,
          size: 16,
          color: Colors.green,
        );
        statusBadge = _buildStatusBadge(
          localizations.correctSelectedLabel,
          Colors.green,
        );
      } else if (isCorrect && !isSelected) {
        // Correct answer NOT selected - Orange/Yellow (missed)
        borderColor = Theme.of(context).colorScheme.onSurface;
        backgroundColor = Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.05);
        iconColor = Theme.of(context).colorScheme.onSurface;
        statusBadge = _buildStatusBadge(
          localizations.correctSelectedLabel,
          Colors.green,
        );
      } else if (!isCorrect && isSelected) {
        // Incorrect answer selected - Red
        borderColor = Colors.red;
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        iconColor = Colors.red;
        fontWeight = FontWeight.w500;
        indicatorIcon = Icon(
          questionType == QuestionType.multipleChoice
              ? Icons.square_rounded
              : Icons.circle,
          size: 16,
          color: Colors.red,
        );
        statusBadge = _buildStatusBadge(
          localizations.incorrectSelectedLabel,
          Colors.red,
        );
      }
    } else if (isSelected) {
      borderColor = Theme.of(context).primaryColor;
      backgroundColor = Theme.of(context).primaryColor.withValues(alpha: 0.05);
      iconColor = Theme.of(context).primaryColor;
      indicatorIcon = Icon(
        questionType == QuestionType.multipleChoice
            ? Icons.square_rounded
            : Icons.circle,
        size: 16,
        color: Theme.of(context).primaryColor,
      );
    }

    final optionTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: fontWeight,
      color: isSelected ? (iconColor ?? Theme.of(context).primaryColor) : null,
      fontFamily: 'Inter',
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isValidatedStudyMode) return;
          context.read<QuizExecutionBloc>().add(
            AnswerSelected(index, !isSelected),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: borderColor,
              width: isValidatedStudyMode ? 1.5 : (isSelected ? 2 : 1),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Indicator (Radio or Checkbox look-alike)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: questionType == QuestionType.multipleChoice
                      ? BoxShape.rectangle
                      : BoxShape.circle,
                  borderRadius: questionType == QuestionType.multipleChoice
                      ? BorderRadius.circular(6)
                      : null,
                  border: Border.all(
                    color: isValidatedStudyMode
                        ? borderColor
                        : (isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade400),
                    width: 2,
                  ),
                  color: Colors.transparent,
                ),
                child: indicatorIcon,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LaTeXText(translatedOption, style: optionTextStyle),
              ),
              ?statusBadge,
            ],
          ),
        ),
      ),
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
