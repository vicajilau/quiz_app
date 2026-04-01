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

import 'package:dio/dio.dart';
import 'package:quizdy/data/repositories/ai/gemini_repository.dart';
import 'package:quizdy/data/repositories/ai/openai_repository.dart';
import 'package:quizdy/data/services/configuration_service.dart';
import 'package:quizdy/domain/models/ai/ai_model_catalog.dart';
import 'package:quizdy/domain/repositories/ai_repository.dart';

/// Creates the correct [AiRepository] implementation based on a model ID.
///
/// The factory consults [AiModelCatalog] to resolve the provider, then
/// instantiates the matching repository with the supplied [modelId].
class AiRepositoryFactory {
  final Dio _dioClient;
  final ConfigurationService _configurationService;

  AiRepositoryFactory({
    required Dio dioClient,
    required ConfigurationService configurationService,
  })  : _dioClient = dioClient,
        _configurationService = configurationService;

  /// Returns a repository configured for [modelId].
  ///
  /// Throws [ArgumentError] if [modelId] is not listed in [AiModelCatalog].
  AiRepository createForModel(String modelId) {
    final entry = AiModelCatalog.forModelId(modelId);
    if (entry == null) {
      throw ArgumentError.value(
        modelId,
        'modelId',
        'Unknown model ID — not listed in AiModelCatalog.',
      );
    }

    return switch (entry.providerId) {
      AiModelCatalog.openaiProviderId => OpenAiRepository(
        dioClient: _dioClient,
        configurationService: _configurationService,
        modelId: modelId,
      ),
      AiModelCatalog.geminiProviderId => GeminiRepository(
        dioClient: _dioClient,
        configurationService: _configurationService,
        modelId: modelId,
      ),
      _ => throw ArgumentError.value(
        entry.providerId,
        'providerId',
        'Unhandled provider ID in AiRepositoryFactory.',
      ),
    };
  }

  /// Returns a repository for the user's saved default model.
  ///
  /// Falls back to [AiModelCatalog.defaultModelId] when no preference is saved.
  Future<AiRepository> createDefault() async {
    final savedModel = await _configurationService.getDefaultAIModel();
    final modelId = (savedModel != null &&
            AiModelCatalog.forModelId(savedModel) != null)
        ? savedModel
        : AiModelCatalog.defaultModelId;
    return createForModel(modelId);
  }
}
