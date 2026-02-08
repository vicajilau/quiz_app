import 'package:flutter/material.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/widgets/quiz_question_essay_result.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/widgets/quiz_question_explanation.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/widgets/quiz_question_image.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/widgets/quiz_question_options_result.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/domain/models/quiz/question_type.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'package:quiz_app/presentation/widgets/latex_text.dart';

/// A card widget that displays the result of a quiz question.
///
/// It shows the question text, image (if any), the student's answer,
/// the correct answer, and an explanation. It uses various sub-widgets
/// to handle different parts of the display.
class QuizQuestionResultCard extends StatelessWidget {
  /// The question result data.
  final QuestionResult result;

  /// The number of the question in the quiz.
  final int questionNumber;

  /// Creates a [QuizQuestionResultCard] widget.
  const QuizQuestionResultCard({
    super.key,
    required this.result,
    required this.questionNumber,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final successColor = Colors.green;
    final errorColor = Colors.red;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      color: theme.cardColor,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (result.isCorrect ? successColor : errorColor)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              result.isCorrect ? Icons.check : Icons.close,
              color: result.isCorrect ? successColor : errorColor,
              size: 20,
            ),
          ),
          title: Text(
            AppLocalizations.of(context)!.questionNumber(questionNumber),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: LaTeXText(
            result.question.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  LaTeXText(
                    result.question.text,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Show image if available
                  if (result.question.image != null)
                    QuizQuestionImage(imageData: result.question.image),

                  // Handle essay questions differently
                  if (result.question.type == QuestionType.essay)
                    QuizQuestionEssayResult(result: result)
                  else
                    QuizQuestionOptionsResult(result: result),

                  // Show explanation if available
                  QuizQuestionExplanation(
                    explanation: result.question.explanation,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
