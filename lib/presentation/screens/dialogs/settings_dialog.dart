import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/services/configuration_service.dart';
import '../../../domain/models/quiz/question_order.dart';

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
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    final currentOrder = await ConfigurationService.instance.getQuestionOrder();
    final examTimeEnabled = await ConfigurationService.instance
        .getExamTimeEnabled();
    final examTimeMinutes = await ConfigurationService.instance
        .getExamTimeMinutes();
    final aiAssistantEnabled = await ConfigurationService.instance
        .getAIAssistantEnabled();
    final apiKey = await ConfigurationService.instance.getOpenAIApiKey();

    setState(() {
      _selectedOrder = currentOrder;
      _examTimeEnabled = examTimeEnabled;
      _examTimeMinutes = examTimeMinutes;
      _aiAssistantEnabled = aiAssistantEnabled;
      _apiKeyController.text = apiKey ?? '';
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    // Validar que si AI Assistant está habilitado, se debe proporcionar API Key
    final apiKey = _apiKeyController.text.trim();
    if (_aiAssistantEnabled && apiKey.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.aiAssistantRequiresApiKeyError,
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return; // No guardar si falta la validación
    }

    await ConfigurationService.instance.saveQuestionOrder(_selectedOrder);
    await ConfigurationService.instance.saveExamTimeEnabled(_examTimeEnabled);
    await ConfigurationService.instance.saveExamTimeMinutes(_examTimeMinutes);
    await ConfigurationService.instance.saveAIAssistantEnabled(
      _aiAssistantEnabled,
    );

    // Save API Key securely
    if (apiKey.isNotEmpty) {
      await ConfigurationService.instance.saveOpenAIApiKey(apiKey);
    } else {
      await ConfigurationService.instance.deleteOpenAIApiKey();
    }

    if (mounted) {
      context.pop(_selectedOrder);
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
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
                    return RadioListTile<QuestionOrder>(
                      title: Text(_getLocalizedOrderName(context, order)),
                      subtitle: Text(
                        _getLocalizedOrderDescription(context, order),
                      ),
                      value: order,
                      groupValue: _selectedOrder,
                      onChanged: (QuestionOrder? value) {
                        if (value != null) {
                          setState(() {
                            _selectedOrder = value;
                          });
                        }
                      },
                    );
                  }),

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
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.aiAssistantSettingsTitle,
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
                    TextFormField(
                      controller: _apiKeyController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(
                          context,
                        )!.openaiApiKeyLabel,
                        hintText: AppLocalizations.of(
                          context,
                        )!.openaiApiKeyHint,
                        helperText: AppLocalizations.of(
                          context,
                        )!.openaiApiKeyDescription,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _apiKeyController.text.trim().isEmpty
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.key,
                          color: _apiKeyController.text.trim().isEmpty
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ),
                        suffixIcon: _apiKeyController.text.trim().isEmpty
                            ? Icon(
                                Icons.warning,
                                color: Theme.of(context).colorScheme.error,
                              )
                            : Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                      ),
                      obscureText: true,
                      maxLines: 1,
                      onChanged: (value) {
                        setState(() {
                          // Trigger rebuild to update visual indicators
                        });
                      },
                    ),
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
