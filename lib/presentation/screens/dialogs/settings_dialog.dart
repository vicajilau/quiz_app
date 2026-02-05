import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/extensions/string_extensions.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/data/services/configuration_service.dart';
import 'package:quiz_app/domain/models/quiz/question_order.dart';
import 'package:quiz_app/presentation/screens/dialogs/settings_widgets/ai_settings_section.dart';
import 'package:quiz_app/presentation/screens/dialogs/settings_widgets/exam_settings_section.dart';
import 'package:quiz_app/presentation/screens/dialogs/settings_widgets/question_settings_section.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  QuestionOrder _selectedOrder = QuestionOrder.random;
  bool _isLoading = true;
  bool _examTimeEnabled = false;
  int _examTimeMinutes = 60;
  bool _aiAssistantEnabled = true;
  bool _randomizeAnswers = false;
  bool _showCorrectAnswerCount = false;
  bool _keepAiDraft = true;
  final TextEditingController _openAiApiKeyController = TextEditingController();
  final TextEditingController _geminiApiKeyController = TextEditingController();
  String? _apiKeyErrorMessage;
  String? _defaultAIModel;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _errorKey = GlobalKey();
  final GlobalKey _aiSettingsKey = GlobalKey();

  bool _isGeminiKeyVisible = false;
  bool _isOpenAiKeyVisible = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final service = ConfigurationService.instance;

      // Load all configurations
      _selectedOrder = await service.getQuestionOrder();
      _examTimeEnabled = await service.getExamTimeEnabled();
      _examTimeMinutes = await service.getExamTimeMinutes();
      final savedAiAssistantEnabled = await service.getAIAssistantEnabled();
      final apiKey = await service.getOpenAIApiKey();
      final geminiApiKey = await service.getGeminiApiKey();
      _randomizeAnswers = await service.getRandomizeAnswers();
      _showCorrectAnswerCount = await service.getShowCorrectAnswerCount();
      _keepAiDraft = await service.getAiKeepDraft();
      _defaultAIModel = await service.getDefaultAIModel();

      // Only enable AI Assistant if there's at least one API key configured
      final hasAnyApiKey =
          (apiKey != null && apiKey.isNotEmpty) ||
          (geminiApiKey != null && geminiApiKey.isNotEmpty);
      _aiAssistantEnabled = savedAiAssistantEnabled && hasAnyApiKey;

      if (mounted) {
        setState(() {
          _openAiApiKeyController.text = apiKey ?? '';
          _geminiApiKeyController.text = geminiApiKey ?? '';
          _isLoading = false; // Important: set as finished
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false; // Also set in case of error
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorLoadingSettings(e.toString()),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    // Clear previous error message
    setState(() {
      _apiKeyErrorMessage = null;
    });

    // Validate that if AI Assistant is enabled, at least one valid API Key must be provided
    final apiKey = _openAiApiKeyController.text.trim();
    final geminiApiKey = _geminiApiKeyController.text.trim();
    final hasValidOpenAI = apiKey.isValidOpenAIApiKey;
    final hasValidGemini = geminiApiKey.isValidGeminiApiKey;

    if (_aiAssistantEnabled && !hasValidOpenAI && !hasValidGemini) {
      setState(() {
        _apiKeyErrorMessage = AppLocalizations.of(
          context,
        )!.aiRequiresAtLeastOneApiKeyError;
      });
      // Scroll to error message after frame renders
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_errorKey.currentContext != null) {
          Scrollable.ensureVisible(
            _errorKey.currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      return; // Don't save if validation fails
    }

    await ConfigurationService.instance.saveQuestionOrder(_selectedOrder);
    await ConfigurationService.instance.saveExamTimeEnabled(_examTimeEnabled);
    await ConfigurationService.instance.saveExamTimeMinutes(_examTimeMinutes);
    await ConfigurationService.instance.saveAIAssistantEnabled(
      _aiAssistantEnabled,
    );
    await ConfigurationService.instance.saveRandomizeAnswers(_randomizeAnswers);
    await ConfigurationService.instance.saveShowCorrectAnswerCount(
      _showCorrectAnswerCount,
    );
    await ConfigurationService.instance.saveAiKeepDraft(_keepAiDraft);

    // Save OpenAI API Key securely (only if valid format)
    if (hasValidOpenAI) {
      await ConfigurationService.instance.saveOpenAIApiKey(apiKey);
    } else {
      await ConfigurationService.instance.deleteOpenAIApiKey();
    }

    // Save Gemini API Key securely (only if valid format)
    if (hasValidGemini) {
      await ConfigurationService.instance.saveGeminiApiKey(geminiApiKey);
    } else {
      await ConfigurationService.instance.deleteGeminiApiKey();
    }

    if (mounted) {
      context.pop(_selectedOrder);
    }
  }

  @override
  void dispose() {
    _openAiApiKeyController.dispose();
    _geminiApiKeyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _clearApiKeyError() {
    if (_apiKeyErrorMessage != null) {
      setState(() {
        _apiKeyErrorMessage = null;
      });
    }
  }

  /// Called when API keys change - saves them and refreshes the selector
  Future<void> _onApiKeyChanged() async {
    // Save API keys immediately so the selector can detect them
    final openaiKey = _openAiApiKeyController.text.trim();
    final geminiKey = _geminiApiKeyController.text.trim();

    if (openaiKey.isValidOpenAIApiKey) {
      await ConfigurationService.instance.saveOpenAIApiKey(openaiKey);
    } else {
      await ConfigurationService.instance.deleteOpenAIApiKey();
    }

    if (geminiKey.isValidGeminiApiKey) {
      await ConfigurationService.instance.saveGeminiApiKey(geminiKey);
    } else {
      await ConfigurationService.instance.deleteGeminiApiKey();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.questionOrderConfigTitle),
      content: _isLoading
          ? const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QuestionSettingsSection(
                    selectedOrder: _selectedOrder,
                    randomizeAnswers: _randomizeAnswers,
                    showCorrectAnswerCount: _showCorrectAnswerCount,
                    onOrderChanged: (value) =>
                        setState(() => _selectedOrder = value),
                    onRandomizeAnswersChanged: (value) =>
                        setState(() => _randomizeAnswers = value),
                    onShowCorrectAnswerCountChanged: (value) =>
                        setState(() => _showCorrectAnswerCount = value),
                  ),
                  ExamSettingsSection(
                    enabled: _examTimeEnabled,
                    minutes: _examTimeMinutes,
                    onEnabledChanged: (value) =>
                        setState(() => _examTimeEnabled = value),
                    onMinutesChanged: (value) =>
                        setState(() => _examTimeMinutes = value),
                  ),
                  AiSettingsSection(
                    key: _aiSettingsKey,
                    enabled: _aiAssistantEnabled,
                    keepDraft: _keepAiDraft,
                    geminiController: _geminiApiKeyController,
                    openAiController: _openAiApiKeyController,
                    defaultModel: _defaultAIModel,
                    errorMessage: _apiKeyErrorMessage,
                    isGeminiVisible: _isGeminiKeyVisible,
                    isOpenAiVisible: _isOpenAiKeyVisible,
                    errorKey: _errorKey,
                    onEnabledChanged: (value) {
                      setState(() => _aiAssistantEnabled = value);
                      if (value) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_aiSettingsKey.currentContext != null) {
                            Scrollable.ensureVisible(
                              _aiSettingsKey.currentContext!,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        });
                      }
                    },
                    onKeepDraftChanged: (value) =>
                        setState(() => _keepAiDraft = value),
                    onToggleGeminiVisibility: () => setState(
                      () => _isGeminiKeyVisible = !_isGeminiKeyVisible,
                    ),
                    onToggleOpenAiVisibility: () => setState(
                      () => _isOpenAiKeyVisible = !_isOpenAiKeyVisible,
                    ),
                    onApiKeyChanged: () async {
                      _clearApiKeyError();
                      await _onApiKeyChanged();
                      setState(() {
                        // Rebuild
                      });
                    },
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveSettings,
          child: Text(AppLocalizations.of(context)!.saveButton),
        ),
      ],
    );
  }
}
