import 'package:flutter/material.dart';

import 'package:quiz_app/core/l10n/app_localizations.dart';

class AbandonQuizDialog extends StatelessWidget {
  const AbandonQuizDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.abandonQuiz),
      content: Text(
        AppLocalizations.of(context)!.abandonQuizConfirmation,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(AppLocalizations.of(context)!.abandon),
        ),
      ],
    );
  }
}
