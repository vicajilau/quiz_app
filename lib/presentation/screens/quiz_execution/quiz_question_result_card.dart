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
        subtitle: Align(
          alignment: Alignment.centerLeft,
          child: LaTeXText(
            result.question.text,
            maxLines: 2,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: LaTeXText(
                    result.question.text,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
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
    );
  }
}
