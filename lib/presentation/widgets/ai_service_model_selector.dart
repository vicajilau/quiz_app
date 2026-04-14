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

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/core/theme/extensions/ai_assistant_theme.dart';
import 'package:quizdy/data/services/configuration_service.dart';
import 'package:quizdy/domain/models/ai/ai_model_catalog.dart';

/// Displays a collapsible selector with two dropdowns:
/// 1. Provider — only shows providers that have a configured API key.
/// 2. Model — filtered to the selected provider's models.
///
/// Reloads the available provider list whenever [geminiApiKey] or
/// [openaiApiKey] change, so the selector updates immediately when the user
/// types a key in the settings screen.
class AiServiceModelSelector extends StatefulWidget {
  final String? initialModel;
  final ValueChanged<String?>? onModelChanged;
  final ValueChanged<bool>? onLoadingChanged;
  final bool enabled;
  final bool saveToPreferences;

  /// Pass the current (possibly unconfirmed) Gemini key so the widget can
  /// react to it changing without waiting for a save.
  final String? geminiApiKey;

  /// Pass the current (possibly unconfirmed) OpenAI key so the widget can
  /// react to it changing without waiting for a save.
  final String? openaiApiKey;

  /// Pass the current local GGUF model path so the widget can show the
  /// llama provider as soon as a model file is selected.
  final String? localModelPath;

  const AiServiceModelSelector({
    super.key,
    this.initialModel,
    this.onModelChanged,
    this.onLoadingChanged,
    this.enabled = true,
    this.saveToPreferences = false,
    this.geminiApiKey,
    this.openaiApiKey,
    this.localModelPath,
  });

  @override
  State<AiServiceModelSelector> createState() => _AiServiceModelSelectorState();
}

