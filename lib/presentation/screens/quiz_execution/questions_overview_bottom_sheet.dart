import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_event.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';

class QuestionsOverviewBottomSheet extends StatelessWidget {
  final QuizExecutionInProgress state;

  const QuestionsOverviewBottomSheet({super.key, required this.state});

  static void show(
    BuildContext context,
    QuizExecutionInProgress state,
    QuizExecutionBloc bloc,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => BlocProvider.value(
        value: bloc,
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) =>
              QuestionsOverviewBottomSheet(state: state),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Handle bar
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[700] : Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.questionsOverview,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${state.answeredQuestionsCount} / ${state.totalQuestions}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),

        const Divider(),

        // Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 60,
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: state.totalQuestions,
            itemBuilder: (context, index) {
              final isCurrent = index == state.currentQuestionIndex;
              // Use index for checking if answered since Question doesn't have ID
              final isAnswered =
                  state.userAnswers.containsKey(index) &&
                  state.userAnswers[index]!.isNotEmpty;
              final isEssayAnswered =
                  state.essayAnswers.containsKey(index) &&
                  state.essayAnswers[index]!.trim().isNotEmpty;
              final hasAnswer = isAnswered || isEssayAnswered;

              Color bgColor;
              Color textColor;
              Border? border;

              if (isCurrent) {
                bgColor = primaryColor.withValues(alpha: 0.2);
                textColor = primaryColor;
                border = Border.all(color: primaryColor, width: 2);
              } else if (hasAnswer) {
                bgColor = isDark
                    ? const Color(0xFF3F3F46)
                    : const Color(0xFFF4F4F5); // Zinc
                textColor = isDark ? Colors.white : Colors.black87;
                border = Border.all(
                  color: isDark
                      ? const Color(0xFF52525B)
                      : const Color(0xFFE4E4E7),
                );
              } else {
                bgColor = Colors.transparent;
                textColor = isDark ? Colors.grey[500]! : Colors.grey[400]!;
                border = Border.all(
                  color: isDark
                      ? const Color(0xFF27272A)
                      : const Color(0xFFE4E4E7),
                );
              }

              return InkWell(
                onTap: () {
                  // Navigate to question
                  // We need an event for jumping to index, logic might need check
                  // Assuming we can just emit state with new index or similar.
                  // Looking at Bloc events... we might need to add a JumpToQuestion event if not exists.
                  // Or use Next/Prev multiple times (bad).
                  // Let's assume we adding JumpToQuestionRequested event.
                  // NOTE: I'll need to check if JumpToQuestionRequested exists or add it.

                  // For now, let's close sheet and try to find a way to jump.
                  // If JumpToQuestionRequested doesn't exist, I will add it.
                  context.read<QuizExecutionBloc>().add(
                    JumpToQuestionRequested(index),
                  );
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: border,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
