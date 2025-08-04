import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';

/// Dialog to confirm importing questions from another quiz file
class ImportQuestionsDialog extends StatelessWidget {
  final int questionCount;
  final String fileName;

  const ImportQuestionsDialog({
    super.key,
    required this.questionCount,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(localizations.importQuestionsTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.importQuestionsMessage(questionCount, fileName),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.importQuestionsPositionQuestion,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(null),
          child: Text(localizations.cancelButton),
        ),
        ElevatedButton(
          onPressed: () => context.pop('beginning'),
          child: Text(localizations.importAtBeginning),
        ),
        ElevatedButton(
          onPressed: () => context.pop('end'),
          child: Text(localizations.importAtEnd),
        ),
      ],
    );
  }
}
