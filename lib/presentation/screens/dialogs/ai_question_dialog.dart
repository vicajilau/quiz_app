import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/extensions/string_extensions.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/question_type.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/data/services/configuration_service.dart';
import 'package:quiz_app/data/services/ai/ai_service.dart';
import 'package:quiz_app/presentation/widgets/ai_service_model_selector.dart';

import '../../../../domain/models/ai/chat_message.dart';
import 'widgets/ai_chat_bubble.dart';
import 'widgets/question_context_widget.dart';

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

  // Chat state
  final List<ChatMessage> _messages = [];

  // Service Selection
  AIService? _selectedService;
  String? _selectedModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Preprocesses the AI response to normalize LaTeX delimiters.
  String _preprocessResponse(String response) {
    // Replace $$ ... $$ with \[ ... \] for display math
    response = response.replaceAllMapped(
      RegExp(r'\$\$(.*?)\$\$', dotAll: true),
      (match) => '\\[${match.group(1)}\\]',
    );

    // Replace $ ... $ with \( ... \) for inline math
    response = response.replaceAllMapped(
      RegExp(r'(?<!\$)\$([^$]+)\$(?!\$)'),
      (match) => '\\(${match.group(1)}\\)',
    );

    return response;
  }

  String _buildPrompt(String userQuestion) {
    final localizations = AppLocalizations.of(context)!;

    String prompt = localizations.aiPrompt;
    prompt += "\n\n";
    prompt += "${localizations.questionLabel}: ${widget.question.text}\n";

    if (widget.question.options.isNotEmpty &&
        widget.question.type != QuestionType.essay) {
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

    // Add chat history context if needed, for now just the new question
    prompt += "\n${localizations.studentComment}: \"$userQuestion\"";

    return prompt;
  }

  Future<void> _askAI() async {
    final userText = _questionController.text.trim();
    if (userText.isEmpty) {
      return;
    }

    final localizations = AppLocalizations.of(context)!;

    setState(() {
      // Add user message to chat
      _messages.add(ChatMessage(content: userText, isUser: true));
      _isLoading = true;
    });

    _questionController.clear();
    _scrollToBottom();

    try {
      // Check if AI assistant is enabled
      final isAiEnabled = await ConfigurationService.instance
          .getAIAssistantEnabled();
      if (!isAiEnabled) {
        setState(() {
          _messages.add(
            ChatMessage(
              content: localizations.aiAssistantSettingsDescription,
              isUser: false,
              isError: true,
            ),
          );
          _isLoading = false;
        });
        return;
      }

      // Check if we have a selected AI service
      if (_selectedService == null) {
        setState(() {
          _messages.add(
            ChatMessage(
              content:
                  '${localizations.aiErrorResponse}\n\n${localizations.configureApiKeyMessage}',
              isUser: false,
              isError: true,
            ),
          );
          _isLoading = false;
        });
        return;
      }

      // Build the prompt with question context
      final prompt = _buildPrompt(userText);

      // Make API call to the selected AI service
      // Note: Passing _selectedModel if the service supports it would be better,
      // but getChatResponse might not accept it yet.
      // Assuming getChatResponse uses default or configured model.
      final response = await _selectedService!.getChatResponse(
        prompt,
        localizations,
        model: _selectedModel,
      );

      // Preprocess response to fix LaTeX delimiters
      final processedResponse = _preprocessResponse(response);

      setState(() {
        _messages.add(ChatMessage(content: processedResponse, isUser: false));
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              content:
                  '${localizations.aiErrorResponse}\n\n${localizations.errorLabel} ${e.toString().cleanErrorMessage()}',
              isUser: false,
              isError: true,
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
            // Header
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
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Content Area (Chat + Context)
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount:
                    2 +
                    _messages.length +
                    (_isLoading
                        ? 1
                        : 0), // Selector + Context + Messages + Loading
                itemBuilder: (context, index) {
                  // 1. Service Selector
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AiServiceModelSelector(
                        onServiceChanged: (service) {
                          setState(() {
                            _selectedService = service;
                          });
                        },
                        onModelChanged: (model) {
                          setState(() {
                            _selectedModel = model;
                          });
                        },
                        saveToPreferences: true,
                      ),
                    );
                  }

                  // 2. Question Context
                  if (index == 1) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: QuestionContextWidget(question: widget.question),
                    );
                  }

                  // 3. Chat Messages
                  final messageIndex = index - 2;
                  if (messageIndex < _messages.length) {
                    final message = _messages[messageIndex];
                    return AiChatBubble(
                      content: message.content,
                      isUser: message.isUser,
                      isError: message.isError,
                      aiServiceName: message.isUser
                          ? null
                          : _selectedService?.serviceName,
                    );
                  }

                  // 4. Loading Indicator
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
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
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _questionController,
                  builder: (_, value, _) {
                    return FilledButton(
                      onPressed: (_isLoading || value.text.trim().isEmpty)
                          ? null
                          : _askAI,
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
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
