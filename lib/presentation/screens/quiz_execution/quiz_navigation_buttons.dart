import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_event.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_state.dart';
import '../dialogs/submit_quiz_dialog.dart';

class QuizNavigationButtons extends StatelessWidget {
  final QuizExecutionInProgress state;

  const QuizNavigationButtons({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          // Previous button
          if (!state.isFirstQuestion)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<QuizExecutionBloc>().add(
                    PreviousQuestionRequested(),
                  );
                },
                icon: const Icon(Icons.arrow_back),
                label: Text(AppLocalizations.of(context)!.previous),
              ),
            ),

          if (!state.isFirstQuestion) const SizedBox(width: 16),

          // Next/Submit button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: state.hasCurrentQuestionAnswered
                  ? () {
                      if (state.isLastQuestion) {
                        SubmitQuizDialog.show(
                          context,
                          context.read<QuizExecutionBloc>(),
                        );
                      } else {
                        context.read<QuizExecutionBloc>().add(
                          NextQuestionRequested(),
                        );
                      }
                    }
                  : null, // Disable button if no answer selected
              icon: Icon(
                state.isLastQuestion ? Icons.check : Icons.arrow_forward,
              ),
              label: Text(
                state.isLastQuestion
                    ? AppLocalizations.of(context)!.finish
                    : AppLocalizations.of(context)!.next,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
