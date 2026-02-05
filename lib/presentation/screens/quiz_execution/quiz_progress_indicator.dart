import 'package:flutter/material.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';

class QuizProgressIndicator extends StatelessWidget {
  final QuizExecutionInProgress state;

  const QuizProgressIndicator({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: state.progress,
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: Colors.grey[300],
          ),
          const SizedBox(height: 8),
          Text(
            '${state.currentQuestionIndex + 1} / ${state.totalQuestions}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
