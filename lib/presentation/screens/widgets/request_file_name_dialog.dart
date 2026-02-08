import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:quiz_app/core/l10n/app_localizations.dart';

/// A dialog widget for requesting a file name from the user.
/// Styled according to design node 75JA2.
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
        _errorMessage = AppLocalizations.of(
          context,
        )!.emptyFileNameMessage; // Set error message for empty filename.
      });
      return false;
    }

    // Check if the filename ends with '.quiz'; if not, append it.
    if (!filename.endsWith(widget.format)) {
      _controller.text =
          '$filename${widget.format}'; // Update the text with the correct extension.
    }

    setState(() {
      _errorMessage = null; // Clear any previous error messages.
    });
    return true; // Input is valid.
  }

  /// Handle submission of the dialog.
  void _submit() {
    if (_validateInput()) {
      context.pop(
        _controller.text.trim(),
      ); // Return the valid filename to the previous context.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF27272A), // Zinc 800
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.requestFileNameTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3F3F46), // Zinc 700
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        LucideIcons.x,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Input Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.fileNameHint,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _controller,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontSize: 16,
                  ),
                  cursorColor: const Color(0xFF8B5CF6), // Violet 500
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF3F3F46), // Zinc 700
                    hintText: 'quiz_name',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontFamily: 'Inter',
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF8B5CF6), // Violet 500
                        width: 2,
                      ),
                    ),
                    errorText: _errorMessage,
                    errorStyle: const TextStyle(
                      color: Color(0xFFEF4444), // Red 500
                      fontFamily: 'Inter',
                    ),
                  ),
                  onFieldSubmitted: (_) => _submit(),
                  onChanged: (value) {
                    setState(() {
                      _errorMessage = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6), // Violet 500
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  AppLocalizations.of(context)!.acceptButton,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
