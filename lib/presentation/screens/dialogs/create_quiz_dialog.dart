import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';

class CreateQuizFileDialog extends StatefulWidget {
  const CreateQuizFileDialog({super.key});

  @override
  State<CreateQuizFileDialog> createState() => _CreateQuizFileDialogState();
}

class _CreateQuizFileDialogState extends State<CreateQuizFileDialog> {
  // Controllers to manage text input for the file metadata.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _versionController = TextEditingController(
    text: '1.0',
  );
  final TextEditingController _authorController = TextEditingController();

  // Error messages for input validation.
  String? _nameError;
  String? _descriptionError;
  String? _authorError;

  @override
  void dispose() {
    // Dispose controllers to release resources when the widget is removed.
    _nameController.dispose();
    _descriptionController.dispose();
    _versionController.dispose();
    _authorController.dispose();
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

  /// Clears the author error message when the user types into the author field.
  void _onAuthorChanged(String value) {
    if (_authorError != null && value.isNotEmpty) {
      setState(() {
        _authorError = null;
      });
    }
  }

  /// Validates inputs and handles form submission.
  void _submit() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final version = _versionController.text.trim();
    final author = _authorController.text.trim();

    // Validate inputs and update error messages if necessary.
    setState(() {
      _nameError = name.isEmpty
          ? AppLocalizations.of(context)!.fileNameRequiredError
          : null;
      _descriptionError = description.isEmpty
          ? AppLocalizations.of(context)!.fileDescriptionRequiredError
          : null;
      _authorError = author.isEmpty
          ? AppLocalizations.of(context)!.authorRequiredError
          : null;
    });

    // If all inputs are valid, process the submission.
    if (_nameError == null &&
        _descriptionError == null &&
        _authorError == null) {
      // Return all metadata to the previous screen.
      context.pop({
        'name': name,
        'description': description,
        'version': version,
        'author': author,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.note_add, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(AppLocalizations.of(context)!.createQuizFileTitle),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text field for entering the file name.
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.fileNameLabel,
                  errorText: _nameError,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.title),
                ),
                onChanged: _onNameChanged,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Text field for entering the file description.
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.fileDescriptionLabel,
                  errorText: _descriptionError,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 2,
                onChanged: _onDescriptionChanged,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Row for version and author fields
              Row(
                children: [
                  // Text field for entering the version.
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _versionController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.versionLabel,
                        border: const OutlineInputBorder(),
                        hintText: '1.0',
                        prefixIcon: const Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Text field for entering the author.
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _authorController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.authorLabel,
                        errorText: _authorError,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      onChanged: _onAuthorChanged,
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Cancel button to close the dialog without saving.
        TextButton(
          onPressed: () => context.pop(),
          child: Text(AppLocalizations.of(context)!.cancelButton),
        ),

        // Create button to validate and submit the form.
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.create),
          label: Text(AppLocalizations.of(context)!.createButton),
        ),
      ],
    );
  }
}
