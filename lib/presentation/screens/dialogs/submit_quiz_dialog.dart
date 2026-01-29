import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_event.dart';

class SubmitQuizDialog {
  static void show(BuildContext context, QuizExecutionBloc bloc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.finishQuiz),
          content: Text(AppLocalizations.of(context)!.finishQuizConfirmation),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                context.pop();
                bloc.add(QuizSubmitted());
              },
              child: Text(AppLocalizations.of(context)!.finish),
            ),
          ],
        );
      },
    );
  }
}
