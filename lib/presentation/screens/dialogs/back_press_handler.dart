import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_state.dart';

class BackPressHandler {
  static void handle(BuildContext context, QuizExecutionBloc bloc) {
    final state = bloc.state;

    if (state is QuizExecutionInProgress) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.abandonQuiz),
            content: Text(
              AppLocalizations.of(context)!.abandonQuizConfirmation,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pop();
                },
                child: Text(AppLocalizations.of(context)!.abandon),
              ),
            ],
          );
        },
      );
    } else {
      context.pop();
    }
  }
}
