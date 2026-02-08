import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_event.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/quiz_question_result_card.dart';

class QuizCompletedView extends StatelessWidget {
  const QuizCompletedView({super.key, required this.state});

  final QuizExecutionCompleted state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final secondaryTextColor = theme.hintColor;
    final successColor = Colors.green;
    final alertColor = Colors.orange;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.quizCompleted,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.dividerColor),
                ),
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        ),

        // Scrollable content area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                // Score Card
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      // Circular Score
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: CircularProgressIndicator(
                              value: state.score / 100,
                              strokeWidth: 12,
                              backgroundColor: theme.dividerColor.withValues(
                                alpha: 0.1,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                state.score >= 70 ? successColor : alertColor,
                              ),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${state.score.toStringAsFixed(0)}%',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: state.score >= 70
                                      ? successColor
                                      : alertColor,
                                ),
                              ),
                              Text(
                                '${state.correctAnswers}/${state.totalQuestions}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        state.score >= 70
                            ? AppLocalizations.of(context)!.congratulations
                            : AppLocalizations.of(context)!.keepPracticing,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.correctAnswers(
                          state.correctAnswers,
                          state.totalQuestions,
                        ),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Question results
                ...state.questionResults.asMap().entries.map((entry) {
                  final index = entry.key;
                  final result = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: QuizQuestionResultCard(
                      result: result,
                      questionNumber: index + 1,
                    ),
                  );
                }),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Action buttons at bottom
        Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              final hasIncorrect = _hasIncorrectAnswers();

              // Define buttons
              final tryAgainBtn = _buildTryAgainButton(context);
              final retryBtn = _buildRetryButton(context, isDarkMode);
              final homeBtn = _buildHomeButton(context, isDarkMode);

              // Responsive Layout Logic:
              // Mobile AND has incorrect answers (3 buttons total) -> 2 Rows
              if (isMobile && hasIncorrect) {
                return Column(
                  children: [
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(child: tryAgainBtn),
                        Expanded(child: retryBtn!),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(children: [Expanded(child: homeBtn)]),
                  ],
                );
              }

              // Desktop OR no incorrect answers (2 buttons) -> 1 Row
              return Row(
                spacing: 12,
                children: [
                  if (hasIncorrect) Expanded(child: tryAgainBtn),
                  if (hasIncorrect) Expanded(child: retryBtn!),
                  Expanded(child: homeBtn),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTryAgainButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        final bloc = BlocProvider.of<QuizExecutionBloc>(context);
        bloc.add(QuizRestarted());
      },
      icon: const Icon(Icons.refresh, size: 20),
      label: Text(
        AppLocalizations.of(context)!.tryAgain,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 25),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget? _buildRetryButton(BuildContext context, bool isDarkMode) {
    if (!_hasIncorrectAnswers()) return null;
    return OutlinedButton.icon(
      onPressed: () => _startFailedQuestionsQuiz(context),
      icon: const Icon(Icons.quiz_outlined, size: 20),
      label: Text(
        AppLocalizations.of(context)!.retryFailedQuestions,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: isDarkMode
            ? const Color(0xFF27272A)
            : const Color(0xFFF4F4F5),
        foregroundColor: isDarkMode
            ? const Color(0xFFA1A1AA)
            : const Color(0xFF71717A),
        side: BorderSide(
          color: isDarkMode ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
          width: 2,
        ),
        padding: const EdgeInsets.symmetric(vertical: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context, bool isDarkMode) {
    return OutlinedButton.icon(
      onPressed: () => context.pop(),
      icon: const Icon(Icons.home_outlined, size: 20),
      label: Text(
        AppLocalizations.of(context)!.home,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: isDarkMode
            ? const Color(0xFF27272A)
            : const Color(0xFFF4F4F5),
        foregroundColor: isDarkMode
            ? const Color(0xFFA1A1AA)
            : const Color(0xFF71717A),
        side: BorderSide(
          color: isDarkMode ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
          width: 2,
        ),
        padding: const EdgeInsets.symmetric(vertical: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      bloc.add(
        QuizExecutionStarted(failedQuestions, isStudyMode: state.isStudyMode),
      );
    }
  }
}
