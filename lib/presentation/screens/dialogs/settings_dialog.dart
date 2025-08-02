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

    setState(() {
      _selectedOrder = currentOrder;
      _examTimeEnabled = examTimeEnabled;
      _examTimeMinutes = examTimeMinutes;
      _aiAssistantEnabled = aiAssistantEnabled;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await ConfigurationService.instance.saveQuestionOrder(_selectedOrder);
    await ConfigurationService.instance.saveExamTimeEnabled(_examTimeEnabled);
    await ConfigurationService.instance.saveExamTimeMinutes(_examTimeMinutes);
    await ConfigurationService.instance.saveAIAssistantEnabled(
      _aiAssistantEnabled,
    );

    if (mounted) {
      context.pop(_selectedOrder);
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
                        suffixText: 'min',
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
