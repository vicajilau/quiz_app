import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'quiz_progress_indicator.dart';
import 'quiz_question_header.dart';
import 'quiz_question_options.dart';
import 'quiz_navigation_buttons.dart';

class QuizInProgressView extends StatelessWidget {
  final QuizExecutionInProgress state;

  const QuizInProgressView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final hasImage = state.currentQuestion.image != null;

    return Column(
      children: [
        // Progress indicator (fixed)
        QuizProgressIndicator(state: state),

        // Main content area (flexible)
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QuizQuestionHeader(state: state),

                // Image section if exists
                if (hasImage) ...[
                  const SizedBox(height: 16),
                  _buildImageSection(),
                ],

                const SizedBox(height: 16),

                // Options section - usar el widget original pero sin scroll
                SizedBox(
                  height:
                      state.currentQuestion.options.length *
                      80.0, // altura estimada por opción
                  child: QuizQuestionOptions(state: state),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Navigation buttons (fixed at bottom)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: QuizNavigationButtons(state: state),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxHeight: 200, // Altura máxima para la imagen
        minHeight: 100, // Altura mínima
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          child: state.currentQuestion.image != null
              ? Image.memory(
                  _getImageBytes(state.currentQuestion.image!)!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error loading image',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  /// Extract image data from base64 string for preview
  Uint8List? _getImageBytes(String? imageData) {
    if (imageData == null) return null;

    try {
      // Extract base64 data after the comma
      final base64Data = imageData.split(',').last;
      return base64.decode(base64Data);
    } catch (e) {
      return null;
    }
  }
}
