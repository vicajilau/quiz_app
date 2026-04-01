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
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/domain/models/ai/ai_file_upload_result.dart';
import 'package:quizdy/data/services/configuration_service.dart';
import 'package:quizdy/data/services/ai/ai_service.dart';
import 'package:quizdy/domain/models/ai/ai_study_generation_config.dart';
import 'package:quizdy/domain/models/quiz/study_component.dart';
import 'package:quizdy/domain/models/custom_exceptions/connectivity_exception.dart';
import 'package:quizdy/domain/use_cases/build_study_page_components_prompt_use_case.dart';

class GeminiService extends AIService {
  static const String _baseUrlBeta =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String _uploadBaseUrlBeta =
      'https://generativelanguage.googleapis.com/upload/v1beta';
  static const String _baseUrlAlpha =
      'https://generativelanguage.googleapis.com/v1alpha';
  static const String _defaultModel = 'gemini-flash-latest';

  static const List<String> _models = [
    'gemini-flash-latest',
    'gemini-3.1-pro-preview',
    'gemini-3-flash-preview',
    'gemini-2.5-pro',
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
  ];

  GeminiService({required this.dioClient, required this.configurationService});

  final Dio dioClient;
  final ConfigurationService configurationService;

  @override
  String get serviceName => 'Google Gemini';

  @override
  String get defaultModel => _defaultModel;

  @override
  List<String> get availableModels => _models;

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
    if (e.error is ConnectivityException) {
      final ce = e.error as ConnectivityException;
      return Exception(
        ce.type == ConnectivityExceptionType.connectionAborted
            ? localizations.aiErrorConnectionAborted
            : localizations.noInternetConnection,
      );
    }

