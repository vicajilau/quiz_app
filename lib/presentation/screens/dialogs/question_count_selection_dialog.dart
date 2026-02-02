import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';

import '../../../domain/models/quiz/quiz_config.dart';

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
  bool _isStudyMode = false; // Default to Exam Mode
  String? _inputError; // Track input validation errors

  @override
  void initState() {
    super.initState();
    // Set default to all questions
    selectedCount = widget.totalQuestions;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.selectQuestionCountTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.selectQuestionCountMessage),
            const SizedBox(height: 16),

            // Only show "All Questions" option
            RadioGroup(
              groupValue: selectedCount,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCount = value;
                  });
                }
              },
              child: RadioListTile<int>(
                title: Text(
                  AppLocalizations.of(
                    context,
                  )!.allQuestions(widget.totalQuestions),
                ),
                value: widget.totalQuestions,
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
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            // Quiz Mode Selection
            Text(
              AppLocalizations.of(context)!.quizModeTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            RadioGroup<bool>(
              groupValue: _isStudyMode,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _isStudyMode = value;
                  });
                }
              },
              child: Column(
                children: [
                  RadioListTile<bool>(
                    title: Text(AppLocalizations.of(context)!.examModeLabel),
                    subtitle: Text(
                      AppLocalizations.of(context)!.examModeDescription,
                    ),
                    value: false,
                    activeColor: Theme.of(context).colorScheme.primary,
                    secondary: Icon(
                      Icons.timer,
                      color: !_isStudyMode
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  RadioListTile<bool>(
                    title: Text(AppLocalizations.of(context)!.studyModeLabel),
                    subtitle: Text(
                      AppLocalizations.of(context)!.studyModeDescription,
                    ),
                    value: true,
                    activeColor: Theme.of(context).colorScheme.primary,
                    secondary: Icon(
                      Icons.school,
                      color: _isStudyMode
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(null),
          child: Text(AppLocalizations.of(context)!.cancelButton),
        ),
        ElevatedButton(
          onPressed: () {
            if (_inputError == null) {
              context.pop(
                QuizConfig(
                  questionCount: selectedCount,
                  isStudyMode: _isStudyMode,
                ),
              );
            }
          },
          child: Text(AppLocalizations.of(context)!.startQuiz),
        ),
      ],
    );
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
