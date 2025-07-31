import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_event.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_state.dart';

class QuizQuestionOptions extends StatelessWidget {
  final QuizExecutionInProgress state;

  const QuizQuestionOptions({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: state.currentQuestion.options.length,
      itemBuilder: (context, index) {
        final option = state.currentQuestion.options[index];
        final isSelected = state.isOptionSelected(index);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Card(
            elevation: isSelected ? 4 : 1,
            child: CheckboxListTile(
              title: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              value: isSelected,
              onChanged: (bool? value) {
                context.read<QuizExecutionBloc>().add(
                  AnswerSelected(index, value ?? false),
                );
              },
              activeColor: Theme.of(context).primaryColor,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        );
      },
    );
  }
}
