import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'package:quiz_app/presentation/screens/dialogs/abandon_quiz_dialog.dart';

class BackPressHandler {
  static Future<void> handle(
    BuildContext context,
    QuizExecutionBloc bloc,
  ) async {
    final state = bloc.state;

    if (state is QuizExecutionInProgress) {
      final shouldExit = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const AbandonQuizDialog(),
      );

      if (shouldExit == true && context.mounted) {
        context.pop();
      }
    } else {
      context.pop();
    }
  }
}
