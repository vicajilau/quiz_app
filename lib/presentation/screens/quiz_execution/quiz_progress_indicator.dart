import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/questions_overview_bottom_sheet.dart';

class QuizProgressIndicator extends StatelessWidget {
  final QuizExecutionInProgress state;

  const QuizProgressIndicator({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF71717A); // Zinc-400 : Zinc-500
    final barBgColor = isDark
        ? const Color(0xFF27272A)
        : const Color(0xFFE4E4E7); // Zinc-800 : Zinc-200

    return GestureDetector(
      onTap: state.isStudyMode
          ? () {
              QuestionsOverviewBottomSheet.show(
                context,
                state,
                context.read<QuizExecutionBloc>(),
              );
            }
          : null,
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Left aligned
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Question ${state.currentQuestionIndex + 1} of ${state.totalQuestions}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 300, // Fixed width from design (zntsx)
                height: 8,
                child: LinearProgressIndicator(
                  value: state.progress,
                  backgroundColor: barBgColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF8B5CF6), // Primary Lilac
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
