import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_event.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/data/services/ai/ai_service.dart';
import 'package:quiz_app/data/services/ai/ai_service_selector.dart';

import 'package:quiz_app/data/services/ai/ai_question_generation_service.dart';
import 'package:quiz_app/core/extensions/string_extensions.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/widgets/ai_assistant_button.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/widgets/quiz_question_explanation.dart';

/// A widget that handles essay-type questions.
///
/// It provides a text input area for the user to type their answer.
/// It also handles the integration with AI services to evaluate the essay
/// when in Study Mode and AI is available.
class EssayAnswerInput extends StatefulWidget {
  /// The essay question being answered.
  final Question question;

  /// The index of the question in the quiz.
  final int questionIndex;

  /// The current text answer provided by the user.
  final String currentAnswer;

  /// Whether the quiz is in Study Mode.
  final bool isStudyMode;

  /// Whether AI assistance features are available/enabled.
  final bool isAiAvailable;

  /// The current execution state of the quiz.
  final QuizExecutionInProgress state;

  /// Creates an [EssayAnswerInput].
  const EssayAnswerInput({
    super.key,
    required this.question,
    required this.questionIndex,
    required this.currentAnswer,
    required this.isStudyMode,
    required this.isAiAvailable,
    required this.state,
  });

  @override
  State<EssayAnswerInput> createState() => _EssayAnswerInputState();
}

class _EssayAnswerInputState extends State<EssayAnswerInput> {
  late TextEditingController _essayController;
  bool _isEvaluating = false;
  String? _aiEvaluation;
  List<AIService> _availableServices = [];
  AIService? _selectedService;

  @override
  void initState() {
    super.initState();
    _essayController = TextEditingController(text: widget.currentAnswer);
    _loadAvailableServices();
  }

  Future<void> _loadAvailableServices() async {
    final services = await AIServiceSelector.instance.getAvailableServices();
    if (mounted) {
      setState(() {
        _availableServices = services;
        _selectedService = services.isNotEmpty ? services.first : null;
      });
    }
  }

  @override
  void didUpdateWidget(EssayAnswerInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentAnswer != _essayController.text) {
      // Only update if external change (e.g. navigation) to avoid cursor jump issues
      // But usually we want to keep what user is typing.
      // The parent ensures this widget is rebuilt when question index changes.
      if (oldWidget.questionIndex != widget.questionIndex) {
        _essayController.text = widget.currentAnswer;
        _aiEvaluation = null; // Clear evaluation on question change
      }
    }
  }

  @override
  void dispose() {
    _essayController.dispose();
    super.dispose();
  }

  Future<void> _evaluateEssayWithAI() async {
    if (_isEvaluating || _selectedService == null) return;

    setState(() {
      _isEvaluating = true;
    });

    try {
      final localizations = AppLocalizations.of(context)!;
      final studentAnswer = widget.currentAnswer;

      // Build the evaluation prompt
      String prompt = AiQuestionGenerationService.buildEvaluationPrompt(
        widget.question.text,
        studentAnswer,
        widget.question.explanation,
        localizations,
      );

      final evaluation = await _selectedService!.getChatResponse(
        prompt,
        localizations,
      );

      if (mounted) {
        setState(() {
          _aiEvaluation = evaluation;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiEvaluation = AppLocalizations.of(
            context,
          )!.aiEvaluationError(e.toString().cleanErrorMessage());
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isEvaluating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Assistant Button (Only in Study Mode and if AI is available)
          if (widget.isStudyMode && widget.isAiAvailable)
            AiAssistantButton(question: widget.question),

          Text(
            AppLocalizations.of(context)!.questionTypeEssay,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.5),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _essayController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.explanationHint,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                onChanged: (text) {
                  context.read<QuizExecutionBloc>().add(
                    EssayAnswerChanged(text),
                  );
                },
              ),
            ),
          ),

          // Show explanation in Study Mode after validation
          if (widget.isStudyMode &&
              widget.state.isCurrentQuestionValidated &&
              widget.question.explanation.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Column(
                children: [
                  // Reusing existing explanation widget
                  QuizQuestionExplanation(
                    explanation: widget.question.explanation,
                  ),

                  // AI Evaluation Section
                  if (widget.isAiAvailable) ...[
                    const SizedBox(height: 16),
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
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<AIService>(
                              initialValue: _selectedService,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
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

                    // Evaluate Button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _isEvaluating || _selectedService == null
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
                            : const Icon(Icons.psychology, size: 18),
                        label: Text(
                          _isEvaluating
                              ? AppLocalizations.of(context)!.aiThinking
                              : AppLocalizations.of(context)!.evaluateWithAI,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),

                    // Evaluation Result
                    if (_aiEvaluation != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
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
                                  Icons.auto_awesome,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.aiEvaluation,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
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
                ],
              ),
            ),
        ],
      ),
    );
  }
}
