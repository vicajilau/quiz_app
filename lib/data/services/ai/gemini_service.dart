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
import 'package:quizdy/data/services/configuration_service.dart';
import 'package:quizdy/data/services/ai/ai_service.dart';
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';

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
    'gemini-3.1-flash-preview',
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
    final apiKey = await configurationService.getGeminiApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(localizations.geminiApiKeyNotConfigured);
    }

    final selectedModel = model ?? _defaultModel;

    final baseUrl = selectedModel == 'gemini-3.1-pro-preview'
        ? _baseUrlAlpha
        : _baseUrlBeta;
    final url = '$baseUrl/models/$selectedModel:generateContent?key=$apiKey';

    final base64Data = base64Encode(file.bytes);

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
                  'inline_data': {
                    'mime_type': file.mimeType,
                    'data': base64Data,
                  },
                },
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
    String? extraContext,
    required String language,
  }) async {
    final commentsSection =
        extraContext != null && extraContext.trim().isNotEmpty
        ? '\nADDITIONAL INSTRUCTIONS/CONTEXT FROM THE USER:\n$extraContext\n'
        : '';

    final targetLanguage = language;

    final prompt =
        '''
Act as an expert academic educator. Analyze the provided document $commentsSection and generate a structured study guide with a Table of Contents for a personalized study plan.

IMPORTANT GLOBAL RULE:
ALL fields in the JSON output (title, description, chapter titles, summaries) MUST be written strictly in the following language: $targetLanguage.

Rules:
1. Generate a concise title that summarizes the subject matter of the syllabus. Do NOT reference the document itself (e.g. avoid "Document about...", "This PDF covers..."). Just state the topic directly.
2. Generate a brief description (2-3 sentences) explaining the syllabus content and its key learning objectives. Write it as if describing the subject, not the document.
3. Divide the content into logical "Themes" or "Chapters" (chunks).
4. Each theme should be granular enough to be studied in a single session.
5. If a section is very long, break it down into sub-themes.
6. For each theme, identify the start and end page (if the document has pages/is a PDF). If not, use estimated percentages or indices.
7. High Priority: Chunks should feel like an index of a book.
8. Themes should be logically treated as the main units of study.
9. Output ONLY a valid JSON object with this structure:
{
  "title": "Subject Title",
  "description": "Brief 2-3 sentence description of the syllabus and learning objectives.",
  "chapters": [
    {
      "title": "Theme Title",
      "startPage": 1,
      "endPage": 3,
      "summary": "Brief 1-sentence description of the topic covered. Do not reference the document."
    }
  ]
}
''';

    return getChatResponseWithFileUri(
      prompt,
      localizations,
      responseMimeType: 'application/json',
      fileUri: fileUri,
      fileMimeType: fileMimeType,
    );
  }

  @override
  Future<String> generateStudyIndexFromText(
    AppLocalizations localizations, {
    required String content,
    required AiGenerationMode generationMode,
    required String language,
  }) async {
    final header = generationMode == AiGenerationMode.topic
        ? 'The user wants a personalized study plan about the following topic/s: $content'
        : 'The user has provided the following text for creating a study plan:\n\n$content';

    final targetLanguage = language;

    final prompt =
        '''
Act as an expert academic educator. $header

Analyze the content and generate a structured study guide with a Table of Contents for a personalized study plan.

IMPORTANT GLOBAL RULE:
ALL fields in the JSON output (title, description, chapter titles, summaries) MUST be written strictly in the following language: $targetLanguage.

Rules:
1. Generate a concise title that summarizes the subject matter.
2. Generate a brief description (2-3 sentences) explaining the syllabus content and its key learning objectives.
3. Divide the content into logical "Themes" or "Chapters" (chunks).
4. Each theme should be granular enough to be studied in a single session.
5. Themes should be logically treated as the main units of study.
6. Output ONLY a valid JSON object with this structure:
{
  "title": "Subject Title",
  "description": "Brief 2-3 sentence description of the syllabus and learning objectives.",
  "chapters": [
    {
      "title": "Theme Title",
      "summary": "Brief 1-sentence description of the topic covered."
    }
  ]
}
''';

    return getChatResponse(
      prompt,
      localizations,
      responseMimeType: 'application/json',
    );
  }
}
