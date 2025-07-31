import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';

class QuestionCountSelectionDialog extends StatefulWidget {
  final int totalQuestions;

  const QuestionCountSelectionDialog({super.key, required this.totalQuestions});

  @override
  State<QuestionCountSelectionDialog> createState() =>
      _QuestionCountSelectionDialogState();
}

class _QuestionCountSelectionDialogState
    extends State<QuestionCountSelectionDialog> {
  int selectedCount = 10; // Default value
  String? _inputError; // Track input validation errors

  @override
  void initState() {
    super.initState();
    // Set default to all questions if less than 10, otherwise 10
    selectedCount = widget.totalQuestions <= 10 ? widget.totalQuestions : 10;
  }

  @override
  Widget build(BuildContext context) {
    final suggestedCounts = _getSuggestedCounts();

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.selectQuestionCountTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.selectQuestionCountMessage),
          const SizedBox(height: 16),

          // Radio buttons for suggested counts
          ...suggestedCounts.map(
            (count) => RadioListTile<int>(
              title: Text(
                count == widget.totalQuestions
                    ? AppLocalizations.of(context)!.allQuestions(count)
                    : AppLocalizations.of(context)!.questionsCount(count),
              ),
              value: count,
              groupValue: selectedCount,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCount = value;
                  });
                }
              },
            ),
          ),

          // Custom count option (always available)
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.customNumberLabel,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.numberInputLabel,
              border: const OutlineInputBorder(),
              helperText: AppLocalizations.of(
                context,
              )!.customNumberHelper(widget.totalQuestions),
              helperMaxLines: 2,
              errorText: _getErrorText(),
            ),
            onChanged: (value) {
              final customCount = int.tryParse(value);
              if (customCount != null && customCount > 0) {
                setState(() {
                  selectedCount = customCount;
                  _inputError = null;
                });
              } else if (value.isNotEmpty) {
                setState(() {
                  _inputError = value;
                });
              } else {
                setState(() {
                  _inputError = null;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(null),
          child: Text(AppLocalizations.of(context)!.cancelButton),
        ),
        ElevatedButton(
          onPressed: () => context.pop(selectedCount),
          child: Text(AppLocalizations.of(context)!.startQuiz),
        ),
      ],
    );
  }

  List<int> _getSuggestedCounts() {
    final counts = <int>[];
    final total = widget.totalQuestions;

    // Add common counts that are available
    final suggestions = [5, 10, 15, 20, 25, 30];

    for (final count in suggestions) {
      if (count <= total) {
        counts.add(count);
      }
    }

    // Always add the total count if it's not already included
    if (!counts.contains(total)) {
      counts.add(total);
    }

    return counts;
  }

  String? _getErrorText() {
    if (_inputError == null || _inputError!.isEmpty) {
      return null;
    }

    final number = int.tryParse(_inputError!);
    if (number == null) {
      return AppLocalizations.of(context)!.errorInvalidNumber;
    } else if (number <= 0) {
      return AppLocalizations.of(context)!.errorNumberMustBePositive;
    }

    return null;
  }
}
