import 'package:flutter/material.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/data/services/ai/ai_service_selector.dart';
import 'package:quiz_app/data/services/ai/ai_service.dart';
import 'package:quiz_app/data/services/configuration_service.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

class AIQuestionDialog extends StatefulWidget {
  final Question question;

  const AIQuestionDialog({super.key, required this.question});

  @override
  State<AIQuestionDialog> createState() => _AIQuestionDialogState();
}

class _AIQuestionDialogState extends State<AIQuestionDialog> {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _aiResponse;
  List<AIService> _availableServices = [];
  AIService? _selectedService;
  bool _isLoadingServices = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableServices();
  }

  Future<void> _loadAvailableServices() async {
    try {
      final services = await AIServiceSelector.instance.getAvailableServices();
      if (mounted) {
        setState(() {
          _availableServices = services;
          _selectedService = services.isNotEmpty ? services.first : null;
          _isLoadingServices = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingServices = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _buildPrompt() {
    final localizations = AppLocalizations.of(context)!;

    String prompt = localizations.aiPrompt;
    prompt += "\n\n";
    prompt += "${localizations.questionLabel}: ${widget.question.text}\n";

    if (widget.question.options.isNotEmpty) {
      prompt += "${localizations.optionsLabel}:\n";
      for (int i = 0; i < widget.question.options.length; i++) {
        final letter = String.fromCharCode(65 + i); // A, B, C, etc.
        prompt += "$letter) ${widget.question.options[i]}\n";
      }
    }

    if (widget.question.explanation.isNotEmpty) {
      prompt +=
          "\n${localizations.explanationLabel}: ${widget.question.explanation}\n";
    }

    prompt +=
        "\n${localizations.studentComment}: \"${_questionController.text}\"";

    return prompt;
  }

  /// Extrae el mensaje de error limpio sin prefijos "Exception:"
  String _extractErrorMessage(Object error) {
    String errorMessage = error.toString();

    // Remover prefijo "Exception: " si existe
    if (errorMessage.startsWith('Exception: ')) {
      errorMessage = errorMessage.substring('Exception: '.length);
    }

    // Remover prefijo "OpenAI API Error: " si existe (por si acaso)
    if (errorMessage.startsWith('OpenAI API Error: ')) {
      errorMessage = errorMessage.substring('OpenAI API Error: '.length);
    }

    return errorMessage.trim();
  }

  Future<void> _askAI() async {
    if (_questionController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _aiResponse = null;
    });

    final localizations = AppLocalizations.of(context)!;

    try {
      // Check if AI assistant is enabled
      final isAiEnabled = await ConfigurationService.instance
          .getAIAssistantEnabled();
      if (!isAiEnabled) {
        setState(() {
          _aiResponse = localizations.aiAssistantSettingsDescription;
          _isLoading = false;
        });
        return;
      }

      // Check if we have a selected AI service
      if (_selectedService == null) {
        setState(() {
          _aiResponse =
              '${localizations.aiErrorResponse}\n\n${localizations.configureApiKeyMessage}';
          _isLoading = false;
        });
        return;
      }

      // Build the prompt with question context
      final prompt = _buildPrompt();

      // Make API call to the selected AI service
      final response = await _selectedService!.getChatResponse(
        prompt,
        localizations,
      );

      setState(() {
        _aiResponse = response;
        _isLoading = false;
      });

      // Scroll to response
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiResponse =
              '${localizations.aiErrorResponse}\n\n${localizations.errorLabel} ${_extractErrorMessage(e)}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.aiButtonText,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.auto_awesome,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    localizations.aiAssistantTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // AI Service Selector
            if (_isLoadingServices) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      localizations.loadingAiServices,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else if (_availableServices.length > 1) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.psychology,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      localizations.aiServiceLabel,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<AIService>(
                          value: _selectedService,
                          isExpanded: true,
                          items: _availableServices.map((service) {
                            return DropdownMenuItem<AIService>(
                              value: service,
                              child: Row(
                                children: [
                                  Icon(
                                    service.serviceName.contains('OpenAI')
                                        ? Icons.auto_awesome
                                        : Icons.auto_fix_high,
                                    size: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    service.serviceName,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (AIService? newService) {
                            if (newService != null) {
                              setState(() {
                                _selectedService = newService;
                                _aiResponse =
                                    null; // Clear previous response when switching
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else if (_availableServices.isEmpty && !_isLoadingServices) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_outlined,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        localizations.configureApiKeyMessage,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else if (_availableServices.length == 1) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedService?.serviceName.contains('OpenAI') == true
                          ? Icons.auto_awesome
                          : Icons.auto_fix_high,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      localizations.usingAiService(
                        _selectedService?.serviceName ?? 'AI',
                      ),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Question context
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.questionContext,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.question.text,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (widget.question.options.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...widget.question.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final letter = String.fromCharCode(65 + index);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          "$letter) $option",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Chat area
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_aiResponse != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _selectedService?.serviceName.contains(
                                            'OpenAI',
                                          ) ==
                                          true
                                      ? Icons.auto_awesome
                                      : Icons.auto_fix_high,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _selectedService?.serviceName ?? 'AI',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  localizations.aiAssistant,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            GptMarkdown(
                              _aiResponse!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_isLoading) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              localizations.aiThinking,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Input area
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: localizations.askAIHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 3,
                    minLines: 1,
                    onSubmitted: (_) => _askAI(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _isLoading ? null : _askAI,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
