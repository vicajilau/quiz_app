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
import 'package:genkit/genkit.dart';
import 'package:genkit_google_genai/genkit_google_genai.dart';
import 'package:genkit_openai/genkit_openai.dart';
import 'package:http/http.dart' as http;
import 'package:quizdy/core/debug_print.dart';

/// A single entry in the AI model catalog.
class AiModelEntry {
  /// Unique model identifier used in API calls, e.g. `'gpt-4o-mini'`.
  final String modelId;

  /// Provider this model belongs to, e.g. `'openai'` or `'gemini'`.
  final String providerId;

  /// Human-readable name shown in the UI.
  final String displayName;

  const AiModelEntry({
    required this.modelId,
    required this.providerId,
    required this.displayName,
  });
}

/// Static catalog of all known AI models and their provider assignments.
///
/// This is the single source of truth used by [AiRepositoryFactory] to
/// instantiate the correct repository and by [AiServiceModelSelector] to
/// display the full predefined list of models in the configuration UI,
/// regardless of which API keys are currently configured.
abstract final class AiModelCatalog {
  static const String geminiProviderId = 'gemini';
  static const String openaiProviderId = 'openai';
  static const String customProviderId = 'custom';

  /// Indicates if connection to the custom AI server endpoint failed.
  static bool customAiConnectionFailed = false;

  /// Display name shown in the UI for each provider.
  static const Map<String, String> providerDisplayNames = {
    geminiProviderId: 'Google Gemini',
    openaiProviderId: 'OpenAI GPT',
    customProviderId: 'Custom / Local',
  };

  /// Ordered list of provider IDs (determines dropdown order).
  static const List<String> providerIds = [
    geminiProviderId,
    openaiProviderId,
    customProviderId,
  ];

  static const String defaultModelId = 'gemini-flash-latest';

  /// Static list of models, initialized with defaults.
  static List<AiModelEntry> models = List.from(_defaultModels);

  static const List<AiModelEntry> _defaultModels = [
    // ── Google Gemini ─────────────────────────────────────────────────────
    AiModelEntry(
      modelId: 'gemini-flash-latest',
      providerId: geminiProviderId,
      displayName: 'Gemini Flash (latest)',
    ),
    AiModelEntry(
      modelId: 'gemini-2.5-flash',
      providerId: geminiProviderId,
      displayName: 'Gemini 2.5 Flash',
    ),
    AiModelEntry(
      modelId: 'gemini-2.5-flash-lite',
      providerId: geminiProviderId,
      displayName: 'Gemini 2.5 Flash Lite',
    ),
    AiModelEntry(
      modelId: 'gemini-2.5-pro',
      providerId: geminiProviderId,
      displayName: 'Gemini 2.5 Pro',
    ),
    AiModelEntry(
      modelId: 'gemini-3-flash-preview',
      providerId: geminiProviderId,
      displayName: 'Gemini 3 Flash (preview)',
    ),
    AiModelEntry(
      modelId: 'gemini-3.1-pro-preview',
      providerId: geminiProviderId,
      displayName: 'Gemini 3.1 Pro (preview)',
    ),
    // ── OpenAI ────────────────────────────────────────────────────────────
    AiModelEntry(
      modelId: 'gpt-4o-mini',
      providerId: openaiProviderId,
      displayName: 'GPT-4o Mini',
    ),
    AiModelEntry(
      modelId: 'gpt-4o',
      providerId: openaiProviderId,
      displayName: 'GPT-4o',
    ),
    AiModelEntry(
      modelId: 'gpt-4-turbo',
      providerId: openaiProviderId,
      displayName: 'GPT-4 Turbo',
    ),
    AiModelEntry(
      modelId: 'gpt-4',
      providerId: openaiProviderId,
      displayName: 'GPT-4',
    ),
    AiModelEntry(
      modelId: 'gpt-3.5-turbo',
      providerId: openaiProviderId,
      displayName: 'GPT-3.5 Turbo',
    ),
  ];

  /// Returns the catalog entry for [modelId], or a dynamic heuristic entry if not found.
  static AiModelEntry? forModelId(String modelId) {
    for (final entry in models) {
      if (entry.modelId == modelId) return entry;
    }
    // Heuristic fallback to resolve any custom / un-hardcoded model ID
    final detectedProvider = _detectProvider(modelId);
    return AiModelEntry(
      modelId: modelId,
      providerId: detectedProvider,
      displayName: _formatDisplayName(modelId),
    );
  }

  /// Returns all catalog entries that belong to [providerId].
  static List<AiModelEntry> forProvider(String providerId) =>
      models.where((e) => e.providerId == providerId).toList();

