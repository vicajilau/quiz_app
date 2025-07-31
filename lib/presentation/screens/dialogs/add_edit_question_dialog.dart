import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/quiz_file.dart';
import 'package:quiz_app/domain/use_cases/validate_question_use_case.dart';
import 'package:quiz_app/domain/models/custom_exceptions/question_error_type.dart';

import '../../../../core/l10n/app_localizations.dart';

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
  late TextEditingController
  _explanationController; // Controller for the explanation text input field.
  late List<TextEditingController>
  _optionControllers; // Controllers for option input fields.
  late List<bool> _correctAnswers; // List of booleans for correct answers.

  String? _questionTextError; // Error message for the question text field.
  String? _optionsError; // Error message for the options field.
  String? _imageData; // Base64 image data

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers.
    _questionTextController = TextEditingController();
    _explanationController = TextEditingController();

    if (widget.question != null) {
      _questionTextController.text = widget.question!.text;
      _explanationController.text = widget.question!.explanation;
      _imageData = widget.question!.image;
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
    _explanationController.dispose();
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
      final explanationText = _explanationController.text.trim();
      final newOrUpdatedQuestion = Question(
        type: "multiple_choice",
        text: _questionTextController.text.trim(),
        image: _imageData,
        options: options,
        correctAnswers: correctAnswers,
        explanation: explanationText,
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

            // Explanation text input field.
            TextFormField(
              controller: _explanationController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.explanationLabel,
                hintText: AppLocalizations.of(context)!.explanationHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Image section
            Text(
              AppLocalizations.of(context)!.imageLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            if (_imageData != null) ...[
              // Image preview
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    _getImageBytes()!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.imageLoadError,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.swap_horiz),
                    label: Text(AppLocalizations.of(context)!.changeImage),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _removeImage,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(AppLocalizations.of(context)!.removeImage),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ] else ...[
              // No image state
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.addImageTap,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.imageFormats,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

  /// Pick an image file and convert to base64
  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          // Get file extension to determine mime type
          String extension = file.extension?.toLowerCase() ?? 'png';
          String mimeType = 'image/$extension';
          if (extension == 'jpg') mimeType = 'image/jpeg';

          // Convert to base64
          String base64String = base64Encode(file.bytes!);
          String imageData = 'data:$mimeType;base64,$base64String';

          setState(() {
            _imageData = imageData;
          });
        }
      }
    } catch (e) {
      // Handle error - could show a snackbar or dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.imagePickError(e.toString()),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Remove the current image
  void _removeImage() {
    setState(() {
      _imageData = null;
    });
  }

  /// Extract image data from base64 string for preview
  Uint8List? _getImageBytes() {
    if (_imageData == null) return null;

    try {
      // Extract base64 data after the comma
      final base64Data = _imageData!.split(',').last;
      return base64Decode(base64Data);
    } catch (e) {
      return null;
    }
  }
}
