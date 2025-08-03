import 'dart:convert';
import 'package:http/http.dart' as http;
import 'configuration_service.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _chatEndpoint = '/chat/completions';

  static OpenAIService? _instance;
  static OpenAIService get instance => _instance ??= OpenAIService._();

  OpenAIService._();

  /// Realiza una petición a la API de ChatGPT
  static Future<String> getChatResponse(
    String prompt,
    AppLocalizations localizations,
  ) async {
    final apiKey = await ConfigurationService.instance.getOpenAIApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(localizations.openaiApiKeyNotConfigured);
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_chatEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['choices'][0]['message']['content'];
        return content?.toString().trim() ?? localizations.noResponseReceived;
      } else if (response.statusCode == 401) {
        throw Exception(localizations.invalidApiKeyError);
      } else if (response.statusCode == 429) {
        throw Exception(localizations.rateLimitError);
      } else if (response.statusCode == 404) {
        throw Exception(localizations.modelNotFoundError);
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
