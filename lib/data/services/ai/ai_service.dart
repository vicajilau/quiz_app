import 'package:quiz_app/core/l10n/app_localizations.dart';

abstract class AIService {
  /// Obtiene una respuesta del servicio de IA basado en el prompt proporcionado
  Future<String> getChatResponse(
    String prompt,
    AppLocalizations localizations, {
    String? model,
  });

  /// Verifica si el servicio está disponible (tiene API key configurada)
  Future<bool> isAvailable();

  /// Obtiene el nombre del servicio para mostrar en la UI
  String get serviceName;

  /// Obtiene el modelo por defecto del servicio
  String get defaultModel;

  /// Obtiene la lista de modelos disponibles para este servicio
  List<String> get availableModels;
}
