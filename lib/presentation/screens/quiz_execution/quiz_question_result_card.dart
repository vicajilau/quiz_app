import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_state.dart';
import '../../utils/question_translation_helper.dart';

class QuizQuestionResultCard extends StatelessWidget {
  final QuestionResult result;
  final int questionNumber;

  const QuizQuestionResultCard({
    super.key,
    required this.result,
    required this.questionNumber,
  });

  /// Extract image data from base64 string for preview
  Uint8List? _getImageBytes(String? imageData) {
    if (imageData == null) return null;

    try {
      // Extract base64 data after the comma
      final base64Data = imageData.split(',').last;
      return base64Decode(base64Data);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        leading: Icon(
          result.isCorrect ? Icons.check_circle : Icons.cancel,
          color: result.isCorrect ? Colors.green : Colors.red,
        ),
        title: Text(
          AppLocalizations.of(context)!.questionNumber(questionNumber),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          result.question.text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.question(result.question.text),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                // Show image if available
                if (result.question.image != null) ...[
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        _getImageBytes(result.question.image)!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 32,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppLocalizations.of(context)!.imageLoadError,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Show all options with indicators
                ...result.question.options.asMap().entries.map((entry) {
                  final optionIndex = entry.key;
                  final optionText = entry.value;
                  final isCorrect = result.correctAnswers.contains(optionIndex);
                  final wasSelected = result.userAnswers.contains(optionIndex);

                  Color? backgroundColor;
                  Color? borderColor;
                  IconData? icon;
                  Color? iconColor;
                  Color? textColor;
                  FontWeight fontWeight = FontWeight.normal;

                  if (isCorrect && wasSelected) {
                    // Respuesta correcta seleccionada - Verde brillante
                    backgroundColor = Colors.green.withValues(alpha: 0.15);
                    borderColor = Colors.green;
                    icon = Icons.check_circle;
                    iconColor = Colors.green;
                    textColor = Colors.green.shade800;
                    fontWeight = FontWeight.w600;
                  } else if (isCorrect && !wasSelected) {
                    // Respuesta correcta NO seleccionada - Naranja/Amarillo (perdida)
                    backgroundColor = Colors.orange.withValues(alpha: 0.1);
                    borderColor = Colors.orange;
                    icon = Icons.radio_button_unchecked;
                    iconColor = Colors.orange;
                    textColor = Colors.orange.shade800;
                    fontWeight = FontWeight.w500;
                  } else if (!isCorrect && wasSelected) {
                    // Respuesta incorrecta seleccionada - Rojo
                    backgroundColor = Colors.red.withValues(alpha: 0.1);
                    borderColor = Colors.red;
                    icon = Icons.cancel;
                    iconColor = Colors.red;
                    textColor = Colors.red.shade800;
                    fontWeight = FontWeight.w500;
                  } else {
                    // Respuesta no seleccionada e incorrecta - Gris neutro
                    backgroundColor = null;
                    borderColor = null;
                    icon = null;
                    iconColor = null;
                    textColor = Theme.of(context).colorScheme.onSurface;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8.0),
                      border: borderColor != null
                          ? Border.all(color: borderColor, width: 1.5)
                          : Border.all(
                              color: Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.3),
                            ),
                    ),
                    child: Row(
                      children: [
                        if (icon != null)
                          Icon(icon, size: 22, color: iconColor),
                        if (icon != null) const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            QuestionTranslationHelper.translateOption(
                              optionText,
                              AppLocalizations.of(context)!,
                            ),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: fontWeight,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        // Agregar texto explicativo para claridad
                        if (isCorrect && wasSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.correctSelectedLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (isCorrect && !wasSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.correctMissedLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (!isCorrect && wasSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.incorrectSelectedLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),

                // Show explanation if available
                if (result.question.explanation.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.explanationTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result.question.explanation,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
