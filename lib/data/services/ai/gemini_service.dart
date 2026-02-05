import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/domain/models/ai/ai_file_attachment.dart';
import '../configuration_service.dart';
import 'ai_service.dart';

class GeminiService extends AIService {
  static const String _baseUrlBeta =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String _baseUrlAlpha =
      'https://generativelanguage.googleapis.com/v1alpha';
  static const String _defaultModel = 'gemini-flash-latest';

  static const List<String> _models = [
    'gemini-flash-latest',
    'gemini-2.5-flash',
    'gemini-2.0-flash-lite',
    'gemini-2.5-pro',
    'gemini-3-flash-preview',
    'gemini-3-pro-preview',
  ];

  static GeminiService? _instance;
  static GeminiService get instance => _instance ??= GeminiService._();

  GeminiService._();

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

    final http.Response response;
    try {
      response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
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
        }),
      );
    } catch (e) {
      throw Exception(localizations.networkError);
    }

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final candidates = jsonResponse['candidates'] as List?;

      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content']['parts'][0]['text'];
        return content?.toString().trim() ?? localizations.noResponseReceived;
      } else {
        return localizations.noResponseReceived;
      }
    } else if (response.statusCode == 400) {
      throw Exception(localizations.aiErrorResponse);
    } else if (response.statusCode == 403) {
      throw Exception(localizations.invalidApiKeyError);
    } else if (response.statusCode == 429) {
      throw Exception(localizations.rateLimitError);
    } else {
      throw Exception(localizations.aiErrorResponse);
    }
  }

  @override
  Future<String> getChatResponseWithFile(
    String prompt,
    AppLocalizations localizations, {
    String? model,
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

    final http.Response response;
    try {
      response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
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
        }),
      );
    } catch (e) {
      throw Exception(localizations.networkError);
    }

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final candidates = jsonResponse['candidates'] as List?;

      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content']['parts'][0]['text'];
        return content?.toString().trim() ?? localizations.noResponseReceived;
      } else {
        return localizations.noResponseReceived;
      }
    } else if (response.statusCode == 400) {
      throw Exception(localizations.aiErrorResponse);
    } else if (response.statusCode == 403) {
      throw Exception(localizations.invalidApiKeyError);
    } else if (response.statusCode == 429) {
      throw Exception(localizations.rateLimitError);
    } else {
      throw Exception(localizations.aiErrorResponse);
    }
  }
}
