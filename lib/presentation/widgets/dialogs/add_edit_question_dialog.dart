import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/quiz_file.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../domain/models/custom_exceptions/regular_process_error_type.dart';

/// Dialog widget for creating or editing a Question.
class AddEditQuestionDialog extends StatefulWidget {
  final Question? question; // Optional question for editing.
  final QuizFile quizFile; // The file containing all questions.
  final int? questionPosition; // Optional index for editing a specific question.

  /// Constructor for the dialog.
  const AddEditQuestionDialog({
    super.key,
    this.question,
    required this.quizFile,
    this.questionPosition,
  });

  @override
  State<AddEditQuestionDialog> createState() =>
      _AddEditQuestionDialogState();
}

class _AddEditQuestionDialogState extends State<AddEditQuestionDialog> {
  late TextEditingController
      _nameController; // Controller for the name input field.
  late TextEditingController
      _arrivalTimeController; // Controller for the arrival time input field.
  late TextEditingController
      _serviceTimeController; // Controller for the service time input field.
  late bool _isEnabled; // Indicates if the process is enabled or disabled.

  String? _nameError; // Error message for the name field.
  String? _arrivalTimeError; // Error message for the arrival time field.
  String? _serviceTimeError; // Error message for the service time field.

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers.
    _nameController = TextEditingController();
    _arrivalTimeController = TextEditingController();
    _serviceTimeController = TextEditingController();
    if (widget.question != null) {
      _nameController.text = widget.question!.text;
      _arrivalTimeController.text = widget.question!.arrivalTime.toString();
      _serviceTimeController.text = widget.question!.serviceTime.toString();
      _isEnabled = widget.question!.enabled;
    } else {
      _isEnabled = true;
    }
  }

  @override
  void dispose() {
    // Dispose of the text controllers to free up resources.
    _nameController.dispose();
    _arrivalTimeController.dispose();
    _serviceTimeController.dispose();
    super.dispose();
  }

  /// Validate the input fields.
  bool _validateInput() {
    // Reset error messages.
    setState(() {
      _nameError = null;
      _arrivalTimeError = null;
      _serviceTimeError = null;
    });

    final validateInput = ValidateMasoProcessUseCase.validateRegularProcess(
        _nameController.text,
        _arrivalTimeController.text,
        _serviceTimeController.text,
        widget.questionPosition,
        widget.quizFile);
    if (validateInput.success) return true;

    switch (validateInput.errorType) {
      case RegularProcessErrorType.emptyName:
        _nameError = validateInput.getDescriptionForInputError(context);
      case RegularProcessErrorType.duplicatedName:
        _nameError = validateInput.getDescriptionForInputError(context);
      case RegularProcessErrorType.invalidArrivalTime:
        _arrivalTimeError = validateInput.getDescriptionForInputError(context);
      case RegularProcessErrorType.invalidServiceTime:
        _serviceTimeError = validateInput.getDescriptionForInputError(context);
    }
    return false;
  }

  /// Submit the form if input is valid.
  void _submit() {
    if (_validateInput()) {
      // Create a new or updated process instance.
      final newOrUpdatedProcess = RegularProcess(
        id: _nameController.text.trim(),
        arrivalTime: int.parse(_arrivalTimeController.text),
        serviceTime: int.parse(_serviceTimeController.text),
        enabled: _isEnabled,
      );
      context.pop(
          newOrUpdatedProcess); // Return the new/updated process to the previous context.
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!
          .createRegularProcessTitle), // Title of the dialog.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name input field.
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.processNameLabel,
                errorText: _nameError,
                errorMaxLines: 2,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _nameError = null; // Clear error when the user types.
                });
              },
            ),
            const SizedBox(height: 10), // Spacing between fields.
            // Arrival time input field.
            TextFormField(
              controller: _arrivalTimeController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.arrivalTimeDialogLabel,
                errorText: _arrivalTimeError,
                errorMaxLines: 2,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number, // Numeric keyboard for input.
              onChanged: (value) {
                setState(() {
                  _arrivalTimeError = null; // Clear error when the user types.
                });
              },
            ),
            const SizedBox(height: 10), // Spacing between fields.
            // Service time input field.
            TextFormField(
              controller: _serviceTimeController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.serviceTimeDialogLabel,
                errorText: _serviceTimeError,
                errorMaxLines: 2,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number, // Numeric keyboard for input.
              onChanged: (value) {
                setState(() {
                  _serviceTimeError = null; // Clear error when the user types.
                });
              },
            ),
            const SizedBox(height: 10), // Spacing between fields.
            // Switch to toggle enabled/disabled state.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEnabled
                      ? AppLocalizations.of(context)!.enabledLabel
                      : AppLocalizations.of(context)!.disabledLabel,
                ),
                Switch(
                  value: _isEnabled,
                  onChanged: (value) {
                    setState(() {
                      _isEnabled = value; // Update the enabled state.
                    });
                  },
                ),
              ],
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
}
