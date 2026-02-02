import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';

import '../../../domain/models/quiz/quiz_config.dart';
import '../../../data/services/configuration_service.dart';
import '../../../domain/models/quiz/quiz_config_stored_settings.dart';

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
  late TextEditingController _customCountController;

  @override
  void initState() {
    super.initState();
    _customCountController = TextEditingController();
    // Set default to all questions initially
    selectedCount = widget.totalQuestions;
    _loadSavedSettings();
  }

  @override
  void dispose() {
    _customCountController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedSettings() async {
    final settings = await ConfigurationService.instance
        .getQuizConfigSettings();
    if (mounted) {
      setState(() {
        if (settings.questionCount != null) {
          // Specific count saved
          selectedCount = settings.questionCount!;
          _customCountController.text = selectedCount.toString();
        } else {
          // "All Questions" mode (default)
          selectedCount = widget.totalQuestions;
          _customCountController.clear();
        }
        if (settings.isStudyMode != null) {
          _isStudyMode = settings.isStudyMode!;
        }
      });
    }
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
                    _customCountController.clear();
                    _inputError = null;
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
              controller: _customCountController,
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
                  return;
                }
                setState(() {
                  _inputError = value.isEmpty ? null : value;
                  selectedCount = widget.totalQuestions;
                });
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
              // Determine value to save
              // If text field is empty, it means we selected "All Questions" cleanly
              // (or cleared custom input). We save -1 to represent "All".
              // If text field has content, we save the specific number.
              final int? countToSave = _customCountController.text.isEmpty
                  ? null
                  : selectedCount;

              // Save settings
              ConfigurationService.instance.saveQuizConfigSettings(
                QuizConfigStoredSettings(
                  questionCount: countToSave,
                  isStudyMode: _isStudyMode,
                ),
              );

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
