import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_state.dart';

class QuizQuestionResultCard extends StatelessWidget {
  final QuestionResult result;
  final int questionNumber;

  const QuizQuestionResultCard({
    super.key,
    required this.result,
    required this.questionNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        leading: Icon(
          result.isCorrect ? Icons.check_circle : Icons.cancel,
          color: result.isCorrect ? Colors.green : Colors.red,
        ),
        title: Text(
          AppLocalizations.of(context)!.questionNumber(questionNumber),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          result.question.text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.question(result.question.text),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                // Show all options with indicators
                ...result.question.options.asMap().entries.map((entry) {
                  final optionIndex = entry.key;
                  final optionText = entry.value;
                  final isCorrect = result.correctAnswers.contains(optionIndex);
                  final wasSelected = result.userAnswers.contains(optionIndex);

                  Color? backgroundColor;
                  IconData? icon;

                  if (isCorrect && wasSelected) {
                    backgroundColor = Colors.green.withValues(alpha: 0.1);
                    icon = Icons.check_circle;
                  } else if (isCorrect && !wasSelected) {
                    backgroundColor = Colors.green.withValues(alpha: 0.1);
                    icon = Icons.check_circle_outline;
                  } else if (!isCorrect && wasSelected) {
                    backgroundColor = Colors.red.withValues(alpha: 0.1);
                    icon = Icons.cancel;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 4.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Row(
                      children: [
                        if (icon != null)
                          Icon(
                            icon,
                            size: 20,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(optionText)),
                      ],
                    ),
                  );
                }),

                // Show explanation if available
                if (result.question.explanation.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.explanationTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result.question.explanation,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
