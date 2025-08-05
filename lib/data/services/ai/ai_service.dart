import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'ai_limits_config.dart';

abstract class AIService {
  /// Obtiene una respuesta del servicio de IA basado en el prompt proporcionado
  Future<String> getChatResponse(String prompt, AppLocalizations localizations);

  /// Verifica si el servicio está disponible (tiene API key configurada)
  Future<bool> isAvailable();

  /// Obtiene el nombre del servicio para mostrar en la UI
  String get serviceName;

  /// Obtiene el modelo por defecto del servicio
  String get defaultModel;

  /// Gets the service limits (from config or default implementation)
  AIServiceLimits get limits {
    final configLimits = AILimitsConfig.getLimitsForService(serviceName);
    if (configLimits != null) {
      return configLimits;
    }
    // Fallback to service-specific implementation
    return AIServiceLimits(
      maxWords: maxInputWords,
      maxCharacters: maxInputCharacters,
      description: 'Default limits for $serviceName',
    );
  }

  /// Gets the maximum word limit for input content (can be overridden by config)
  int get maxInputWords => limits.maxWords;

  /// Gets the maximum character limit for input content (can be overridden by config)
  int? get maxInputCharacters => limits.maxCharacters;

  /// Validates if the input content is within service limits
  bool isContentWithinLimits(String content) {
    return limits.isContentValid(content);
  }

  /// Gets a description of the service limits for UI display
  String getLimitsDescription(AppLocalizations localizations) {
    final serviceLimits = limits;
    final maxChars = serviceLimits.maxCharacters;
    if (maxChars != null) {
      return localizations.aiServiceLimitsWithChars(
        serviceLimits.maxWords,
        maxChars,
      );
    } else {
      return localizations.aiServiceLimitsWordsOnly(serviceLimits.maxWords);
    }
  }
}
