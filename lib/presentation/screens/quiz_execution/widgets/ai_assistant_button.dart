import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../domain/models/quiz/question.dart';
import '../../dialogs/ai_question_dialog.dart';

/// A button that triggers the AI Assistant dialog for a specific question.
///
/// This button is typically displayed when the user wants to ask for help or hints
/// regarding the current question.
class AiAssistantButton extends StatelessWidget {
  /// The question for which the AI assistance is requested.
  final Question question;

  /// Creates an [AiAssistantButton].
  const AiAssistantButton({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: TextButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AIQuestionDialog(question: question),
            );
          },
          icon: const Icon(Icons.auto_awesome),
          label: Text(AppLocalizations.of(context)!.askAiAssistant),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
