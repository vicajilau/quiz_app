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
import 'package:quizdy/data/interceptors/ai_logging_interceptor.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/data/services/configuration_service.dart';
import 'package:quizdy/data/services/ai/ai_service.dart';

class GeminiService extends AIService {
  static const String _baseUrlBeta =
      'https://generativelanguage.googleapis.com/v1beta';
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
}