    if (e.response?.statusCode == 302) {
      final location = e.response?.headers['location']?.first;
      return Exception(localizations.aiErrorRedirect(location ?? ''));
    } else if (e.response?.statusCode == 400) {
      return Exception(_extractErrorDetail(e, localizations));
    } else if (e.response?.statusCode == 403) {
      return Exception(localizations.invalidApiKeyError);
    } else if (e.response?.statusCode == 429) {
      return Exception(localizations.rateLimitError);
    } else {
      return Exception(_extractErrorDetail(e, localizations));
    }
  }

  @override
  Future<bool> isAvailable() async {
    final apiKey = await configurationService.getGeminiApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  /// Realiza una petición a la API de Gemini
  @override
  Future<String> getChatResponse(
    String prompt,
    AppLocalizations localizations, {
    String? model,
    String? responseMimeType,
  }) async {
    final apiKey = await configurationService.getGeminiApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(localizations.geminiApiKeyNotConfigured);
    }

    final selectedModel = model ?? _defaultModel;

    final baseUrl = selectedModel == 'gemini-3.1-pro-preview'
        ? _baseUrlAlpha
        : _baseUrlBeta;
    final url = '$baseUrl/models/$selectedModel:generateContent?key=$apiKey';

    try {
      final response = await dioClient.post(
        url,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'temperature': 0.2, 'topK': 5, 'topP': 0.95},
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
          ],
        },
      );

      final jsonResponse = response.data;
      final candidates = jsonResponse['candidates'] as List?;

      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content']['parts'][0]['text'];
        return content?.toString().trim() ?? localizations.noResponseReceived;
      } else {
        return localizations.noResponseReceived;
      }
    } on DioException catch (e) {
      throw _buildDioException(e, localizations);
    } catch (e) {
      throw Exception(localizations.networkErrorGemini);
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
    final uploadResult = await uploadFile(file, localizations);

    return getChatResponseWithFileUri(
      prompt,
      localizations,
      model: model,
      responseMimeType: responseMimeType,
      fileUri: uploadResult.fileUri,
      fileMimeType: file.mimeType,
    );
  }

  @override
  Future<AiFileUploadResult> uploadFile(
    AiFileAttachment file,
    AppLocalizations localizations,
  ) async {
    final apiKey = await configurationService.getGeminiApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(localizations.geminiApiKeyNotConfigured);
    }

    final url = '$_uploadBaseUrlBeta/files?key=$apiKey';

    try {
      final boundary =
          '--------------------------${DateTime.now().millisecondsSinceEpoch}';

      final List<int> metadata = utf8.encode(
        '--$boundary\r\n'
        'Content-Type: application/json; charset=UTF-8\r\n\r\n'
        '{"file": {"displayName": "${file.name}"}}\r\n'
        '--$boundary\r\n'
        'Content-Type: ${file.mimeType}\r\n\r\n',
      );

      final List<int> footer = utf8.encode('\r\n--$boundary--\r\n');

      final body = Uint8List.fromList([...metadata, ...file.bytes, ...footer]);

      final response = await dioClient.post(
        url,
        options: Options(
          headers: {
            'X-Goog-Upload-Protocol': 'multipart',
            'Content-Type': 'multipart/related; boundary=$boundary',
            'Content-Length': '${body.length}',
          },
        ),
        data: body,
      );

      final jsonResponse = response.data;
      final fileUri = jsonResponse['file']?['uri'] as String?;
      final expirationTimeStr =
          jsonResponse['file']?['expirationTime'] as String?;

      if (fileUri != null && expirationTimeStr != null) {
        return AiFileUploadResult(
          fileUri: fileUri,
          expirationTime: DateTime.parse(expirationTimeStr),
        );
      } else {
        throw Exception(localizations.noResponseReceived);
      }
    } on DioException catch (e) {
      throw _buildDioException(e, localizations);
    } catch (e) {
      throw Exception(localizations.networkErrorGemini);
    }
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
    final apiKey = await configurationService.getGeminiApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(localizations.geminiApiKeyNotConfigured);
    }

    final selectedModel = model ?? _defaultModel;

    final baseUrl = selectedModel == 'gemini-3.1-pro-preview'
        ? _baseUrlAlpha
        : _baseUrlBeta;
    final url = '$baseUrl/models/$selectedModel:generateContent?key=$apiKey';

    try {
      final response = await dioClient.post(
        url,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt},
                {
                  'file_data': {'mime_type': fileMimeType, 'file_uri': fileUri},
                },
              ],
            },
          ],
          'generationConfig': {
            'responseMimeType': ?responseMimeType,
            'temperature': 0.2,
            'topK': 5,
            'topP': 0.95,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
          ],
        },
      );

      final jsonResponse = response.data;
      final candidates = jsonResponse['candidates'] as List?;

      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content']['parts'][0]['text'];
        return content?.toString().trim() ?? localizations.noResponseReceived;
      } else {
        return localizations.noResponseReceived;
      }
    } on DioException catch (e) {
      throw _buildDioException(e, localizations);
    } catch (e) {
      throw Exception(localizations.networkErrorGemini);
    }
  }

  /// Generates a list of [StudyComponent]s from an [AiStudyGenerationConfig].
  ///
  /// The prompt is assembled by [BuildStudyPageComponentsPromptUseCase] so that
  /// this service only handles HTTP execution and JSON parsing.
  Future<List<StudyComponent>> generatePageComponents(
    AppLocalizations localizations,
    AiStudyGenerationConfig config,
  ) async {
    final prompt = BuildStudyPageComponentsPromptUseCase.build(
      config,
      localizations,
    );

    final String responseBody;
    if (config.hasFile) {
      responseBody = await getChatResponseWithFile(
        prompt,
        localizations,
        model: config.preferredModel,
        responseMimeType: 'application/json',
        file: config.file!,
      );
    } else {
      responseBody = await getChatResponse(
        prompt,
        localizations,
        model: config.preferredModel,
        responseMimeType: 'application/json',
      );
    }

    final cleanJson = _extractJsonArrayFromResponse(responseBody);
    final decoded = jsonDecode(cleanJson);
    if (decoded is! List) {
      throw FormatException(
        'Expected a JSON array of components. Got: $cleanJson',
      );
    }
    return decoded
        .map((e) => StudyComponent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Extracts a JSON array string from the LLM response, stripping markdown if present.
  String _extractJsonArrayFromResponse(String response) {
    final regExp = RegExp(r'```json\s*([\s\S]*?)\s*```', multiLine: true);
    final match = regExp.firstMatch(response);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!.trim();
    }
    final firstBracket = response.indexOf('[');
    final lastBracket = response.lastIndexOf(']');
    if (firstBracket != -1 && lastBracket != -1 && lastBracket > firstBracket) {
      return response.substring(firstBracket, lastBracket + 1).trim();
    }
    return response.trim();
  }
}
