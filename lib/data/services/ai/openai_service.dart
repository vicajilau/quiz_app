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
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/domain/models/ai/openai_content_block.dart';
import 'package:quizdy/data/services/configuration_service.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/data/services/ai/ai_service.dart';
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';

class OpenAIService extends AIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _chatEndpoint = '/chat/completions';
  static const String _defaultModel = 'gpt-4o-mini';

  static const List<String> _models = [
    'gpt-4o-mini',
    'gpt-4o',
    'gpt-4-turbo',
    'gpt-4',
    'gpt-3.5-turbo',
  ];

  OpenAIService({required this.dioClient, required this.configurationService});

  final Dio dioClient;
  final ConfigurationService configurationService;

  @override
  String get serviceName => 'OpenAI GPT';

  @override
  String get defaultModel => _defaultModel;

  @override
  List<String> get availableModels => _models;

  @override
  Future<bool> isAvailable() async {
    final apiKey = await configurationService.getOpenAIApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  String _extractErrorDetail(DioException e, AppLocalizations localizations) {
    final data = e.response?.data;
    if (data != null &&
        data['error'] != null &&
        data['error']['message'] != null) {
      return '${localizations.aiErrorResponse} ${data['error']['message']}';
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == null) {
      return localizations.aiErrorResponse;
    }
    return '${localizations.aiErrorResponse} ($statusCode)';
  }

  Exception _buildDioException(DioException e, AppLocalizations localizations) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      final errorStr = e.error.toString();
      if (errorStr.contains('Software caused connection abort') ||
          errorStr.contains('Connection closed')) {
        return Exception(localizations.aiErrorConnectionAborted);
      }
    }

    if (e.response?.statusCode == 401) {
      return Exception(localizations.invalidApiKeyError);
    } else if (e.response?.statusCode == 429) {
      return Exception(localizations.rateLimitError);
    } else if (e.response?.statusCode == 404) {
      return Exception(localizations.modelNotFoundError);
    } else {
      return Exception(_extractErrorDetail(e, localizations));
    }
  }

  /// Realiza una petición a la API de ChatGPT
  @override
  Future<String> getChatResponse(
    String prompt,
    AppLocalizations localizations, {
    String? model,
    String? responseMimeType,
  }) async {
    final apiKey = await configurationService.getOpenAIApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(localizations.openaiApiKeyNotConfigured);
    }

    final selectedModel = model ?? _defaultModel;

    try {
      final response = await dioClient.post(
        '$_baseUrl$_chatEndpoint',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
        ),
        data: {
          'model': selectedModel,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 8192,
          'temperature': 0.2,
        },
      );

      final jsonResponse = response.data;
      final content = jsonResponse['choices'][0]['message']['content'];
      return content?.toString().trim() ?? localizations.noResponseReceived;
    } on DioException catch (e) {
      throw _buildDioException(e, localizations);
    } catch (e) {
      throw Exception(localizations.networkErrorOpenAI);
    }
  }

  @override
  Future<String> getChatResponseWithFile(
    String prompt,
    AppLocalizations localizations, {
    String? model,
    String? responseMimeType,
    required AiFileAttachment file,
  }) async {
    final apiKey = await configurationService.getOpenAIApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(localizations.openaiApiKeyNotConfigured);
    }

    final selectedModel = model ?? _defaultModel;
    final contentBlocks = OpenAIContentBlock.fromPromptAndFile(prompt, file);

    try {
      final response = await dioClient.post(
        '$_baseUrl$_chatEndpoint',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
        ),
        data: {
          'model': selectedModel,
          'messages': [
            {
              'role': 'user',
              'content': contentBlocks.map((b) => b.toJson()).toList(),
            },
          ],
          'max_tokens': 8192,
          'temperature': 0.2,
        },
      );

      final jsonResponse = response.data;
      final content = jsonResponse['choices'][0]['message']['content'];
      return content?.toString().trim() ?? localizations.noResponseReceived;
    } on DioException catch (e) {
      throw _buildDioException(e, localizations);
    } catch (e) {
      throw Exception(localizations.networkErrorOpenAI);
    }
  }

  @override
  Future<FileUploadResult> uploadFile(
    AiFileAttachment file,
    AppLocalizations localizations,
  ) async {
    throw UnimplementedError('OpenAI File API not implemented yet');
  }

  @override
  Future<String> getChatResponseWithFileUri(
    String prompt,
    AppLocalizations localizations, {
    String? model,
    String? responseMimeType,
    required String fileUri,
    required String fileMimeType,
  }) async {
    throw UnimplementedError('OpenAI File API not implemented yet');
  }

  @override
  Future<String> generateStudyIndex(
    AppLocalizations localizations, {
    required String fileUri,
    required String fileMimeType,
    String? extraContext,
    required String language,
  }) async {
    throw UnimplementedError('OpenAI File API not implemented yet');
  }

  @override
  Future<String> generateStudyIndexFromText(
    AppLocalizations localizations, {
    required String content,
    required AiGenerationMode generationMode,
    required String language,
  }) async {
    throw UnimplementedError(
      'OpenAI Study Index from Text not implemented yet',
    );
  }
}
