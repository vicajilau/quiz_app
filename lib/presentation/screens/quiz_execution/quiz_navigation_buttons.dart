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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isCheckPhase = isStudyMode && !state.isCurrentQuestionValidated;
    final canProceed = isCheckPhase
        ? state.hasCurrentQuestionAnswered
        : (isStudyMode || state.hasCurrentQuestionAnswered);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          if (!state.isFirstQuestion) ...[
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<QuizExecutionBloc>().add(
                      PreviousQuestionRequested(),
                    );
                  },
                  icon: Icon(
                    Icons.chevron_left,
                    color: isDark
                        ? const Color(0xFFA1A1AA)
                        : const Color(0xFF71717A),
                  ),
                  label: Text(
                    AppLocalizations.of(context)!.previous,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFA1A1AA)
                          : const Color(0xFF71717A),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF27272A)
                        : Colors.white,
                    side: BorderSide(
                      color: isDark
                          ? const Color(0xFF3F3F46)
                          : const Color(0xFFE4E4E7),
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],

          // Next / Check / Finish Button
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: canProceed
                    ? () {
                        if (isCheckPhase) {
                          context.read<QuizExecutionBloc>().add(
                            CheckAnswerRequested(),
                          );
                        } else if (state.isLastQuestion) {
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
                    : (isCheckPhase && !state.hasCurrentQuestionAnswered
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
                          : null),
                icon: Icon(
                  isCheckPhase
                      ? (state.hasCurrentQuestionAnswered
                            ? Icons.check_circle
                            : (state.isLastQuestion
                                  ? Icons.check
                                  : Icons.skip_next))
                      : (state.isLastQuestion
                            ? Icons.check
                            : Icons.chevron_right),
                  color: Colors.white,
                ),
                label: Text(
                  isCheckPhase
                      ? (state.hasCurrentQuestionAnswered
                            ? AppLocalizations.of(context)!.checkAnswer
                            : (state.isLastQuestion
                                  ? AppLocalizations.of(context)!.finish
                                  : AppLocalizations.of(context)!.skip))
                      : (state.isLastQuestion
                            ? AppLocalizations.of(context)!.finish
                            : AppLocalizations.of(context)!.next),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
