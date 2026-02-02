import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';

/// A dialog that allows the user to create or edit quiz metadata.
///
/// This dialog collects the quiz name, description, and author.
/// It supports both creating a new quiz (where fields are initially empty)
/// and editing an existing one (where fields are pre-filled).
class QuizMetadataDialog extends StatefulWidget {
  /// The initial name of the quiz, used when editing.
  final String? initialName;

  /// The initial description of the quiz, used when editing.
  final String? initialDescription;

  /// The initial author of the quiz, used when editing.
  final String? initialAuthor;

  /// Whether the dialog is in editing mode (true) or creation mode (false).
  ///
  /// Defaults to `false`.
  final bool isEditing;

  /// Creates a [QuizMetadataDialog].
  const QuizMetadataDialog({
    super.key,
    this.initialName,
    this.initialDescription,
    this.initialAuthor,
    this.isEditing = false,
  });

  @override
  State<QuizMetadataDialog> createState() => _QuizMetadataDialogState();
}

class _QuizMetadataDialogState extends State<QuizMetadataDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _authorController;

  // Error messages for input validation.
  String? _nameError;
  String? _descriptionError;
  String? _authorError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
    _authorController = TextEditingController(text: widget.initialAuthor);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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

  /// Validates the inputs and closes the dialog with the result if valid.
  void _submit() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final author = _authorController.text.trim();

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

    if (_nameError == null &&
        _descriptionError == null &&
        _authorError == null) {
      context.pop({'name': name, 'description': description, 'author': author});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            widget.isEditing ? Icons.edit : Icons.note_add,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.isEditing
                  ? AppLocalizations.of(context)!.editQuizFileTitle
                  : AppLocalizations.of(context)!.createQuizFileTitle,
            ),
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
              TextField(
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(AppLocalizations.of(context)!.cancelButton),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: Icon(widget.isEditing ? Icons.save : Icons.create),
          label: Text(
            widget.isEditing
                ? AppLocalizations.of(context)!.saveButton
                : AppLocalizations.of(context)!.createButton,
          ),
        ),
      ],
    );
  }
}
