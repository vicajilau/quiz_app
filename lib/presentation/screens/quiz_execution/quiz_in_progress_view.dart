import 'package:flutter/material.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'quiz_progress_indicator.dart';
import 'quiz_question_header.dart';
import 'quiz_options_wrapper.dart';
import 'quiz_navigation_buttons.dart';

class QuizInProgressView extends StatelessWidget {
  final QuizExecutionInProgress state;

  const QuizInProgressView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress indicator (fixed)
        QuizProgressIndicator(state: state),

        // Main content area (flexible)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QuizQuestionHeader(state: state),

                const SizedBox(height: 16),

                // Options section
                QuizOptionsWrapper(state: state),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Navigation buttons (fixed at bottom)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: QuizNavigationButtons(state: state),
        ),
      ],
    );
  }
}
