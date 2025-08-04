import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/models/quiz/question_type.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_event.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_state.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../utils/question_translation_helper.dart';

class QuizQuestionOptions extends StatelessWidget {
  final QuizExecutionInProgress state;
  final bool showCorrectAnswerCount;

  const QuizQuestionOptions({
    super.key,
    required this.state,
    this.showCorrectAnswerCount = false,
  });

  @override
  Widget build(BuildContext context) {
    final questionType = state.currentQuestion.type;
    final correctAnswersCount = state.currentQuestion.correctAnswers.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show correct answer count hint for multiple choice questions
        if (showCorrectAnswerCount &&
            questionType == QuestionType.multipleChoice &&
            correctAnswersCount > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.correctAnswersCount(correctAnswersCount),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Options list
        Expanded(
          child: ListView.builder(
            itemCount: state.currentQuestion.options.length,
            itemBuilder: (context, index) {
              final option = state.currentQuestion.options[index];
              final isSelected = state.isOptionSelected(index);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Card(
                  elevation: isSelected ? 4 : 1,
                  child: _buildOptionTile(
                    context,
                    questionType,
                    option,
                    index,
                    isSelected,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    QuestionType questionType,
    String option,
    int index,
    bool isSelected,
  ) {
    // For multiple choice questions, use CheckboxListTile
    if (questionType == QuestionType.multipleChoice) {
      final localizations = AppLocalizations.of(context)!;
      return CheckboxListTile(
        title: Text(
          QuestionTranslationHelper.translateOption(option, localizations),
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        value: isSelected,
        onChanged: (bool? value) {
          context.read<QuizExecutionBloc>().add(
            AnswerSelected(index, value ?? false),
          );
        },
        activeColor: Theme.of(context).primaryColor,
        controlAffinity: ListTileControlAffinity.leading,
      );
    }
    // For single choice, true/false, and essay questions, use RadioListTile
    else {
      // Get the currently selected option (if any)
      final currentAnswers = state.currentQuestionAnswers;
      final selectedIndex = currentAnswers.isNotEmpty
          ? currentAnswers.first
          : -1;

      final localizations = AppLocalizations.of(context)!;
      return RadioListTile<int>(
        title: Text(
          QuestionTranslationHelper.translateOption(option, localizations),
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        value: index,
        groupValue: selectedIndex >= 0 ? selectedIndex : null,
        onChanged: (int? value) {
          if (value != null) {
            // For single selection, first deselect all, then select the chosen one
            context.read<QuizExecutionBloc>().add(AnswerSelected(value, true));
          }
        },
        activeColor: Theme.of(context).primaryColor,
        controlAffinity: ListTileControlAffinity.leading,
      );
    }
  }
}
