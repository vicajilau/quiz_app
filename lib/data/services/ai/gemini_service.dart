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
import 'package:quizdy/data/interceptors/ai_logging_interceptor.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/data/services/configuration_service.dart';
import 'package:quizdy/data/services/ai/ai_service.dart';

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
    'gemini-3-pro-preview',
    'gemini-3-flash-preview',
    'gemini-2.5-pro',
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
  ];

  static GeminiService? _instance;
  static GeminiService get instance => _instance ??= GeminiService._();

  late final Dio _dio;

  GeminiService._() {
    _dio = Dio();
    _dio.interceptors.add(AiLoggingInterceptor());
  }

  @override
  String get serviceName => 'Google Gemini';

  @override
  String get defaultModel => _defaultModel;

  @override
  List<String> get availableModels => _models;

  @override
  Future<bool> isAvailable() async {
    final apiKey = await ConfigurationService.instance.getGeminiApiKey();
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
    final apiKey = await ConfigurationService.instance.getGeminiApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(localizations.geminiApiKeyNotConfigured);
    }

    final selectedModel = model ?? _defaultModel;

    final baseUrl = selectedModel == 'gemini-3-pro-preview'
        ? _baseUrlAlpha
        : _baseUrlBeta;
    final url = '$baseUrl/models/$selectedModel:generateContent?key=$apiKey';

    try {
      final response = await _dio.post(
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
          'generationConfig': {
            'temperature': 0.2,
            'topK': 5,
            'topP': 0.95,
            'maxOutputTokens': 8192,
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
      if (e.response?.statusCode == 302) {
        final location = e.response?.headers['location']?.first;
        throw Exception('Redirected (302) to: $location');
      } else if (e.response?.statusCode == 400) {
        throw Exception(localizations.aiErrorResponse);
      } else if (e.response?.statusCode == 403) {
        throw Exception(localizations.invalidApiKeyError);
      } else if (e.response?.statusCode == 429) {
        throw Exception(localizations.rateLimitError);
      } else {
        throw Exception(localizations.networkErrorGemini);
      }
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
    final apiKey = await ConfigurationService.instance.getGeminiApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(localizations.geminiApiKeyNotConfigured);
    }

    final selectedModel = model ?? _defaultModel;

    final baseUrl = selectedModel == 'gemini-3-pro-preview'
        ? _baseUrlAlpha
        : _baseUrlBeta;
    final url = '$baseUrl/models/$selectedModel:generateContent?key=$apiKey';

    final base64Data = base64Encode(file.bytes);

    try {
      final response = await _dio.post(
        url,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt},
                {
                  'inline_data': {
                    'mime_type': file.mimeType,
                    'data': base64Data,
                  },
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.2,
            'topK': 5,
            'topP': 0.95,
            'maxOutputTokens': 8192,
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
      if (e.response?.statusCode == 302) {
        final location = e.response?.headers['location']?.first;
        throw Exception('Redirected (302) to: $location');
      } else if (e.response?.statusCode == 400) {
        String errorMessage = localizations.aiErrorResponse;
        try {
          final data = e.response?.data;
          if (data != null &&
              data['error'] != null &&
              data['error']['message'] != null) {
            errorMessage += ': ${data['error']['message']}';
          }
        } catch (_) {}
        throw Exception(errorMessage);
      } else if (e.response?.statusCode == 403) {
        throw Exception(localizations.invalidApiKeyError);
      } else if (e.response?.statusCode == 429) {
        throw Exception(localizations.rateLimitError);
      } else {
        String errorMessage = localizations.aiErrorResponse;
        try {
          final data = e.response?.data;
          if (data != null &&
              data['error'] != null &&
              data['error']['message'] != null) {
            errorMessage += ': ${data['error']['message']}';
          } else {
            errorMessage += ' (${e.response?.statusCode})';
          }
        } catch (_) {
          errorMessage += ' (${e.response?.statusCode})';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception(localizations.networkErrorGemini);
    }
  }

  @override
  Future<String> uploadFile(
    AiFileAttachment file,
    AppLocalizations localizations,
  ) async {
    final apiKey = await ConfigurationService.instance.getGeminiApiKey();

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

      final response = await _dio.post(
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

      if (fileUri != null) {
        return fileUri;
      } else {
        throw Exception(localizations.noResponseReceived);
      }
    } on DioException catch (e) {
      String errorMessage = localizations.aiErrorResponse;
      try {
        final data = e.response?.data;
        if (data != null &&
            data['error'] != null &&
            data['error']['message'] != null) {
          errorMessage += ': ${data['error']['message']}';
        } else {
          errorMessage += ': ${e.message}';
        }
      } catch (_) {
        errorMessage += ': ${e.message}';
      }
      throw Exception(errorMessage);
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
    final apiKey = await ConfigurationService.instance.getGeminiApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(localizations.geminiApiKeyNotConfigured);
    }

    final selectedModel = model ?? _defaultModel;

    final baseUrl = selectedModel == 'gemini-3-pro-preview'
        ? _baseUrlAlpha
        : _baseUrlBeta;
    final url = '$baseUrl/models/$selectedModel:generateContent?key=$apiKey';

    try {
      final response = await _dio.post(
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
            'maxOutputTokens': 8192,
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
      String errorMessage = localizations.aiErrorResponse;
      try {
        final data = e.response?.data;
        if (data != null &&
            data['error'] != null &&
            data['error']['message'] != null) {
          errorMessage += ': ${data['error']['message']}';
        } else {
          errorMessage += ': ${e.message}';
        }
      } catch (_) {
        errorMessage += ': ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception(localizations.networkErrorGemini);
    }
  }

  @override
  Future<String> generateStudyIndex(
    AppLocalizations localizations, {
    required String fileUri,
    required String fileMimeType,
  }) async {
    final prompt =
        '''
Act as an expert academic educator. Analyze the provided document and generate a structured Table of Contents (index) for a personalized study plan.

Rules:
1. Divide the content into logical "Themes" or "Chapters" (chunks).
2. Each theme should be granular enough to be studied in a single session.
3. If a section is very long, break it down into sub-themes.
4. For each theme, identify the start and end page (if the document has pages/is a PDF). If not, use estimated percentages or indices.
5. High Priority: Chunks should feel like an index of a book.
6. Themes should be logically treated as the main units of study.
7. Output ONLY a valid JSON array of objects with this structure:
[
  {
    "title": "Theme Title",
    "startPage": 1, 
    "endPage": 3,
    "summary": "Brief 1-sentence description of what will be covered."
  }
]

Current Language: ${localizations.localeName}
''';

    return getChatResponseWithFileUri(
      prompt,
      localizations,
      responseMimeType: 'application/json',
      fileUri: fileUri,
      fileMimeType: fileMimeType,
    );
  }
}
