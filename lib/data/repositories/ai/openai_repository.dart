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

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:genkit/genkit.dart';
import 'package:genkit_openai/genkit_openai.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/data/services/configuration_service.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/domain/models/ai/ai_file_upload_result.dart';
import 'package:quizdy/domain/models/ai/ai_model_catalog.dart';
import 'package:quizdy/domain/repositories/ai_repository.dart';

/// OpenAI implementation of [AiRepository].
///
/// Handles the OpenAI wire format, authentication, rate-limit errors, and
/// file uploads.  Contains no prompt text — all payloads arrive pre-assembled.
class OpenAiRepository implements AiRepository {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _chatEndpoint = '/chat/completions';
  static const String _filesEndpoint = '/files';

  final Dio _dioClient;
  final ConfigurationService _configurationService;
  final bool isCustom;

  @override
  final String modelId;

  OpenAiRepository({
    required this._dioClient,
    required this._configurationService,
    required this.modelId,
    this.isCustom = false,
  });

  @override
  String get providerId => isCustom
      ? AiModelCatalog.customProviderId
      : AiModelCatalog.openaiProviderId;

  @override
  Future<bool> isAvailable() async {
    if (isCustom) {
      final customBaseUrl = await _configurationService.getCustomAiBaseUrl();
      return customBaseUrl != null && customBaseUrl.isNotEmpty;
    }
    final key = await _configurationService.getOpenAIApiKey();
    return key != null && key.isNotEmpty;
  }

  // ── Error helpers ────────────────────────────────────────────────────────

  String _extractErrorDetail(DioException e, AppLocalizations localizations) {
    final data = e.response?.data;
    if (data != null &&
        data['error'] != null &&
        data['error']['message'] != null) {
      return '${localizations.aiErrorResponse} ${data['error']['message']}';
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == null) return localizations.aiErrorResponse;
    return '${localizations.aiErrorResponse} ($statusCode)';
  }

