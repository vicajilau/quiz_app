import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import 'package:quiz_app/presentation/screens/dialogs/abandon_quiz_dialog.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';

class BackPressHandler {
  static void handle(BuildContext context, QuizExecutionBloc bloc) {
    final state = bloc.state;

    if (state is QuizExecutionInProgress) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AbandonQuizDialog();
        },
      );
    } else {
      context.pop();
    }
  }
}
