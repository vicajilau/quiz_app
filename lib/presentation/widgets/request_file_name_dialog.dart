import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';

/// A dialog widget for requesting a file name from the user.
class RequestFileNameDialog extends StatefulWidget {
  final String format;
  const RequestFileNameDialog({super.key, required this.format});

  @override
  State<RequestFileNameDialog> createState() => _RequestFileNameDialogState();
}

class _RequestFileNameDialogState extends State<RequestFileNameDialog> {
  late TextEditingController
      _controller; // Controller for the file name input field.
  String? _errorMessage; // Error message to display if validation fails.

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(); // Initialize the text controller.
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the text controller to free resources.
    super.dispose();
  }

  /// Validate the input and set error messages as necessary.
  bool _validateInput() {
    final filename = _controller.text.trim(); // Get the trimmed input value.

    // Check if the filename is empty.
    if (filename.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!
            .emptyFileNameMessage; // Set error message for empty filename.
      });
      return false;
    }

    // Check if the filename ends with '.maso'; if not, append it.
    if (!filename.endsWith(widget.format)) {
      _controller.text =
          "$filename${widget.format}"; // Update the text with the correct extension.
    }

    setState(() {
      _errorMessage = null; // Clear any previous error messages.
    });
    return true; // Input is valid.
  }

  /// Handle submission of the dialog.
  void _submit() {
    if (_validateInput()) {
      context.pop(_controller.text
          .trim()); // Return the valid filename to the previous context.
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!
          .requestFileNameTitle), // Title of the dialog.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Minimize column size to fit content.
          children: [
            // TextFormField for file name input.
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!
                    .fileNameHint, // Hint text for the input field.
                errorText:
                    _errorMessage, // Display error message if validation fails.
                border: const OutlineInputBorder(), // Define border style.
              ),
              onChanged: (value) {
                setState(() {
                  _errorMessage =
                      null; // Clear error message when input changes.
                });
              },
            ),
            const SizedBox(height: 10), // Add spacing below the input field.
          ],
        ),
      ),
      actions: [
        // Cancel button to close the dialog without saving.
        TextButton(
          onPressed: () => context.pop(),
          child: Text(AppLocalizations.of(context)!.cancelButton),
        ),
        // Accept button to submit the filename.
        ElevatedButton(
          onPressed: _submit,
          child: Text(AppLocalizations.of(context)!.acceptButton),
        ),
      ],
    );
  }
}
