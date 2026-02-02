import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/models/quiz/question_type.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import '../../../blocs/quiz_execution_bloc/quiz_execution_event.dart';
import '../../../blocs/quiz_execution_bloc/quiz_execution_state.dart';
import '../../../utils/question_translation_helper.dart';
import '../../../widgets/latex_text.dart';

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

    final optionTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
    );

    // For multiple choice questions, use CheckboxListTile
    if (questionType == QuestionType.multipleChoice) {
      Color? tileColor;
      Color? activeColor;

      if (isStudyMode && state.isCurrentQuestionValidated) {
        final isCorrect = state.currentQuestion.correctAnswers.contains(index);
        if (isSelected) {
          tileColor = isCorrect
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.red.withValues(alpha: 0.2);
          activeColor = isCorrect ? Colors.green : Colors.red;
        } else if (isCorrect) {
          // Show correct answer even if not selected
          tileColor = Colors.green.withValues(alpha: 0.2);
          activeColor = Colors.green;
        }
      }

      return CheckboxListTile(
        title: IgnorePointer(
          child: LaTeXText(translatedOption, style: optionTextStyle),
        ),
        value: isSelected,
        onChanged: (bool? value) {
          context.read<QuizExecutionBloc>().add(
            AnswerSelected(index, value ?? false),
          );
        },
        activeColor: activeColor ?? Theme.of(context).primaryColor,
        tileColor: tileColor,
        controlAffinity: ListTileControlAffinity.leading,
      );
    }
    // For single choice, true/false, and essay questions, use RadioListTile
    else {
      Color? tileColor;
      Color? activeColor;

      if (isStudyMode) {
        final isCorrect = state.currentQuestion.correctAnswers.contains(index);
        final isValidated = state.isCurrentQuestionValidated;

        if (isValidated) {
          if (isSelected) {
            tileColor = isCorrect
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.red.withValues(alpha: 0.2);
            activeColor = isCorrect ? Colors.green : Colors.red;
          } else if (isCorrect) {
            // Show correct answer even if not selected
            tileColor = Colors.green.withValues(alpha: 0.2);
            activeColor = Colors.green;
          }
        }
      }

      return RadioListTile<int>(
        title: IgnorePointer(
          child: LaTeXText(translatedOption, style: optionTextStyle),
        ),
        value: index,
        activeColor: activeColor ?? Theme.of(context).primaryColor,
        tileColor: tileColor,
        controlAffinity: ListTileControlAffinity.leading,
      );
    }
  }
}
