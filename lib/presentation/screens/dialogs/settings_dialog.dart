import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/extensions/string_extensions.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/services/configuration_service.dart';
import '../../../domain/models/quiz/question_order.dart';
import '../../widgets/ai_service_model_selector.dart';

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

  Future<void> _openAiApiKeysUrl() async {
    final url = Uri.parse('https://platform.openai.com/api-keys');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.couldNotOpenUrl(url.toString()),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _openGeminiApiKeysUrl() async {
    final url = Uri.parse('https://aistudio.google.com/app/apikey');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.couldNotOpenUrl(url.toString()),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _openAiApiKeyController.dispose();
    _geminiApiKeyController.dispose();
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Order Section
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.questionOrderConfigDescription,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ...QuestionOrder.values.map((order) {
                    return RadioGroup(
                      groupValue: _selectedOrder,
                      onChanged: (QuestionOrder? value) {
                        if (value != null) {
                          setState(() {
                            _selectedOrder = value;
                          });
                        }
                      },
                      child: RadioListTile<QuestionOrder>(
                        title: Text(_getLocalizedOrderName(context, order)),
                        subtitle: Text(
                          _getLocalizedOrderDescription(context, order),
                        ),
                        value: order,
                      ),
                    );
                  }),

                  // Answer Randomization Section
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: Text(
                      AppLocalizations.of(context)!.randomizeAnswersTitle,
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!.randomizeAnswersDescription,
                    ),
                    value: _randomizeAnswers,
                    onChanged: (bool value) {
                      setState(() {
                        _randomizeAnswers = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: Text(
                      AppLocalizations.of(context)!.showCorrectAnswerCountTitle,
                    ),
                    subtitle: Text(
                      AppLocalizations.of(
                        context,
                      )!.showCorrectAnswerCountDescription,
                    ),
                    value: _showCorrectAnswerCount,
                    onChanged: (bool value) {
                      setState(() {
                        _showCorrectAnswerCount = value;
                      });
                    },
                  ),

                  // Exam Time Limit Section
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: Text(
                      AppLocalizations.of(context)!.examTimeLimitTitle,
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!.examTimeLimitDescription,
                    ),
                    value: _examTimeEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _examTimeEnabled = value;
                      });
                    },
                  ),

                  if (_examTimeEnabled) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _examTimeMinutes.toString(),
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        )!.timeLimitMinutes,
                        border: const OutlineInputBorder(),
                        suffixText: AppLocalizations.of(
                          context,
                        )!.minutesAbbreviation,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final minutes = int.tryParse(value);
                        if (minutes != null && minutes > 0) {
                          _examTimeMinutes = minutes;
                        }
                      },
                    ),
                  ],

                  // AI Assistant Section
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    title: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.aiAssistantSettingsTitle,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      AppLocalizations.of(
                        context,
                      )!.aiAssistantSettingsDescription,
                    ),
                    value: _aiAssistantEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _aiAssistantEnabled = value;
                      });
                    },
                  ),

                  if (_aiAssistantEnabled) ...[
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(
                        AppLocalizations.of(context)!.aiKeepDraftTitle,
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context)!.aiKeepDraftDescription,
                      ),
                      value: _keepAiDraft,
                      onChanged: (bool value) {
                        setState(() {
                          _keepAiDraft = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _geminiApiKeyController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        )!.geminiApiKeyLabel,
                        hintText: AppLocalizations.of(
                          context,
                        )!.geminiApiKeyHint,
                        hintMaxLines: 3,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                _geminiApiKeyController.text.isValidGeminiApiKey
                                ? Theme.of(context).colorScheme.outline
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.key,
                          color:
                              _geminiApiKeyController.text.isValidGeminiApiKey
                              ? null
                              : Theme.of(context).colorScheme.error,
                        ),
                        suffixIcon:
                            _geminiApiKeyController.text.isValidGeminiApiKey
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                      ),
                      obscureText: true,
                      onChanged: (value) async {
                        _clearApiKeyError();
                        await _onApiKeyChanged();
                        setState(() {
                          // Trigger rebuild to update visual indicators
                        });
                      },
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.geminiApiKeyDescription,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _openGeminiApiKeysUrl,
                          icon: const Icon(Icons.info_outline),
                          tooltip: AppLocalizations.of(
                            context,
                          )!.getGeminiApiKeyTooltip,
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _openAiApiKeyController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        )!.openaiApiKeyLabel,
                        hintText: AppLocalizations.of(
                          context,
                        )!.openaiApiKeyHint,
                        hintMaxLines: 3,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                _openAiApiKeyController.text.isValidOpenAIApiKey
                                ? Theme.of(context).colorScheme.outline
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.key,
                          color:
                              _openAiApiKeyController.text.isValidOpenAIApiKey
                              ? null
                              : Theme.of(context).colorScheme.error,
                        ),
                        suffixIcon:
                            _openAiApiKeyController.text.isValidOpenAIApiKey
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                      ),
                      obscureText: true,
                      onChanged: (value) async {
                        _clearApiKeyError();
                        await _onApiKeyChanged();
                        setState(() {
                          // Trigger rebuild to update visual indicators
                        });
                      },
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.openaiApiKeyDescription,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _openAiApiKeysUrl,
                          icon: const Icon(Icons.info_outline),
                          tooltip: AppLocalizations.of(
                            context,
                          )!.getApiKeyTooltip,
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      ],
                    ),
                    // Error message for API keys
                    if (_apiKeyErrorMessage != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.error,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _apiKeyErrorMessage!,
                                style: Theme.of(context).textTheme.bodySmall
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
                    ],

                    // Default AI Model Section (only show if at least one valid API key is configured)
                    if (_geminiApiKeyController.text.isValidGeminiApiKey ||
                        _openAiApiKeyController.text.isValidOpenAIApiKey) ...[
                      const SizedBox(height: 24),
                      Text(
                        AppLocalizations.of(context)!.aiDefaultModelTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.aiDefaultModelDescription,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      AiServiceModelSelector(
                        initialModel: _defaultAIModel,
                        saveToPreferences: true,
                        geminiApiKey:
                            _geminiApiKeyController.text.isValidGeminiApiKey
                            ? _geminiApiKeyController.text.trim()
                            : null,
                        openaiApiKey:
                            _openAiApiKeyController.text.isValidOpenAIApiKey
                            ? _openAiApiKeyController.text.trim()
                            : null,
                      ),
                    ],
                  ],

                  // Future settings sections can be added here
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

  String _getLocalizedOrderName(BuildContext context, QuestionOrder order) {
    switch (order) {
      case QuestionOrder.ascending:
        return AppLocalizations.of(context)!.questionOrderAscending;
      case QuestionOrder.descending:
        return AppLocalizations.of(context)!.questionOrderDescending;
      case QuestionOrder.random:
        return AppLocalizations.of(context)!.questionOrderRandom;
    }
  }

  String _getLocalizedOrderDescription(
    BuildContext context,
    QuestionOrder order,
  ) {
    switch (order) {
      case QuestionOrder.ascending:
        return AppLocalizations.of(context)!.questionOrderAscendingDesc;
      case QuestionOrder.descending:
        return AppLocalizations.of(context)!.questionOrderDescendingDesc;
      case QuestionOrder.random:
        return AppLocalizations.of(context)!.questionOrderRandomDesc;
    }
  }
}
