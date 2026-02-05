import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_event.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'package:quiz_app/presentation/screens/dialogs/submit_quiz_dialog.dart';

class QuizNavigationButtons extends StatelessWidget {
  final QuizExecutionInProgress state;
  final bool isStudyMode;

  const QuizNavigationButtons({
    super.key,
    required this.state,
    this.isStudyMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Check Answer button (Only in Study Mode and not validated, full width)
          if (isStudyMode && !state.isCurrentQuestionValidated) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<QuizExecutionBloc>().add(CheckAnswerRequested());
                },
                icon: const Icon(Icons.check_circle_outline),
                label: Text(AppLocalizations.of(context)!.checkAnswer),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          Row(
            children: [
              // Previous button
              if (!state.isFirstQuestion) ...[
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
                const SizedBox(width: 8),
              ],

              // Next/Submit button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (isStudyMode || state.hasCurrentQuestionAnswered)
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
                      : null, // Disable button if no answer selected (only in Exam Mode)
                  icon: Icon(
                    state.isLastQuestion ? Icons.check : Icons.arrow_forward,
                  ),
                  label: Text(_getLabel(context)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getLabel(BuildContext context) {
    if (state.isLastQuestion) {
      return AppLocalizations.of(context)!.finish;
    }
    if (isStudyMode &&
        !state.hasCurrentQuestionAnswered &&
        !state.isCurrentQuestionValidated) {
      return AppLocalizations.of(context)!.skip;
    }
    return AppLocalizations.of(context)!.next;
  }
}
