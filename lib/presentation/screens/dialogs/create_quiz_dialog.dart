import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';

class CreateQuizFileDialog extends StatefulWidget {
  final Map<String, String>? initialMetadata;

  const CreateQuizFileDialog({super.key, this.initialMetadata});

  @override
  State<CreateQuizFileDialog> createState() => _CreateQuizFileDialogState();
}

class _CreateQuizFileDialogState extends State<CreateQuizFileDialog> {
  // Controllers to manage text input for the file metadata.
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _versionController;
  late final TextEditingController _authorController;

  // Error messages for input validation.
  String? _nameError;
  String? _descriptionError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialMetadata?['name'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.initialMetadata?['description'] ?? '',
    );
    _versionController = TextEditingController(
      text: widget.initialMetadata?['version'] ?? '1.0',
    );
    _authorController = TextEditingController(
      text: widget.initialMetadata?['author'] ?? '',
    );
  }

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
    });

    // If all inputs are valid, process the submission.
    if (_nameError == null && _descriptionError == null) {
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

              // Text field for entering the author.
              TextField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.authorLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
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
          icon: const Icon(
            Icons.check,
          ), // Changed icon to check as it acts more like a confirm now
          label: Text(
            AppLocalizations.of(context)!.acceptButton,
          ), // Changed to Accept/Confirm? Or keep Create? Context says "Create Button" logic uses createButton string.
          // Sticking to "Create" or "Accept"? In save flow, we are "Saving".
          // But the dialog title is "Create Quiz File".
          // If I use this dialog for "Edit Metadata" later, I might want to change title too.
          // For now, I'll keep "Create" logic but maybe change label if I can.
          // The issue description says: "The 'Create Quiz File' dialog (or a Metadata prompt) should only appear when the user clicks the 'Save' button."
          // So "Accept" or "Save" might be better.
          // Existing code used `createButton`. I will check if `acceptButton` exists. Yes it does.
        ),
      ],
    );
  }
}
