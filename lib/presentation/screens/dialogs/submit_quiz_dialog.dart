import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/core/theme/app_theme.dart';
import 'package:quiz_app/core/theme/extensions/confirm_dialog_colors_extension.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_event.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';

class SubmitQuizDialog {
  static void show(BuildContext context, QuizExecutionBloc bloc) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final colors = context.appColors;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Title + Close Button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.finishQuiz,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: colors.title,
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: colors.surface,
                        fixedSize: const Size(40, 40),
                        padding: EdgeInsets.zero,
                      ),
                      icon: Icon(Icons.close, size: 20, color: colors.subtitle),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Content
                Builder(
                  builder: (context) {
                    final state = bloc.state;
                    int unansweredCount = 0;
                    if (state is QuizExecutionInProgress) {
                      unansweredCount =
                          state.totalQuestions - state.answeredQuestionsCount;
                    }

                    final message = unansweredCount > 0
                        ? AppLocalizations.of(
                            context,
                          )!.finishQuizUnansweredQuestions(unansweredCount)
                        : AppLocalizations.of(context)!.finishQuizConfirmation;

                    return Text(
                      message,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: colors.subtitle,
                        height: 1.5,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Actions (Stacked buttons)
                Column(
                  children: [
                    // Finish Button (Primary)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.pop();
                          bloc.add(QuizSubmitted());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        label: Text(
                          AppLocalizations.of(context)!.finish,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
