import 'package:flutter/material.dart';
import 'package:quiz_app/domain/models/quiz/question_type.dart';
import '../../../../../core/l10n/app_localizations.dart';
import 'question_option_row.dart';

class QuestionOptionsSection extends StatelessWidget {
  final QuestionType questionType;
  final List<TextEditingController> optionControllers;
  final List<UniqueKey> optionKeys;
  final ValueNotifier<List<bool>> correctAnswersNotifier;
  final ValueNotifier<String?> optionsErrorNotifier;
  final Function(int, bool?) onCorrectChanged;
  final VoidCallback onTextChanged;
  final Function(int) onRemove;
  final VoidCallback onAddOption;

  const QuestionOptionsSection({
    super.key,
    required this.questionType,
    required this.optionControllers,
    required this.optionKeys,
    required this.correctAnswersNotifier,
    required this.optionsErrorNotifier,
    required this.onCorrectChanged,
    required this.onTextChanged,
    required this.onRemove,
    required this.onAddOption,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (questionType == QuestionType.essay) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Options header with error display
        ValueListenableBuilder<String?>(
          valueListenable: optionsErrorNotifier,
          builder: (context, optionsError, child) {
            return RepaintBoundary(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.optionsLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (optionsError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        optionsError,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),

        // Option input fields with checkboxes/radio buttons
        ValueListenableBuilder<List<bool>>(
          valueListenable: correctAnswersNotifier,
          builder: (context, correctAnswers, child) {
            return Column(
              children: List.generate(optionControllers.length, (index) {
                return RepaintBoundary(
                  child: QuestionOptionRow(
                    key: optionKeys[index],
                    index: index,
                    controller: optionControllers[index],
                    isCorrect: correctAnswers[index],
                    questionType: questionType,
                    optionsError: optionsErrorNotifier.value,
                    canRemove: optionControllers.length > 2,
                    onCorrectChanged: (value) => onCorrectChanged(index, value),
                    onTextChanged: onTextChanged,
                    onRemove: () => onRemove(index),
                  ),
                );
              }),
            );
          },
        ),

        // Add option button (only for multiple/single choice)
        if (questionType == QuestionType.multipleChoice ||
            questionType == QuestionType.singleChoice)
          RepaintBoundary(
            child: TextButton.icon(
              onPressed: onAddOption,
              icon: const Icon(Icons.add),
              label: Text(localizations.addOption),
            ),
          ),
      ],
    );
  }
}
