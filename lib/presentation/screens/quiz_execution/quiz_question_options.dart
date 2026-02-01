import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/models/quiz/question_type.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_event.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_state.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../utils/question_translation_helper.dart';
import '../../widgets/latex_text.dart';
import '../dialogs/ai_question_dialog.dart';
import '../../../data/services/configuration_service.dart';
import '../../../data/services/ai/ai_service.dart';
import '../../../data/services/ai/ai_service_selector.dart';
import '../../../data/services/ai/ai_question_generation_service.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import '../../../core/extensions/string_extensions.dart';

class QuizQuestionOptions extends StatefulWidget {
  final QuizExecutionInProgress state;
  final bool showCorrectAnswerCount;
  final bool isStudyMode;

  const QuizQuestionOptions({
    super.key,
    required this.state,
    this.showCorrectAnswerCount = false,
    this.isStudyMode = false,
  });

  @override
  State<QuizQuestionOptions> createState() => _QuizQuestionOptionsState();
}

class _QuizQuestionOptionsState extends State<QuizQuestionOptions> {
  late TextEditingController _essayController;
  bool _isAiAvailable = false;

  // AI Evaluation State
  bool _isEvaluating = false;
  String? _aiEvaluation;
  List<AIService> _availableServices = [];
  AIService? _selectedService;

  @override
  void initState() {
    super.initState();
    _essayController = TextEditingController();
    _updateEssayController();
    _checkAiAvailability();
  }

  Future<void> _checkAiAvailability() async {
    final configService = ConfigurationService.instance;
    final isEnabled = await configService.getAIAssistantEnabled();
    final openAiKey = await configService.getOpenAIApiKey();
    final geminiKey = await configService.getGeminiApiKey();

    // Fetch available services for evaluation
    final availableServices = await AIServiceSelector.instance
        .getAvailableServices();

    if (mounted) {
      setState(() {
        _isAiAvailable = isEnabled && (openAiKey != null || geminiKey != null);
        _availableServices = availableServices;
        _selectedService = availableServices.isNotEmpty
            ? availableServices.first
            : null;
      });
    }
  }

