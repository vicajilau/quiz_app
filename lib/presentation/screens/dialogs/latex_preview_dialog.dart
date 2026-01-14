import 'package:flutter/material.dart';
import '../../widgets/latex_text.dart';

/// A dialog to preview how an option will appear with LaTeX rendering
class LaTeXPreviewDialog extends StatelessWidget {
  final String optionText;
  final String title;

  const LaTeXPreviewDialog({
    super.key,
    required this.optionText,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Preview:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[600]!),
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[900],
              ),
              constraints: const BoxConstraints(minHeight: 80),
              child: optionText.trim().isEmpty
                  ? const Text(
                      '(empty)',
                      style: TextStyle(color: Colors.white70),
                    )
                  : LaTeXText(
                      optionText,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'LaTeX Syntax:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              r'Inline math: Use $...$ for LaTeX expressions'
              '\n'
              r'Example: $x^2 + y^2 = z^2$',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/// A button that shows a LaTeX preview dialog for the given text
class LaTeXPreviewButton extends StatelessWidget {
  final String text;
  final String title;

  const LaTeXPreviewButton({
    super.key,
    required this.text,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.preview),
      tooltip: 'Preview LaTeX rendering',
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => LaTeXPreviewDialog(
            optionText: text,
            title: title,
          ),
        );
      },
    );
  }
}
