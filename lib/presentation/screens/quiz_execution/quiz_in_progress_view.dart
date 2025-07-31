import 'package:flutter/material.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'quiz_progress_indicator.dart';
import 'quiz_question_header.dart';
import 'quiz_question_options.dart';
import 'quiz_navigation_buttons.dart';

class QuizInProgressView extends StatelessWidget {
  final QuizExecutionInProgress state;

  const QuizInProgressView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress indicator
        QuizProgressIndicator(state: state),

        // Question content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question number and text
                QuizQuestionHeader(state: state),

                const SizedBox(height: 24),

                // Options
                Expanded(child: QuizQuestionOptions(state: state)),

                // Navigation buttons
                QuizNavigationButtons(state: state),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
