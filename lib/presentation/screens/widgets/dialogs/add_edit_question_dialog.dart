import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/quiz_file.dart';
import 'package:quiz_app/domain/use_cases/validate_question_use_case.dart';
import 'package:quiz_app/domain/models/custom_exceptions/question_error_type.dart';

import '../../../../../core/l10n/app_localizations.dart';

/// Dialog widget for creating or editing a Question.
class AddEditQuestionDialog extends StatefulWidget {
  final Question? question; // Optional question for editing.
  final QuizFile quizFile; // The file containing all questions.
  final int?
  questionPosition; // Optional index for editing a specific question.

  /// Constructor for the dialog.
  const AddEditQuestionDialog({
    super.key,
    this.question,
    required this.quizFile,
    this.questionPosition,
  });

  @override
  State<AddEditQuestionDialog> createState() => _AddEditQuestionDialogState();
}

class _AddEditQuestionDialogState extends State<AddEditQuestionDialog> {
  late TextEditingController
  _questionTextController; // Controller for the question text input field.
  late List<TextEditingController>
  _optionControllers; // Controllers for option input fields.
  late List<bool> _correctAnswers; // List of booleans for correct answers.

  String? _questionTextError; // Error message for the question text field.
  String? _optionsError; // Error message for the options field.

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers.
    _questionTextController = TextEditingController();

    if (widget.question != null) {
      _questionTextController.text = widget.question!.text;
      _optionControllers = widget.question!.options
          .map((option) => TextEditingController(text: option))
          .toList();
      _correctAnswers = List.generate(
        widget.question!.options.length,
        (index) => widget.question!.correctAnswers.contains(index),
      );
    } else {
      // Default: 4 empty options
      _optionControllers = List.generate(4, (index) => TextEditingController());
      _correctAnswers = List.generate(4, (index) => false);
    }
  }

  @override
  void dispose() {
    // Dispose of the text controllers to free up resources.
    _questionTextController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Validate the input fields.
  bool _validateInput() {
    // Reset error messages.
    setState(() {
      _questionTextError = null;
      _optionsError = null;
    });

    // Get option texts and correct answer indices
    final options = _optionControllers
        .map((controller) => controller.text)
        .toList();
    final correctAnswers = <int>[];
    for (int i = 0; i < _correctAnswers.length; i++) {
      if (_correctAnswers[i]) {
        correctAnswers.add(i);
      }
    }

    final validateInput = ValidateQuestionUseCase.validateQuestion(
      _questionTextController.text,
      options,
      correctAnswers,
      widget.questionPosition,
      widget.quizFile,
    );

    if (validateInput.success) return true;

    setState(() {
      switch (validateInput.errorType) {
        case QuestionErrorType.emptyText:
          _questionTextError = validateInput.getDescriptionForInputError(
            context,
          );
        case QuestionErrorType.duplicatedText:
          _questionTextError = validateInput.getDescriptionForInputError(
            context,
          );
        case QuestionErrorType.insufficientOptions:
        case QuestionErrorType.invalidCorrectAnswers:
        case QuestionErrorType.emptyOption:
          _optionsError = validateInput.getDescriptionForInputError(context);
      }
    });
    return false;
  }

  /// Submit the form if input is valid.
  void _submit() {
    if (_validateInput()) {
      // Get option texts and correct answer indices
      final options = _optionControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
      final correctAnswers = <int>[];
      for (int i = 0; i < _correctAnswers.length && i < options.length; i++) {
        if (_correctAnswers[i]) {
          correctAnswers.add(i);
        }
      }

      // Create a new or updated question instance.
      final newOrUpdatedQuestion = Question(
        type: "multiple_choice",
        text: _questionTextController.text.trim(),
        options: options,
        correctAnswers: correctAnswers,
      );
      context.pop(
        newOrUpdatedQuestion,
      ); // Return the new/updated question to the previous context.
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.question == null ? "Add Question" : "Edit Question",
      ), // Title of the dialog.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Question text input field.
            TextFormField(
              controller: _questionTextController,
              decoration: InputDecoration(
                labelText: "Question Text",
                errorText: _questionTextError,
                errorMaxLines: 2,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  _questionTextError = null; // Clear error when the user types.
                });
              },
            ),
            const SizedBox(height: 16),

            // Options section
            Text("Options", style: Theme.of(context).textTheme.titleMedium),
            if (_optionsError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _optionsError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 8),

            // Option input fields with checkboxes
            ...List.generate(_optionControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: _correctAnswers[index],
                      onChanged: (value) {
                        setState(() {
                          _correctAnswers[index] = value ?? false;
                          _optionsError = null;
                        });
                      },
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _optionControllers[index],
                        decoration: InputDecoration(
                          labelText: "Option ${index + 1}",
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _optionsError = null;
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _optionControllers.length > 2
                          ? () => _removeOption(index)
                          : null,
                    ),
                  ],
                ),
              );
            }),

            // Add option button
            TextButton.icon(
              onPressed: _addOption,
              icon: const Icon(Icons.add),
              label: const Text("Add Option"),
            ),
          ],
        ),
      ),
      actions: [
        // Cancel button to close the dialog without saving.
        TextButton(
          onPressed: () => context.pop(),
          child: Text(AppLocalizations.of(context)!.cancelButton),
        ),
        // Save button to submit the form.
        ElevatedButton(
          onPressed: _submit,
          child: Text(AppLocalizations.of(context)!.saveButton),
        ),
      ],
    );
  }

  /// Add a new option field
  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
      _correctAnswers.add(false);
    });
  }

  /// Remove an option field
  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
        _correctAnswers.removeAt(index);
      });
    }
  }
}
