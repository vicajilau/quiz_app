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

  /// Whether the AI assistant is available (enabled and has API keys configured).
  final bool isAiAvailable;

  /// Creates an [AiAssistantButton].
  const AiAssistantButton({
    super.key,
    required this.question,
    this.isAiAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: TextButton.icon(
          onPressed: () {
            if (!isAiAvailable) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.aiRequiresAtLeastOneApiKeyError,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
              return;
            }

            showDialog(
              context: context,
              builder: (context) => AIQuestionDialog(question: question),
            );
          },
          icon: const Icon(Icons.auto_awesome),
          label: Text(l10n.askAiAssistant),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
