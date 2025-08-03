import 'package:quiz_app/data/services/ai/ai_service.dart';
import 'package:quiz_app/data/services/openai_service.dart';
import 'package:quiz_app/data/services/ai/gemini_service.dart';

/// Servicio para seleccionar automáticamente el servicio de IA disponible
class AIServiceSelector {
  static AIServiceSelector? _instance;
  static AIServiceSelector get instance => _instance ??= AIServiceSelector._();

  AIServiceSelector._();

  /// Obtiene el primer servicio de IA disponible
  /// Prioridad: OpenAI -> Gemini
  Future<AIService?> getAvailableService() async {
    final services = await getAvailableServices();
    return services.isNotEmpty ? services.first : null;
  }

  /// Obtiene todos los servicios de IA disponibles
  Future<List<AIService>> getAvailableServices() async {
    final services = <AIService>[];

    // Verificar OpenAI
    final openaiService = OpenAIService.instance;
    if (await openaiService.isAvailable()) {
      services.add(openaiService);
    }

    // Verificar Gemini
    final geminiService = GeminiService.instance;
    if (await geminiService.isAvailable()) {
      services.add(geminiService);
    }

    return services;
  }

  /// Verifica si hay al menos un servicio de IA disponible
  Future<bool> hasAvailableService() async {
    final services = await getAvailableServices();
    return services.isNotEmpty;
  }

  /// Obtiene información de todos los servicios configurados
  Future<Map<String, bool>> getServicesStatus() async {
    final openaiService = OpenAIService.instance;
    final geminiService = GeminiService.instance;

    return {
      'OpenAI': await openaiService.isAvailable(),
      'Gemini': await geminiService.isAvailable(),
    };
  }
}