class _AiServiceModelSelectorState extends State<AiServiceModelSelector> {
  List<String> _availableProviderIds = [];
  String? _selectedProviderId;
  String? _selectedModelId;
  bool _isExpanded = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableProviders();
  }

  @override
  void didUpdateWidget(AiServiceModelSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.geminiApiKey != widget.geminiApiKey ||
        oldWidget.openaiApiKey != widget.openaiApiKey ||
        oldWidget.localModelPath != widget.localModelPath) {
      _loadAvailableProviders();
    }
  }

  Future<void> _loadAvailableProviders() async {
    try {
      final configService = ServiceLocator.getIt<ConfigurationService>();

      // Determine which providers have a key / model configured.
      final geminiKey = await configService.getGeminiApiKey();
      final openaiKey = await configService.getOpenAIApiKey();
      final localPath = await configService.getLocalModelPath();

      final available = <String>[
        if ((geminiKey?.isNotEmpty ?? false)) AiModelCatalog.geminiProviderId,
        if ((openaiKey?.isNotEmpty ?? false)) AiModelCatalog.openaiProviderId,
        if (localPath != null && localPath.isNotEmpty)
          AiModelCatalog.llamaProviderId,
      ];

      if (!mounted) return;

      // Load saved model preference.
      final savedModel = await configService.getDefaultAIModel();

      String? resolvedProviderId;
      String? resolvedModelId;

      // Try to honour the saved / initial model if its provider is available.
      final candidateModelId =
          (savedModel != null && AiModelCatalog.forModelId(savedModel) != null)
          ? savedModel
          : widget.initialModel != null &&
                AiModelCatalog.forModelId(widget.initialModel!) != null
          ? widget.initialModel
          : null;

      if (candidateModelId != null) {
        final entry = AiModelCatalog.forModelId(candidateModelId)!;
        if (available.contains(entry.providerId)) {
          resolvedProviderId = entry.providerId;
          resolvedModelId = candidateModelId;
        }
      }

      // Fall back to the first available provider and its first model.
      if (resolvedProviderId == null && available.isNotEmpty) {
        resolvedProviderId = available.first;
        final models = AiModelCatalog.forProvider(resolvedProviderId);
        resolvedModelId = models.isNotEmpty ? models.first.modelId : null;
      }

      if (mounted) {
        setState(() {
          _availableProviderIds = available;
          _selectedProviderId = resolvedProviderId;
          _selectedModelId = resolvedModelId;
          _isLoading = false;
        });
        widget.onModelChanged?.call(resolvedModelId);
        widget.onLoadingChanged?.call(false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        widget.onLoadingChanged?.call(false);
      }
    }
  }

  void _onProviderSelected(String? providerId) {
    if (providerId == null || providerId == _selectedProviderId) return;
    final models = AiModelCatalog.forProvider(providerId);
    final newModelId = models.isNotEmpty ? models.first.modelId : null;
    setState(() {
      _selectedProviderId = providerId;
      _selectedModelId = newModelId;
    });
    widget.onModelChanged?.call(newModelId);
    if (widget.saveToPreferences && newModelId != null) {
      ServiceLocator.getIt<ConfigurationService>().saveDefaultAIModel(
        newModelId,
      );
    }
  }

  Future<void> _onModelSelected(String? modelId) async {
    if (modelId == null || modelId == _selectedModelId) return;
    setState(() => _selectedModelId = modelId);
    widget.onModelChanged?.call(modelId);
    if (widget.saveToPreferences) {
      await ServiceLocator.getIt<ConfigurationService>().saveDefaultAIModel(
        modelId,
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final aiTheme = Theme.of(context).extension<AiAssistantTheme>()!;
    final headerBg = aiTheme.selectorHeaderBg;
    final contentBg = aiTheme.selectorContentBg;
    final borderColor = aiTheme.selectorBorderColor;
    final labelColor = aiTheme.selectorLabelColor;
    final textColor = aiTheme.selectorTextColor;
    final chevronColor = aiTheme.selectorLabelColor;

    Widget buildDropdown<T>({
      required String label,
      required T? value,
      required List<DropdownMenuItem<T>> items,
      required ValueChanged<T?>? onChanged,
      String? loadingText,
      String? emptyText,
      String Function(T value)? selectedLabelOf,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.centerLeft,
            child: _isLoading
                ? Text(
                    loadingText ?? localizations.aiServicesLoading,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  )
                : items.isEmpty && emptyText != null
                ? Text(
                    emptyText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<T>(
                      value: value,
                      isExpanded: true,
                      icon: Icon(
                        LucideIcons.chevronDown,
                        color: chevronColor,
                        size: 16,
                      ),
                      dropdownColor: headerBg,
                      selectedItemBuilder: (context) => items
                          .map(
                            (item) => Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                item.value != null && selectedLabelOf != null
                                    ? selectedLabelOf(item.value as T)
                                    : item.value?.toString() ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      items: items,
                      onChanged: widget.enabled ? onChanged : null,
                    ),
                  ),
          ),
        ],
      );
    }

    Widget buildHeader(bool expanded) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: headerBg,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(12),
            bottom: Radius.circular(expanded ? 0 : 12),
          ),
        ),
        child: Row(
          children: [
            Icon(
              LucideIcons.sparkles,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                localizations.aiDefaultModelTitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,

                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Icon(
              expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
              size: 16,
              color: chevronColor,
            ),
          ],
        ),
      );
    }

    // Provider items — only configured providers.
    final providerItems = _availableProviderIds
        .map(
          (id) => DropdownMenuItem<String>(
            value: id,
            child: Text(AiModelCatalog.providerDisplayNames[id] ?? id),
          ),
        )
        .toList();

    // Model items — filtered to the selected provider.
    final modelItems =
        (_selectedProviderId != null
                ? AiModelCatalog.forProvider(_selectedProviderId!)
                : <AiModelEntry>[])
            .map(
              (entry) => DropdownMenuItem<String>(
                value: entry.modelId,
                child: Text(entry.displayName),
              ),
            )
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.linear,
            firstCurve: Curves.linear,
            secondCurve: Curves.linear,
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: buildHeader(false),
            secondChild: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildHeader(true),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 12,
                    bottom: 14,
                    left: 14,
                    right: 14,
                  ),
                  decoration: BoxDecoration(
                    color: contentBg,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                    border: Border(
                      left: BorderSide(color: borderColor),
                      right: BorderSide(color: borderColor),
                      bottom: BorderSide(color: borderColor),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Provider selector
                      buildDropdown<String>(
                        label: localizations.aiServiceLabel,
                        value: _selectedProviderId,
                        items: providerItems,
                        onChanged: _onProviderSelected,
                        loadingText: localizations.aiServicesLoading,
                        emptyText: localizations.aiServicesNotConfigured,
                        selectedLabelOf: (id) =>
                            AiModelCatalog.providerDisplayNames[id] ?? id,
                      ),
                      if (!_isLoading &&
                          _selectedProviderId != null &&
                          _availableProviderIds.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        // Model selector
                        buildDropdown<String>(
                          label: localizations.aiModelLabel,
                          value: _selectedModelId,
                          items: modelItems,
                          onChanged: _onModelSelected,
                          selectedLabelOf: (modelId) =>
                              AiModelCatalog.forModelId(modelId)?.displayName ??
                              modelId,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
