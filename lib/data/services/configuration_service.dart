import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/quiz/question_order.dart';

class ConfigurationService {
  static const String _questionOrderKey = 'question_order';
  static const String _examTimeEnabledKey = 'exam_time_enabled';
  static const String _examTimeMinutesKey = 'exam_time_minutes';
  static const String _aiAssistantEnabledKey = 'ai_assistant_enabled';

  static ConfigurationService? _instance;
  static ConfigurationService get instance =>
      _instance ??= ConfigurationService._();

  ConfigurationService._();

  /// Guarda el orden de preguntas seleccionado en SharedPreferences
  Future<void> saveQuestionOrder(QuestionOrder order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_questionOrderKey, order.value);
  }

  /// Obtiene el orden de preguntas guardado, por defecto es aleatorio
  Future<QuestionOrder> getQuestionOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final orderValue = prefs.getString(_questionOrderKey);

    if (orderValue != null) {
      return QuestionOrder.fromString(orderValue);
    }

    return QuestionOrder.random; // Valor por defecto
  }

  /// Guarda si el tiempo límite del examen está habilitado
  Future<void> saveExamTimeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_examTimeEnabledKey, enabled);
  }

  /// Obtiene si el tiempo límite del examen está habilitado, por defecto es false
  Future<bool> getExamTimeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_examTimeEnabledKey) ?? false;
  }

  /// Guarda el tiempo límite del examen en minutos
  Future<void> saveExamTimeMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_examTimeMinutesKey, minutes);
  }

  /// Obtiene el tiempo límite del examen en minutos, por defecto es 60
  Future<int> getExamTimeMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_examTimeMinutesKey) ?? 60;
  }

  /// Guarda si el asistente de IA está habilitado
  Future<void> saveAIAssistantEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_aiAssistantEnabledKey, enabled);
  }

  /// Obtiene si el asistente de IA está habilitado, por defecto es true
  Future<bool> getAIAssistantEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_aiAssistantEnabledKey) ?? true;
  }
}
