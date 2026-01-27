import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quiz_app/core/l10n/app_localizations.dart';
import '../configuration_service.dart';
import 'ai_service.dart';

class GeminiService extends AIService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String _defaultModel = 'gemini-flash-latest';

  static const List<String> _models = [
    'gemini-flash-latest',
    'gemini-2.5-flash',
    'gemini-2.0-flash-lite',
    'gemini-2.5-pro',
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

    try {
      final url = '$_baseUrl/models/$selectedModel:generateContent?key=$apiKey';

      final response = await http.post(
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
        final errorBody = jsonDecode(response.body);
        final errorMessage =
            errorBody['error']?['message'] ?? localizations.invalidApiKeyError;
        throw Exception(errorMessage);
      } else if (response.statusCode == 403) {
        throw Exception(localizations.invalidApiKeyError);
      } else if (response.statusCode == 429) {
        throw Exception(localizations.rateLimitError);
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage =
            errorBody['error']?['message'] ?? localizations.unknownError;
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception(localizations.networkError);
    }
  }
}
