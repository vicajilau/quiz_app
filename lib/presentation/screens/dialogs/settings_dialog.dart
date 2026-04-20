// Copyright (C) 2026 Víctor Carreras
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:platform_detail/platform_detail.dart';
import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/core/extensions/string_extension.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/core/theme/extensions/confirm_dialog_colors_extension.dart';
import 'package:quizdy/data/services/configuration_service.dart';
import 'package:quizdy/presentation/screens/dialogs/settings_dialog_widgets.dart';
import 'package:quizdy/presentation/screens/dialogs/settings_widgets/ai_settings_section.dart';
import 'package:quizdy/presentation/screens/dialogs/settings_widgets/advanced_settings_section.dart';
import 'package:quizdy/presentation/utils/support_issue_helper.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';
import 'package:quizdy/presentation/widgets/quizdy_markdown.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  bool _isLoading = true;
  String _appVersion = '-';
  bool _aiAssistantEnabled = true;
  bool _keepAiDraft = true;
  final TextEditingController _openAiApiKeyController = TextEditingController();
  final TextEditingController _geminiApiKeyController = TextEditingController();
  String? _apiKeyErrorMessage;
  String? _defaultAIModel;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _errorKey = GlobalKey();
  final GlobalKey _aiSettingsKey = GlobalKey();
  final configurationService = ServiceLocator.getIt<ConfigurationService>();

  bool _isGeminiKeyVisible = false;
  bool _isOpenAiKeyVisible = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      // Load all configurations
      final apiKey = await configurationService.getOpenAIApiKey();
      final geminiApiKey = await configurationService.getGeminiApiKey();
      _keepAiDraft = await configurationService.getAiKeepDraft();
      _defaultAIModel = await configurationService.getDefaultAIModel();
      _aiAssistantEnabled = await configurationService.getIsAiAvailable();
      final versionDetails = await PlatformDetail.versionDetails();
      final versionLabel = kReleaseMode
          ? versionDetails.version
          : '${versionDetails.version}-debug';

      if (mounted) {
        setState(() {
          _openAiApiKeyController.text = apiKey ?? '';
          _geminiApiKeyController.text = geminiApiKey ?? '';
          _appVersion = versionLabel;
          _isLoading = false; // Important: set as finished
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false; // Also set in case of error
        });
        context.presentSnackBar(
          AppLocalizations.of(context)!.errorLoadingSettings(e.toString()),
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

    await configurationService.saveAIAssistantEnabled(_aiAssistantEnabled);
    await configurationService.saveAiKeepDraft(_keepAiDraft);

    // Save OpenAI API Key securely (only if valid format)
    if (hasValidOpenAI) {
      await configurationService.saveOpenAIApiKey(apiKey);
    } else {
      await configurationService.deleteOpenAIApiKey();
    }

    // Save Gemini API Key securely (only if valid format)
    if (hasValidGemini) {
      await configurationService.saveGeminiApiKey(geminiApiKey);
    } else {
      await configurationService.deleteGeminiApiKey();
    }

    if (mounted) {
      context.pop();
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

  Future<void> _openSupportIssueUrl() async {
    final url = await SupportIssueHelper.buildIssueUri();
    final launched = await SupportIssueHelper.openIssueUrl(url);

    if (!launched && mounted) {
      context.presentSnackBar(
        AppLocalizations.of(context)!.couldNotOpenUrl(url.toString()),
      );
    }
  }

  Future<void> _openChangelog() async {
    final version = _normalizedVersion(_appVersion);
    if (version == null) {
      return;
    }

    final changelog = await _loadChangelogForVersion(version);
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final dialogColors = dialogContext.appColors;
        final localizations = AppLocalizations.of(dialogContext)!;

        return Dialog(
          backgroundColor: dialogColors.card,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: dialogColors.border, width: 1),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 640,
              maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.8,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: dialogColors.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          LucideIcons.sparkles,
                          size: 20,
                          color: dialogColors.subtitle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${localizations.versionLabel} $version',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: dialogColors.title,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              localizations.settingsTitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: dialogColors.subtitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: dialogColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: dialogColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: changelog == null
                            ? Center(
                                child: Text(
                                  AppLocalizations.of(
                                    dialogContext,
                                  )!.emptyPlaceholder,
                                  style: TextStyle(
                                    color: dialogColors.subtitle,
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                child: QuizdyMarkdown(
                                  data: changelog,
                                  style: TextStyle(color: dialogColors.title),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  QuizdyButton(
                    type: QuizdyButtonType.primary,
                    title: localizations.okButton,
                    expanded: true,
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String?> _loadChangelogForVersion(String version) async {
    try {
      final changelog = await rootBundle.loadString('CHANGELOG.md');
      return _extractChangelogSection(changelog, version);
    } catch (_) {
      return null;
    }
  }

  String? _extractChangelogSection(String changelog, String version) {
    final sectionHeading = RegExp(r'^## \[([^\]]+)\]');
    final lines = changelog.split('\n');
    final sectionLines = <String>[];
    var isCollecting = false;

    for (final line in lines) {
      final match = sectionHeading.firstMatch(line);
      if (match != null) {
        if (isCollecting) {
          break;
        }

        isCollecting = match.group(1) == version;
        continue;
      }

      if (isCollecting) {
        sectionLines.add(line);
      }
    }

    final section = sectionLines.join('\n').trim();
    return section.isEmpty ? null : section;
  }

  String? _normalizedVersion(String version) {
    final match = RegExp(r'^\d+\.\d+\.\d+').firstMatch(version);
    return match?.group(0);
  }

  /// Called when API keys change - saves them and refreshes the selector
  Future<void> _onApiKeyChanged() async {
    // Save API keys immediately so the selector can detect them
    final openaiKey = _openAiApiKeyController.text.trim();
    final geminiKey = _geminiApiKeyController.text.trim();

    if (openaiKey.isValidOpenAIApiKey) {
      await configurationService.saveOpenAIApiKey(openaiKey);
    } else {
      await configurationService.deleteOpenAIApiKey();
    }

    if (geminiKey.isValidGeminiApiKey) {
      await configurationService.saveGeminiApiKey(geminiKey);
    } else {
      await configurationService.deleteGeminiApiKey();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 520, // Node Eql6E width
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.settingsTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: colors.title,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.surface,
                      fixedSize: const Size(40, 40),
                      padding: EdgeInsets.zero,
                      shape: const CircleBorder(),
                    ),
                    icon: Icon(LucideIcons.x, size: 20, color: colors.subtitle),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (_aiSettingsKey.currentContext != null) {
                                    Scrollable.ensureVisible(
                                      _aiSettingsKey.currentContext!,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
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
                          if (kDebugMode) ...[
                            const SizedBox(height: 24),
                            const AdvancedSettingsSection(),
                          ],
                          const SizedBox(height: 24),
                          Divider(color: colors.border),
                          const SizedBox(height: 16),
                          SettingsOnboardingRow(colors: colors),
                          const SizedBox(height: 8),
                          SettingsPrivacyPolicyRow(colors: colors),
                          const SizedBox(height: 8),
                          SettingsSupportRow(
                            colors: colors,
                            onTap: _openSupportIssueUrl,
                          ),
                          const SizedBox(height: 8),
                          SettingsVersionRow(
                            colors: colors,
                            version: _appVersion,
                            onTap: _openChangelog,
                          ),
                        ],
                      ),
                    ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(height: 1, thickness: 1, color: colors.border),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                  child: QuizdyButton(
                    title: AppLocalizations.of(context)!.saveButton,
                    expanded: true,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _saveSettings,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