  /// All models whose provider matches [providerId], in catalog order.
  static List<String> modelIdsForProvider(String providerId) =>
      forProvider(providerId).map((e) => e.modelId).toList();

  /// Dynamically updates the catalog with fetched models.
  static void updateCatalog(List<AiModelEntry> fetchedModels) {
    final existingIds = models.map((e) => e.modelId).toSet();
    final updated = List<AiModelEntry>.from(models);
    for (final entry in fetchedModels) {
      if (!existingIds.contains(entry.modelId)) {
        updated.add(entry);
        existingIds.add(entry.modelId);
      }
    }
    models = updated;
  }

  /// Registers custom models directly into the catalog.
  static void registerCustomModels(List<String> modelIds) {
    final fetched = modelIds
        .map(
          (id) => AiModelEntry(
            modelId: id,
            providerId: customProviderId,
            displayName: _formatDisplayName(id),
          ),
        )
        .toList();
    updateCatalog(fetched);
  }

  static Future<bool> _isUrlReachable(String url) async {
    if (kIsWeb) return true; // Skip check on Web due to CORS constraints
    try {
      final uri = Uri.parse(url);
      if (uri.host.isEmpty) return false;
      await http.get(uri).timeout(const Duration(milliseconds: 500));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Dynamically queries the Genkit registry using the supplied API keys
  /// and updates the catalog list with any newly discovered models.
  static Future<void> loadDynamicModels({
    String? geminiApiKey,
    String? openaiApiKey,
    String? customBaseUrl,
    String? customApiKey,
    List<String>? customModels,
  }) async {
    final isCustomReachable =
        customBaseUrl != null &&
        customBaseUrl.isNotEmpty &&
        await _isUrlReachable(customBaseUrl);

    if (customBaseUrl != null && customBaseUrl.isNotEmpty) {
      customAiConnectionFailed = !isCustomReachable;
    } else {
      customAiConnectionFailed = false;
    }

    final plugins = [
      if (geminiApiKey != null && geminiApiKey.isNotEmpty)
        googleAI(apiKey: geminiApiKey),
      if (openaiApiKey != null && openaiApiKey.isNotEmpty)
        openAI(apiKey: openaiApiKey),
      if (isCustomReachable)
        openAI(
          name: 'custom',
          apiKey: (customApiKey != null && customApiKey.isNotEmpty)
              ? customApiKey
              : 'dummy-key',
          baseUrl: customBaseUrl,
          models:
              customModels
                  ?.map((m) => CustomModelDefinition(name: m))
                  .toList() ??
              [],
        ),
    ];

    if (plugins.isEmpty) return;

    final ai = Genkit(plugins: plugins);
    try {
      final actions = await ai.registry.listActions();
      final modelActions = actions.where((a) => a.actionType == 'model');

      final List<AiModelEntry> fetchedModels = [];
      for (final action in modelActions) {
        if (action.name.startsWith('googleai/')) {
          final modelId = action.name.replaceFirst('googleai/', '');
          fetchedModels.add(
            AiModelEntry(
              modelId: modelId,
              providerId: geminiProviderId,
              displayName: _formatDisplayName(modelId),
            ),
          );
        } else if (action.name.startsWith('openai/')) {
          final modelId = action.name.replaceFirst('openai/', '');
          fetchedModels.add(
            AiModelEntry(
              modelId: modelId,
              providerId: openaiProviderId,
              displayName: _formatDisplayName(modelId),
            ),
          );
        } else if (action.name.startsWith('custom/')) {
          final modelId = action.name.replaceFirst('custom/', '');
          fetchedModels.add(
            AiModelEntry(
              modelId: modelId,
              providerId: customProviderId,
              displayName: _formatDisplayName(modelId),
            ),
          );
        }
      }

      if (fetchedModels.isNotEmpty) {
        updateCatalog(fetchedModels);
      }
    } catch (e) {
      // Fail silently and keep current/fallback defaults
      printInDebug('[AiModelCatalog] Failed to load dynamic models: $e');
    }
  }

  static String _detectProvider(String modelId) {
    final lower = modelId.toLowerCase();
    if (lower.startsWith('openai/') ||
        lower.contains('gpt-') ||
        lower.startsWith('o1') ||
        lower.startsWith('o3')) {
      return openaiProviderId;
    }
    return geminiProviderId;
  }

  static String _formatDisplayName(String modelId) {
    final parts = modelId.split('-');
    return parts
        .map((part) {
          if (part.isEmpty) return '';
          if (part.toLowerCase() == 'gpt') return 'GPT';
          if (part.toLowerCase() == 'o1' || part.toLowerCase() == 'o3') {
            return part;
          }
          return part[0].toUpperCase() + part.substring(1);
        })
        .join(' ');
  }
}
