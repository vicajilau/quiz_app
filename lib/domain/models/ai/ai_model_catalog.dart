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
  static const String llamaProviderId = 'llama';

  /// Display name shown in the UI for each provider.
  static const Map<String, String> providerDisplayNames = {
    geminiProviderId: 'Google Gemini',
    openaiProviderId: 'OpenAI GPT',
    llamaProviderId: 'Local (llama.cpp)',
  };

  /// Ordered list of provider IDs (determines dropdown order).
  static const List<String> providerIds = [
    geminiProviderId,
    openaiProviderId,
    llamaProviderId,
  ];

  static const String defaultModelId = 'gemini-flash-latest';

  static const List<AiModelEntry> models = [
    // ── Local llama.cpp ───────────────────────────────────────────────────
    AiModelEntry(
      modelId: 'llama-local',
      providerId: llamaProviderId,
      displayName: 'Local model (llama.cpp)',
    ),
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

  /// Returns the catalog entry for [modelId], or `null` if not found.
  static AiModelEntry? forModelId(String modelId) {
    for (final entry in models) {
      if (entry.modelId == modelId) return entry;
    }
    return null;
  }

  /// Returns all catalog entries that belong to [providerId].
  static List<AiModelEntry> forProvider(String providerId) =>
      models.where((e) => e.providerId == providerId).toList();

  /// All models whose provider matches [providerId], in catalog order.
  static List<String> modelIdsForProvider(String providerId) =>
      forProvider(providerId).map((e) => e.modelId).toList();
}
