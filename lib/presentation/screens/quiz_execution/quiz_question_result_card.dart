import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:quiz_app/core/extensions/string_extensions.dart';
import 'package:quiz_app/data/services/ai/ai_question_generation_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/quiz/question_type.dart';
import '../../../data/services/configuration_service.dart';
import '../../../data/services/ai/ai_service_selector.dart';
import '../../../data/services/ai/ai_service.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_state.dart';
import '../../utils/question_translation_helper.dart';

class QuizQuestionResultCard extends StatefulWidget {
  final QuestionResult result;
  final int questionNumber;

  const QuizQuestionResultCard({
    super.key,
    required this.result,
    required this.questionNumber,
  });

  @override
  State<QuizQuestionResultCard> createState() => _QuizQuestionResultCardState();
}

class _QuizQuestionResultCardState extends State<QuizQuestionResultCard> {
  bool _isAIEnabled = false;
  bool _hasAPIKey = false;
  bool _isEvaluating = false;
  String? _aiEvaluation;
  List<AIService> _availableServices = [];
  AIService? _selectedService;

  @override
  void initState() {
    super.initState();
    _checkAIAvailability();
  }

  Future<void> _checkAIAvailability() async {
    final aiEnabled = await ConfigurationService.instance
        .getAIAssistantEnabled();
    final availableServices = await AIServiceSelector.instance
        .getAvailableServices();

    setState(() {
      _isAIEnabled = aiEnabled;
      _hasAPIKey = availableServices.isNotEmpty;
      _availableServices = availableServices;
      _selectedService = availableServices.isNotEmpty
          ? availableServices.first
          : null;
    });
  }

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
          widget.result.isCorrect ? Icons.check_circle : Icons.cancel,
          color: widget.result.isCorrect ? Colors.green : Colors.red,
        ),
        title: Text(
          AppLocalizations.of(context)!.questionNumber(widget.questionNumber),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          widget.result.question.text,
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
                  AppLocalizations.of(
                    context,
                  )!.question(widget.result.question.text),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                // Show image if available
                if (widget.result.question.image != null) ...[
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
                        _getImageBytes(widget.result.question.image)!,
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

                // Handle essay questions differently
                if (widget.result.question.type == QuestionType.essay) ...[
                  // Show essay answer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: widget.result.essayAnswer.trim().isNotEmpty
                          ? Colors.blue.withValues(alpha: 0.05)
                          : Colors.grey.withValues(alpha: 0.05),
                      border: Border.all(
                        color: widget.result.essayAnswer.trim().isNotEmpty
                            ? Colors.blue.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              widget.result.essayAnswer.trim().isNotEmpty
                                  ? Icons.edit_note
                                  : Icons.edit_off,
                              color: widget.result.essayAnswer.trim().isNotEmpty
                                  ? Colors.blue
                                  : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.questionTypeEssay,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color:
                                    widget.result.essayAnswer.trim().isNotEmpty
                                    ? Colors.blue.shade800
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.result.essayAnswer,
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.result.essayAnswer.trim().isNotEmpty
                                ? Theme.of(context).colorScheme.onSurface
                                : Colors.grey.shade600,
                            fontStyle:
                                widget.result.essayAnswer.trim().isNotEmpty
                                ? FontStyle.normal
                                : FontStyle.italic,
                          ),
                        ),
                        // AI Evaluation Button for essay questions
                        if (_isAIEnabled &&
                            _hasAPIKey &&
                            widget.result.essayAnswer.trim().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          // AI Service Selector (if multiple services available)
                          if (_availableServices.length > 1) ...[
                            Row(
                              children: [
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.aiServiceLabel,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<AIService>(
                                    value: _selectedService,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outline,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ),
                                    items: _availableServices.map((service) {
                                      return DropdownMenuItem<AIService>(
                                        value: service,
                                        child: Text(
                                          service.serviceName,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (AIService? newService) {
                                      setState(() {
                                        _selectedService = newService;
                                        // Reset evaluation when changing service
                                        _aiEvaluation = null;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                          Center(
                            child: ElevatedButton.icon(
                              onPressed:
                                  _isEvaluating || _selectedService == null
                                  ? null
                                  : _evaluateEssayWithAI,
                              icon: _isEvaluating
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.auto_awesome, size: 18),
                              label: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _isEvaluating
                                        ? AppLocalizations.of(
                                            context,
                                          )!.aiThinking
                                        : AppLocalizations.of(
                                            context,
                                          )!.evaluateWithAI,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  if (_selectedService != null &&
                                      _availableServices.length == 1)
                                    Text(
                                      '(${_selectedService!.serviceName})',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                        ],
                        // Show AI evaluation if available
                        if (_aiEvaluation != null) ...[
                          const SizedBox(height: 12),
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
                                      Icons.psychology,
                                      size: 20,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.aiEvaluation,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                    if (_selectedService != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Text(
                                          _selectedService!.serviceName,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 8),
                                GptMarkdown(
                                  _aiEvaluation!,
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
                ] else ...[
                  // Show all options with indicators for non-essay questions
                  ...widget.result.question.options.asMap().entries.map((
                    entry,
                  ) {
                    final optionIndex = entry.key;
                    final optionText = entry.value;
                    final isCorrect = widget.result.correctAnswers.contains(
                      optionIndex,
                    );
                    final wasSelected = widget.result.userAnswers.contains(
                      optionIndex,
                    );

                    Color? backgroundColor;
                    Color? borderColor;
                    IconData? icon;
                    Color? iconColor;
                    Color? textColor;
                    FontWeight fontWeight = FontWeight.normal;

                    if (isCorrect && wasSelected) {
                      // Correct answer selected - Bright green
                      backgroundColor = Colors.green.withValues(alpha: 0.15);
                      borderColor = Colors.green;
                      icon = Icons.check_circle;
                      iconColor = Colors.green;
                      textColor = Colors.green.shade800;
                      fontWeight = FontWeight.w600;
                    } else if (isCorrect && !wasSelected) {
                      // Correct answer NOT selected - Orange/Yellow (missed)
                      backgroundColor = Colors.orange.withValues(alpha: 0.1);
                      borderColor = Colors.orange;
                      icon = Icons.radio_button_unchecked;
                      iconColor = Colors.orange;
                      textColor = Colors.orange.shade800;
                      fontWeight = FontWeight.w500;
                    } else if (!isCorrect && wasSelected) {
                      // Incorrect answer selected - Red
                      backgroundColor = Colors.red.withValues(alpha: 0.1);
                      borderColor = Colors.red;
                      icon = Icons.cancel;
                      iconColor = Colors.red;
                      textColor = Colors.red.shade800;
                      fontWeight = FontWeight.w500;
                    } else {
                      // Answer not selected and incorrect - Neutral gray
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
                          // Add explanatory text for clarity
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
                                AppLocalizations.of(
                                  context,
                                )!.correctMissedLabel,
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
                ], // Close options section for non-essay questions
                // Show explanation if available
                if (widget.result.question.explanation.isNotEmpty) ...[
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
                          widget.result.question.explanation,
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

  Future<void> _evaluateEssayWithAI() async {
    if (_isEvaluating || _selectedService == null) return;

    setState(() {
      _isEvaluating = true;
    });

    try {
      final localizations = AppLocalizations.of(context)!;

      // Build the evaluation prompt
      String prompt = AiQuestionGenerationService.buildEvaluationPrompt(
        widget.result.question.text,
        widget.result.essayAnswer,
        widget.result.question.explanation,
        localizations,
      );

      final evaluation = await _selectedService!.getChatResponse(
        prompt,
        localizations,
      );

      setState(() {
        _aiEvaluation = evaluation;
      });
    } catch (e) {
      setState(() {
        _aiEvaluation = AppLocalizations.of(
          context,
        )!.aiEvaluationError(e.toString().cleanErrorMessage());
      });
    } finally {
      setState(() {
        _isEvaluating = false;
      });
    }
  }
}
