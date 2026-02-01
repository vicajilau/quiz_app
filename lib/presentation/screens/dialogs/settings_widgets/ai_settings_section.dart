import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/extensions/string_extensions.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../widgets/ai_service_model_selector.dart';

/// A widget that handles the AI Assistant settings section.
///
/// Allows the user to enable/disable the AI assistant, configure API keys for Gemini and OpenAI,
/// select the default AI model, and toggle the behavior for keeping AI drafts.
class AiSettingsSection extends StatelessWidget {
  final bool enabled;
  final bool keepDraft;
  final TextEditingController geminiController;
  final TextEditingController openAiController;
  final String? defaultModel;
  final String? errorMessage;
  final bool isGeminiVisible;
  final bool isOpenAiVisible;
  final GlobalKey? errorKey;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<bool> onKeepDraftChanged;
  final VoidCallback onToggleGeminiVisibility;
  final VoidCallback onToggleOpenAiVisibility;
  final VoidCallback onApiKeyChanged;

  const AiSettingsSection({
    super.key,
    required this.enabled,
    required this.keepDraft,
    required this.geminiController,
    required this.openAiController,
    this.defaultModel,
    this.errorMessage,
    required this.isGeminiVisible,
    required this.isOpenAiVisible,
    this.errorKey,
    required this.onEnabledChanged,
    required this.onKeepDraftChanged,
    required this.onToggleGeminiVisibility,
    required this.onToggleOpenAiVisibility,
    required this.onApiKeyChanged,
  });

  Future<void> _openAiApiKeysUrl(BuildContext context) async {
    final url = Uri.parse('https://platform.openai.com/api-keys');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
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

  Future<void> _openGeminiApiKeysUrl(BuildContext context) async {
    final url = Uri.parse('https://aistudio.google.com/app/apikey');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
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
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                  AppLocalizations.of(context)!.aiAssistantSettingsTitle,
                ),
              ),
            ],
          ),
          subtitle: Text(
            AppLocalizations.of(context)!.aiAssistantSettingsDescription,
          ),
          value: enabled,
          onChanged: onEnabledChanged,
        ),
        if (enabled) ...[
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.aiKeepDraftTitle),
            subtitle: Text(
              AppLocalizations.of(context)!.aiKeepDraftDescription,
            ),
            value: keepDraft,
            onChanged: onKeepDraftChanged,
          ),
          const SizedBox(height: 16),
          _buildApiKeyField(
            context,
            controller: geminiController,
            label: AppLocalizations.of(context)!.geminiApiKeyLabel,
            hint: AppLocalizations.of(context)!.geminiApiKeyHint,
            description: AppLocalizations.of(context)!.geminiApiKeyDescription,
            isVisible: isGeminiVisible,
            onToggleVisibility: onToggleGeminiVisibility,
            isValid: geminiController.text.isValidGeminiApiKey,
            onInfoPressed: () => _openGeminiApiKeysUrl(context),
          ),
          const SizedBox(height: 16),
          _buildApiKeyField(
            context,
            controller: openAiController,
            label: AppLocalizations.of(context)!.openaiApiKeyLabel,
            hint: AppLocalizations.of(context)!.openaiApiKeyHint,
            description: AppLocalizations.of(context)!.openaiApiKeyDescription,
            isVisible: isOpenAiVisible,
            onToggleVisibility: onToggleOpenAiVisibility,
            isValid: openAiController.text.isValidOpenAIApiKey,
            onInfoPressed: () => _openAiApiKeysUrl(context),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 8),
            Container(
              key: errorKey,
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
                      errorMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (geminiController.text.isValidGeminiApiKey ||
              openAiController.text.isValidOpenAIApiKey) ...[
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.aiDefaultModelTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context)!.aiDefaultModelDescription,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            AiServiceModelSelector(
              initialModel: defaultModel,
              saveToPreferences: true,
              geminiApiKey: geminiController.text.isValidGeminiApiKey
                  ? geminiController.text.trim()
                  : null,
              openaiApiKey: openAiController.text.isValidOpenAIApiKey
                  ? openAiController.text.trim()
                  : null,
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildApiKeyField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required String description,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    required bool isValid,
    required VoidCallback onInfoPressed,
  }) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            hintMaxLines: 3,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: isValid
                    ? Theme.of(context).colorScheme.outline
                    : Theme.of(context).colorScheme.error,
              ),
            ),
            prefixIcon: Icon(
              Icons.key,
              color: isValid ? null : Theme.of(context).colorScheme.error,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isValid)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: onToggleVisibility,
                ),
              ],
            ),
          ),
          obscureText: !isVisible,
          onChanged: (value) async {
            onApiKeyChanged();
          },
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onInfoPressed,
              icon: const Icon(Icons.info_outline),
              tooltip: AppLocalizations.of(
                context,
              )!.getApiKeyTooltip, // Assuming generic tooltip or use specific if passed
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
