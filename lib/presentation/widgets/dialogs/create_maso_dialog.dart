import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';

class CreateMasoFileDialog extends StatefulWidget {
  const CreateMasoFileDialog({super.key});

  @override
  State<CreateMasoFileDialog> createState() => _CreateMasoFileDialogState();
}

class _CreateMasoFileDialogState extends State<CreateMasoFileDialog> {
  // Controllers to manage text input for the file name and description.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Error messages for input validation.
  String? _nameError;
  String? _descriptionError;

  @override
  void dispose() {
    // Dispose controllers to release resources when the widget is removed.
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Clears the name error message when the user types into the name field.
  void _onNameChanged(String value) {
    if (_nameError != null && value.isNotEmpty) {
      setState(() {
        _nameError = null;
      });
    }
  }

  /// Clears the description error message when the user types into the description field.
  void _onDescriptionChanged(String value) {
    if (_descriptionError != null && value.isNotEmpty) {
      setState(() {
        _descriptionError = null;
      });
    }
  }

  /// Validates inputs and handles form submission.
  void _submit() {
    final name =
        _nameController.text.trim(); // Trim whitespace from the name input.
    final description = _descriptionController.text
        .trim(); // Trim whitespace from the description input.

    // Validate inputs and update error messages if necessary.
    setState(() {
      _nameError = name.isEmpty
          ? AppLocalizations.of(context)!.fileNameRequiredError
          : null;
      _descriptionError = description.isEmpty
          ? AppLocalizations.of(context)!.fileDescriptionRequiredError
          : null;
    });

    // If both inputs are valid, process the submission.
    if (_nameError == null && _descriptionError == null) {
      // Return the name and description to the previous screen.
      context.pop({
        'name': name,
        'description': description,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          AppLocalizations.of(context)!.createMasoFileTitle), // Dialog title.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text field for entering the file name.
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.fileNameLabel,
                errorText:
                    _nameError, // Displays error message if validation fails.
                border: const OutlineInputBorder(),
              ),
              onChanged:
                  _onNameChanged, // Removes error message on input change.
            ),
            const SizedBox(height: 10), // Adds vertical spacing.

            // Text field for entering the file description.
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.fileDescriptionLabel,
                errorText:
                    _descriptionError, // Displays error message if validation fails.
                border: const OutlineInputBorder(),
              ),
              onChanged:
                  _onDescriptionChanged, // Removes error message on input change.
            ),
          ],
        ),
      ),
      actions: [
        // Cancel button to close the dialog without saving.
        TextButton(
          onPressed: () => context.pop(), // Closes the dialog.
          child: Text(AppLocalizations.of(context)!.cancelButton),
        ),

        // Create button to validate and submit the form.
        ElevatedButton(
          onPressed: _submit, // Calls the _submit method.
          child: Text(AppLocalizations.of(context)!.createButton),
        ),
      ],
    );
  }
}
