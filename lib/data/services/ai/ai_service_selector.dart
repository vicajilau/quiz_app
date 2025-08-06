import 'package:quiz_app/data/services/ai/ai_service.dart';
import 'package:quiz_app/data/services/ai/openai_service.dart';
import 'package:quiz_app/data/services/ai/gemini_service.dart';

/// Service to automatically select the available AI service
class AIServiceSelector {
  static AIServiceSelector? _instance;
  static AIServiceSelector get instance => _instance ??= AIServiceSelector._();

  AIServiceSelector._();

  /// Gets the first available AI service
  Future<AIService?> getAvailableService() async {
    final services = await getAvailableServices();
    return services.isNotEmpty ? services.first : null;
  }

  /// Gets all available AI services
  Future<List<AIService>> getAvailableServices() async {
    final services = <AIService>[];

    // Check Gemini
    final geminiService = GeminiService.instance;
    if (await geminiService.isAvailable()) {
      services.add(geminiService);
    }

    // Check OpenAI
    final openaiService = OpenAIService.instance;
    if (await openaiService.isAvailable()) {
      services.add(openaiService);
    }

    return services;
  }

  /// Checks if there is at least one available AI service
  Future<bool> hasAvailableService() async {
    final services = await getAvailableServices();
    return services.isNotEmpty;
  }

  /// Gets information about all configured services
  Future<Map<String, bool>> getServicesStatus() async {
    final openaiService = OpenAIService.instance;
    final geminiService = GeminiService.instance;

    return {
      'Gemini': await geminiService.isAvailable(),
      'OpenAI': await openaiService.isAvailable(),
    };
  }
}
