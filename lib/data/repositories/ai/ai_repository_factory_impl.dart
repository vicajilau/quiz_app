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
import 'package:quizdy/domain/repositories/ai_repository_factory.dart';

/// Concrete implementation of [AiRepositoryFactory] in the data layer.
class AiRepositoryFactoryImpl implements AiRepositoryFactory {
  final Dio _dioClient;
  final ConfigurationService _configurationService;

  AiRepositoryFactoryImpl({
    required this._dioClient,
    required this._configurationService,
  });

  @override
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
      AiModelCatalog.customProviderId => OpenAiRepository(
        dioClient: _dioClient,
        configurationService: _configurationService,
        modelId: modelId,
        isCustom: true,
      ),
      _ => throw ArgumentError.value(
        entry.providerId,
        'providerId',
        'Unhandled provider ID in AiRepositoryFactory.',
      ),
    };
  }

  @override
  Future<AiRepository> createDefault() async {
    final savedModel = _configurationService.getDefaultAIModel();
    final modelId =
        (savedModel != null && AiModelCatalog.forModelId(savedModel) != null)
        ? savedModel
        : AiModelCatalog.defaultModelId;
    return createForModel(modelId);
  }
}
