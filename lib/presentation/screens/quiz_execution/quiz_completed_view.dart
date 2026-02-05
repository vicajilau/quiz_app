import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_event.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/quiz_question_result_card.dart';

class QuizCompletedView extends StatelessWidget {
  final QuizExecutionCompleted state;

  const QuizCompletedView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Scrollable content area
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Results header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(
                            state.score >= 70 ? Icons.celebration : Icons.info,
                            size: 64,
                            color: state.score >= 70
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.quizCompleted,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.score(state.score.toStringAsFixed(1)),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: state.score >= 70
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.correctAnswers(
                              state.correctAnswers,
                              state.totalQuestions,
                            ),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Question results
                  ...state.questionResults.asMap().entries.map((entry) {
                    final index = entry.key;
                    final result = entry.value;
                    return QuizQuestionResultCard(
                      result: result,
                      questionNumber: index + 1,
                    );
                  }),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Fixed action buttons at bottom
          IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                // First column of buttons (Repetir y Reintentar errores)
                Expanded(
                  child: Flex(
                    direction: Axis.horizontal,
                    spacing: 12,
                    children: [
                      Flexible(
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Get the bloc from the current context since we're inside BlocConsumer
                              final bloc = BlocProvider.of<QuizExecutionBloc>(
                                context,
                              );
                              bloc.add(QuizRestarted());
                            },
                            icon: const Icon(Icons.refresh),
                            label: Text(AppLocalizations.of(context)!.retry),
                          ),
                        ),
                      ),
                      // Second row - button for failed questions
                      if (_hasIncorrectAnswers())
                        Flexible(
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _startFailedQuestionsQuiz(context),
                              icon: const Icon(Icons.quiz),
                              label: Text(
                                AppLocalizations.of(
                                  context,
                                )!.retryFailedQuestions,
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange,
                                side: const BorderSide(color: Colors.orange),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.home),
                  label: Text(AppLocalizations.of(context)!.goBack),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Check if there are any incorrect answers
  bool _hasIncorrectAnswers() {
    return state.questionResults.any((result) => !result.isCorrect);
  }

  /// Start a new quiz with only the failed questions
  void _startFailedQuestionsQuiz(BuildContext context) {
    // Get only the questions that were answered incorrectly
    final failedQuestions = state.questionResults
        .where((result) => !result.isCorrect)
        .map((result) => result.question)
        .toList();

    if (failedQuestions.isNotEmpty) {
      // Start a new quiz with only the failed questions
      final bloc = BlocProvider.of<QuizExecutionBloc>(context);
      bloc.add(QuizExecutionStarted(failedQuestions));
    }
  }
}