  Exception _buildException(DioException e, AppLocalizations localizations) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      final err = e.error.toString();
      if (err.contains('Software caused connection abort') ||
          err.contains('Connection closed')) {
        return Exception(localizations.aiErrorConnectionAborted);
      }
    }
    return switch (e.response?.statusCode) {
      401 => Exception(localizations.invalidApiKeyError),
      429 => Exception(localizations.rateLimitError),
      404 => Exception(localizations.modelNotFoundError),
      _ => Exception(_extractErrorDetail(e, localizations)),
    };
  }

  Future<Genkit> _initGenkit(AppLocalizations localizations) async {
    if (isCustom) {
      final customBaseUrl = await _configurationService.getCustomAiBaseUrl();
      if (customBaseUrl == null || customBaseUrl.isEmpty) {
        throw Exception('Custom Base URL not configured');
      }
      final customApiKey = await _configurationService.getCustomAiApiKey();
      final apiKeyToUse = (customApiKey != null && customApiKey.isNotEmpty)
          ? customApiKey
          : 'dummy-key';
      return Genkit(
        plugins: [
          openAI(
            name: 'custom',
            apiKey: apiKeyToUse,
            baseUrl: customBaseUrl,
            models: [CustomModelDefinition(name: modelId)],
          ),
        ],
      );
    } else {
      final apiKey = await _configurationService.getOpenAIApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception(localizations.openaiApiKeyNotConfigured);
      }
      return Genkit(plugins: [openAI(apiKey: apiKey)]);
    }
  }

  // ── AiRepository interface ───────────────────────────────────────────────

  @override
  Future<String> sendMessages(
    String prompt,
    AppLocalizations localizations, {
    String? responseMimeType,
  }) async {
    final ai = await _initGenkit(localizations);
    final modelRef = openAI.model(
      modelId,
      namespace: isCustom ? 'custom' : 'openai',
    );

    try {
      final response = await ai.generate(
        model: modelRef,
        prompt: prompt,
        config: OpenAIChatOptions(
          temperature: 0.2,
          jsonMode: responseMimeType == 'application/json',
        ),
      );
      return response.text;
    } catch (e) {
      throw Exception('${localizations.networkErrorOpenAI}: $e');
    }
  }

  @override
  Future<String> sendMessagesWithFile(
    String prompt,
    AppLocalizations localizations, {
    required AiFileAttachment file,
    String? responseMimeType,
  }) async {
    final ai = await _initGenkit(localizations);
    final modelRef = openAI.model(
      modelId,
      namespace: isCustom ? 'custom' : 'openai',
    );
    final base64Data = base64Encode(file.bytes);
    final dataUrl = 'data:${file.mimeType};base64,$base64Data';

    try {
      final response = await ai.generate(
        model: modelRef,
        messages: [
          Message(
            role: Role.user,
            content: [
              MediaPart(
                media: Media(contentType: file.mimeType, url: dataUrl),
              ),
              TextPart(text: prompt),
            ],
          ),
        ],
        config: OpenAIChatOptions(
          temperature: 0.2,
          jsonMode: responseMimeType == 'application/json',
        ),
      );
      return response.text;
    } catch (e) {
      throw Exception('${localizations.networkErrorOpenAI}: $e');
    }
  }

  @override
  Future<AiFileUploadResult> uploadFile(
    AiFileAttachment file,
    AppLocalizations localizations,
  ) async {
    final apiKey = isCustom
        ? (await _configurationService.getCustomAiApiKey() ?? 'dummy-key')
        : await _configurationService.getOpenAIApiKey();
    if (!isCustom && (apiKey == null || apiKey.isEmpty)) {
      throw Exception(localizations.openaiApiKeyNotConfigured);
    }
    final baseUrlToUse = isCustom
        ? await _configurationService.getCustomAiBaseUrl()
        : _baseUrl;

    try {
      final formData = FormData.fromMap({
        'purpose': 'assistants',
        'file': MultipartFile.fromBytes(file.bytes, filename: file.name),
      });

      final response = await _dioClient.post(
        '$baseUrlToUse$_filesEndpoint',
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
        data: formData,
      );

      final fileId = response.data['id'] as String?;
      if (fileId == null || fileId.isEmpty) {
        throw Exception(localizations.noResponseReceived);
      }

      return AiFileUploadResult(
        fileUri: fileId,
        expirationTime: DateTime.now().add(const Duration(days: 3650)),
      );
    } on DioException catch (e) {
      throw _buildException(e, localizations);
    } catch (_) {
      throw Exception(localizations.networkErrorOpenAI);
    }
  }

  @override
  Future<String> sendMessagesWithFileUri(
    String prompt,
    AppLocalizations localizations, {
    required String fileUri,
    required String fileMimeType,
    String? responseMimeType,
  }) async {
    final apiKey = isCustom
        ? (await _configurationService.getCustomAiApiKey() ?? 'dummy-key')
        : await _configurationService.getOpenAIApiKey();
    if (!isCustom && (apiKey == null || apiKey.isEmpty)) {
      throw Exception(localizations.openaiApiKeyNotConfigured);
    }
    final baseUrlToUse = isCustom
        ? await _configurationService.getCustomAiBaseUrl()
        : _baseUrl;

    final data = <String, dynamic>{
      'model': modelId,
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': prompt},
            {
              'type': 'file',
              'file': {'file_id': fileUri},
            },
          ],
        },
      ],
      'max_tokens': 8192,
      'temperature': 0.2,
    };
    if (responseMimeType == 'application/json') {
      data['response_format'] = {'type': 'json_object'};
    }

    try {
      final response = await _dioClient.post(
        '$baseUrlToUse$_chatEndpoint',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
        ),
        data: data,
      );
      final content =
          response.data['choices'][0]['message']['content'] as String?;
      return content?.trim() ?? localizations.noResponseReceived;
    } on DioException catch (e) {
      throw _buildException(e, localizations);
    } catch (_) {
      throw Exception(localizations.networkErrorOpenAI);
    }
  }
}