  @override
  void didUpdateWidget(QuizQuestionOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.currentQuestionIndex !=
            widget.state.currentQuestionIndex ||
        oldWidget.state.essayAnswers != widget.state.essayAnswers) {
      _updateEssayController();
    }
    // Re-check availability in case settings changed (less likely but good practice)
    _checkAiAvailability();
  }

  void _updateEssayController() {
    final currentText =
        widget.state.essayAnswers[widget.state.currentQuestionIndex] ?? '';
    if (_essayController.text != currentText) {
      _essayController.text = currentText;
    }
    // Clear previous evaluation when question changes
    if (_aiEvaluation != null) {
      setState(() {
        _aiEvaluation = null;
      });
    }
  }

  Future<void> _evaluateEssayWithAI() async {
    if (_isEvaluating || _selectedService == null) return;

    setState(() {
      _isEvaluating = true;
    });

    try {
      final localizations = AppLocalizations.of(context)!;
      final studentAnswer =
          widget.state.essayAnswers[widget.state.currentQuestionIndex] ?? '';

      // Build the evaluation prompt
      String prompt = AiQuestionGenerationService.buildEvaluationPrompt(
        widget.state.currentQuestion.text,
        studentAnswer,
        widget.state.currentQuestion.explanation,
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
  void dispose() {
    _essayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionType = widget.state.currentQuestion.type;
    final correctAnswersCount =
        widget.state.currentQuestion.correctAnswers.length;

    // Handle essay questions separately
    if (questionType == QuestionType.essay) {
      return _buildEssayInput(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Assistant Button (Only in Study Mode and if AI is available)
        if (widget.isStudyMode && _isAiAvailable)
          _buildAiAssistantButton(context),

        // Show correct answer count hint for multiple choice questions
        if (widget.showCorrectAnswerCount &&
            questionType == QuestionType.multipleChoice &&
            correctAnswersCount > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.correctAnswersCount(correctAnswersCount),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Options list
        if (questionType == QuestionType.multipleChoice)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.state.currentQuestion.options.length,
            itemBuilder: (context, index) {
              final option = widget.state.currentQuestion.options[index];
              final isSelected = widget.state.isOptionSelected(index);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Card(
                  elevation: isSelected ? 4 : 1,
                  child: _buildOptionTile(
                    context,
                    questionType,
                    option,
                    index,
                    isSelected,
                  ),
                ),
              );
            },
          )
        else
          RadioGroup<int>(
            groupValue: widget.state.currentQuestionAnswers.isNotEmpty
                ? widget.state.currentQuestionAnswers.first
                : null,
            onChanged: (int? value) {
              // In Study Mode, check if question is validated before locking
              if (widget.isStudyMode &&
                  widget.state.isCurrentQuestionValidated) {
                return; // Prevent changing answer if already validated
              }

              if (value != null) {
                context.read<QuizExecutionBloc>().add(
                  AnswerSelected(value, true),
                );
              }
            },
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.state.currentQuestion.options.length,
              itemBuilder: (context, index) {
                final option = widget.state.currentQuestion.options[index];
                final isSelected = widget.state.isOptionSelected(index);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    elevation: isSelected ? 4 : 1,
                    child: _buildOptionTile(
                      context,
                      questionType,
                      option,
                      index,
                      isSelected,
                    ),
                  ),
                );
              },
            ),
          ),

        // Show explanation in Study Mode after answering and validation
        if (widget.isStudyMode &&
            widget.state.isCurrentQuestionValidated &&
            widget.state.currentQuestion.explanation.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                        Icons.lightbulb_outline,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.explanationTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LaTeXText(
                    widget.state.currentQuestion.explanation,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    QuestionType questionType,
    String option,
    int index,
    bool isSelected,
  ) {
    final localizations = AppLocalizations.of(context)!;
    final translatedOption = QuestionTranslationHelper.translateOption(
      option,
      localizations,
    );

    final optionTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
    );

    // For multiple choice questions, use CheckboxListTile
    if (questionType == QuestionType.multipleChoice) {
      Color? tileColor;
      Color? activeColor;

      if (widget.isStudyMode &&
          isSelected &&
          widget.state.isCurrentQuestionValidated) {
        final isCorrect = widget.state.currentQuestion.correctAnswers.contains(
          index,
        );
        tileColor = isCorrect
            ? Colors.green.withValues(alpha: 0.2)
            : Colors.red.withValues(alpha: 0.2);
        activeColor = isCorrect ? Colors.green : Colors.red;
      }
      // Also highlight correct answers if we missed them?
      // For Multiple Choice it's tricky because you select multiple.
      // Let's keep it simple: Show Green for correct selected, Red for incorrect selected.

      return CheckboxListTile(
        title: IgnorePointer(
          child: LaTeXText(translatedOption, style: optionTextStyle),
        ),
        value: isSelected,
        onChanged: (bool? value) {
          context.read<QuizExecutionBloc>().add(
            AnswerSelected(index, value ?? false),
          );
        },
        activeColor: activeColor ?? Theme.of(context).primaryColor,
        tileColor: tileColor,
        controlAffinity: ListTileControlAffinity.leading,
      );
    }
    // For single choice, true/false, and essay questions, use RadioListTile
    else {
      Color? tileColor;
      Color? activeColor;

      if (widget.isStudyMode) {
        final isCorrect = widget.state.currentQuestion.correctAnswers.contains(
          index,
        );
        final isValidated = widget.state.isCurrentQuestionValidated;

        if (isValidated) {
          if (isSelected) {
            tileColor = isCorrect
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.red.withValues(alpha: 0.2);
            activeColor = isCorrect ? Colors.green : Colors.red;
          } else if (isCorrect) {
            // Show correct answer even if not selected
            tileColor = Colors.green.withValues(alpha: 0.2);
            activeColor = Colors.green;
          }
        }
      }

      return RadioListTile<int>(
        title: IgnorePointer(
          child: LaTeXText(translatedOption, style: optionTextStyle),
        ),
        value: index,
        activeColor: activeColor ?? Theme.of(context).primaryColor,
        tileColor: tileColor,
        controlAffinity: ListTileControlAffinity.leading,
      );
    }
  }

  Widget _buildEssayInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Assistant Button (Only in Study Mode and if AI is available)
          if (widget.isStudyMode && _isAiAvailable)
            _buildAiAssistantButton(context),

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
              widget.state.currentQuestion.explanation.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Column(
                children: [
                  // Standard Explanation
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3),
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
                              Icons.lightbulb_outline,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.explanationTitle,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        if (widget
                            .state
                            .currentQuestion
                            .explanation
                            .isNotEmpty) ...[
                          const SizedBox(height: 12),
                          LaTeXText(
                            widget.state.currentQuestion.explanation,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // AI Evaluation Section
                  if (_isAiAvailable) ...[
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

  Widget _buildAiAssistantButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: TextButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) =>
                  AIQuestionDialog(question: widget.state.currentQuestion),
            );
          },
          icon: const Icon(Icons.auto_awesome),
          label: Text(AppLocalizations.of(context)!.askAiAssistant),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
