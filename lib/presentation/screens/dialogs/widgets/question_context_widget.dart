import 'package:flutter/material.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/question_type.dart';
import 'package:quiz_app/presentation/widgets/latex_text.dart';

/// A widget that displays the context of the question being discussed.
///
/// This includes the [question] text and its options (if applicable),
/// formatted with LaTeX support.
class QuestionContextWidget extends StatelessWidget {
  /// The question object containing the text and options to display.
  final Question question;

  /// Creates a [QuestionContextWidget].
  const QuestionContextWidget({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.questionContext,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          LaTeXText(
            question.text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (question.options.isNotEmpty &&
              question.type != QuestionType.essay) ...[
            const SizedBox(height: 12),
            ...question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final letter = String.fromCharCode(65 + index);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: LaTeXText(
                  '$letter) $option',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
