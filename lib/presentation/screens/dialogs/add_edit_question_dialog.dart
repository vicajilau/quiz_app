import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/question_type.dart';
import 'package:quiz_app/domain/models/quiz/quiz_file.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/constants/question_constants.dart';
import '../../utils/question_translation_helper.dart';

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
  QuestionType _selectedType =
      QuestionType.multipleChoice; // Selected question type

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
      _selectedType = widget.question!.type;

      // Translate options for display in UI (this will be done after build)
      _optionControllers = widget.question!.options
          .map((option) => TextEditingController(text: option))
          .toList();
      _correctAnswers = List.generate(
        widget.question!.options.length,
        (index) => widget.question!.correctAnswers.contains(index),
      );
    } else {
      // Default: 4 empty options for multiple choice
      _selectedType = QuestionType.multipleChoice;
      _optionControllers = List.generate(4, (index) => TextEditingController());
      _correctAnswers = List.generate(4, (index) => false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Translate options after context is available
    if (widget.question != null) {
      final localizations = AppLocalizations.of(context)!;
      for (int i = 0; i < _optionControllers.length; i++) {
        final originalOption = widget.question!.options[i];
        final translatedOption = QuestionTranslationHelper.translateOption(
          originalOption,
          localizations,
        );
        _optionControllers[i].text = translatedOption;
      }
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
  bool _validateForm() {
    bool isValid = true;
    final localizations = AppLocalizations.of(context)!;

    // Reset all error messages
    setState(() {
      _questionTextError = null;
      _optionsError = null;
    });

    // Validate question text
    if (_questionTextController.text.trim().isEmpty) {
      setState(() {
        _questionTextError = localizations.questionTextRequired;
      });
      isValid = false;
    }

    // Validate options only for questions that have options
    if (_selectedType != QuestionType.essay) {
      // Check for empty options
      List<int> emptyOptionIndexes = [];
      for (int i = 0; i < _optionControllers.length; i++) {
        if (_optionControllers[i].text.trim().isEmpty) {
          emptyOptionIndexes.add(i + 1); // +1 for human-readable numbering
        }
      }

      // If there are empty options, show specific error message
      if (emptyOptionIndexes.isNotEmpty) {
        setState(() {
          if (emptyOptionIndexes.length == 1) {
            // Singular: only one empty option
            _optionsError = localizations.emptyOptionError(
              emptyOptionIndexes.first.toString(),
            );
          } else {
            // Plural: multiple empty options
            _optionsError = localizations.emptyOptionsError(
              emptyOptionIndexes.join(', '),
            );
          }
        });
        isValid = false;
      } else {
        // Check if at least one correct answer is selected (except for essay)
        bool hasCorrectAnswer = _correctAnswers.any((answer) => answer);
        if (!hasCorrectAnswer) {
          setState(() {
            _optionsError = localizations.atLeastOneCorrectAnswerRequired;
          });
          isValid = false;
        }

        // Validate specific question types
        if (_selectedType == QuestionType.singleChoice ||
            _selectedType == QuestionType.trueFalse) {
          int correctCount = _correctAnswers.where((answer) => answer).length;
          if (correctCount > 1) {
            setState(() {
              _optionsError = localizations.onlyOneCorrectAnswerAllowed;
            });
            isValid = false;
          }
        }
      }
    }

    return isValid;
  }

  /// Submit the form if input is valid.
  void _submit() {
    if (_validateForm()) {
      final localizations = AppLocalizations.of(context)!;

      // Get option texts and convert back to model values
      final options = _optionControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .map(
            (optionText) =>
                _translateOptionBackToModel(optionText, localizations),
          )
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
        type: _selectedType,
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

  /// Convert translated option text back to model values
  String _translateOptionBackToModel(
    String optionText,
    AppLocalizations localizations,
  ) {
    if (optionText == localizations.trueLabel) {
      return QuestionConstants.defaultTrueOption;
    } else if (optionText == localizations.falseLabel) {
      return QuestionConstants.defaultFalseOption;
    }
    return optionText; // Return as-is for custom options
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(
        widget.question == null
            ? localizations.addQuestion
            : localizations.editQuestion,
      ), // Title of the dialog.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Question text input field.
            TextFormField(
              controller: _questionTextController,
              decoration: InputDecoration(
                labelText: localizations.questionText,
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

            // Question type selector
            DropdownButtonFormField<QuestionType>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: localizations.questionType,
                border: const OutlineInputBorder(),
                prefixIcon: Icon(_getQuestionTypeIcon(_selectedType)),
              ),
              items: QuestionType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getQuestionTypeLabel(type)),
                );
              }).toList(),
              onChanged: (QuestionType? newType) {
                if (newType != null) {
                  setState(() {
                    _selectedType = newType;
                    _updateOptionsForType(newType);
                  });
                }
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

            // Options section (only for non-essay questions)
            if (_selectedType != QuestionType.essay) ...[
              Text(
                localizations.optionsLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
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

              // Option input fields with checkboxes/radio buttons
              ...List.generate(_optionControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      // Use different input types based on question type
                      if (_selectedType == QuestionType.multipleChoice)
                        Tooltip(
                          message: localizations.selectCorrectAnswers,
                          child: Checkbox(
                            value: _correctAnswers[index],
                            activeColor: Colors.green,
                            onChanged: (value) {
                              setState(() {
                                _correctAnswers[index] = value ?? false;
                                _optionsError = null;
                              });
                            },
                          ),
                        )
                      else if (_selectedType == QuestionType.singleChoice ||
                          _selectedType == QuestionType.trueFalse)
                        Tooltip(
                          message: localizations.selectCorrectAnswer,
                          child: Radio<int>(
                            value: index,
                            activeColor: Colors.green,
                            groupValue: _correctAnswers.indexWhere(
                              (element) => element,
                            ),
                            onChanged: (value) {
                              setState(() {
                                // Reset all to false, then set selected to true
                                for (
                                  int i = 0;
                                  i < _correctAnswers.length;
                                  i++
                                ) {
                                  _correctAnswers[i] = (i == value);
                                }
                                _optionsError = null;
                              });
                            },
                          ),
                        ),
                      Expanded(
                        child: TextFormField(
                          controller: _optionControllers[index],
                          decoration: InputDecoration(
                            labelText:
                                "${localizations.optionLabel} ${index + 1}",
                            border: const OutlineInputBorder(),
                            errorText:
                                _optionsError != null &&
                                    _optionControllers[index].text
                                        .trim()
                                        .isEmpty &&
                                    _selectedType != QuestionType.trueFalse
                                ? localizations.optionEmptyError
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _optionsError = null;
                            });
                          },
                          readOnly: _selectedType == QuestionType.trueFalse,
                        ),
                      ),
                      if (_selectedType != QuestionType.trueFalse)
                        IconButton(
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          tooltip: localizations.removeOption,
                          onPressed: _optionControllers.length > 2
                              ? () => _removeOption(index)
                              : null,
                        ),
                    ],
                  ),
                );
              }),

              // Add option button (only for multiple/single choice)
              if (_selectedType == QuestionType.multipleChoice ||
                  _selectedType == QuestionType.singleChoice)
                TextButton.icon(
                  onPressed: _addOption,
                  icon: const Icon(Icons.add),
                  label: Text(localizations.addOption),
                ),

              const SizedBox(height: 16),
            ],
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

  /// Get icon for question type
  IconData _getQuestionTypeIcon(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return Icons.checklist;
      case QuestionType.singleChoice:
        return Icons.radio_button_checked;
      case QuestionType.trueFalse:
        return Icons.toggle_on;
      case QuestionType.essay:
        return Icons.article;
    }
  }

  /// Get label for question type
  String _getQuestionTypeLabel(QuestionType type) {
    final localizations = AppLocalizations.of(context)!;
    switch (type) {
      case QuestionType.multipleChoice:
        return localizations.questionTypeMultipleChoice;
      case QuestionType.singleChoice:
        return localizations.questionTypeSingleChoice;
      case QuestionType.trueFalse:
        return localizations.questionTypeTrueFalse;
      case QuestionType.essay:
        return localizations.questionTypeEssay;
    }
  }

  /// Update options based on question type
  void _updateOptionsForType(QuestionType type) {
    // Dispose current controllers
    for (var controller in _optionControllers) {
      controller.dispose();
    }

    final localizations = AppLocalizations.of(context)!;
    switch (type) {
      case QuestionType.trueFalse:
        _optionControllers = [
          TextEditingController(text: localizations.trueLabel),
          TextEditingController(text: localizations.falseLabel),
        ];
        _correctAnswers = [false, false];
        break;
      case QuestionType.essay:
        _optionControllers = [];
        _correctAnswers = [];
        break;
      case QuestionType.multipleChoice:
      case QuestionType.singleChoice:
        _optionControllers = List.generate(
          4,
          (index) => TextEditingController(),
        );
        _correctAnswers = List.generate(4, (index) => false);
        break;
    }
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
