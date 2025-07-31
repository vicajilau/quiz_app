import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_event.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'quiz_question_result_card.dart';

class QuizCompletedView extends StatelessWidget {
  final QuizExecutionCompleted state;

  const QuizCompletedView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
                    color: state.score >= 70 ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.quizCompleted,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.score(state.score.toStringAsFixed(1)),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: state.score >= 70 ? Colors.green : Colors.orange,
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
          Expanded(
            child: ListView.builder(
              itemCount: state.questionResults.length,
              itemBuilder: (context, index) {
                final result = state.questionResults[index];
                return QuizQuestionResultCard(
                  result: result,
                  questionNumber: index + 1,
                );
              },
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Get the bloc from the current context since we're inside BlocConsumer
                      final bloc = BlocProvider.of<QuizExecutionBloc>(context);
                      bloc.add(QuizRestarted());
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(AppLocalizations.of(context)!.retry),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.home),
                    label: Text(AppLocalizations.of(context)!.goBack),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
