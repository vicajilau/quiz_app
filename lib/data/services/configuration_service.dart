import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/quiz/question_order.dart';
import '../../core/security/encryption_service.dart';

class ConfigurationService {
  static const String _questionOrderKey = 'question_order';
  static const String _examTimeEnabledKey = 'exam_time_enabled';
  static const String _examTimeMinutesKey = 'exam_time_minutes';
  static const String _aiAssistantEnabledKey = 'ai_assistant_enabled';
  static const String _openaiApiKeyKey = 'openai_api_key';
  static const String _geminiApiKeyKey = 'gemini_api_key';
  static const String _randomizeAnswersKey = 'randomize_answers';
  static const String _showCorrectAnswerCountKey = 'show_correct_answer_count';

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

  /// Guarda la API Key de OpenAI de forma segura (encriptada)
  Future<void> saveOpenAIApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedApiKey = EncryptionService.encrypt(apiKey);
    await prefs.setString(_openaiApiKeyKey, encryptedApiKey);
  }

  /// Obtiene la API Key de OpenAI (desencriptada)
  Future<String?> getOpenAIApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedApiKey = prefs.getString(_openaiApiKeyKey);

    if (encryptedApiKey == null || encryptedApiKey.isEmpty) {
      return null;
    }

    return EncryptionService.decrypt(encryptedApiKey);
  }

  /// Elimina la API Key de OpenAI
  Future<void> deleteOpenAIApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_openaiApiKeyKey);
  }

  /// Guarda la API Key de Gemini de forma segura (encriptada)
  Future<void> saveGeminiApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedApiKey = EncryptionService.encrypt(apiKey);
    await prefs.setString(_geminiApiKeyKey, encryptedApiKey);
  }

  /// Obtiene la API Key de Gemini (desencriptada)
  Future<String?> getGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedApiKey = prefs.getString(_geminiApiKeyKey);

    if (encryptedApiKey == null || encryptedApiKey.isEmpty) {
      return null;
    }

    return EncryptionService.decrypt(encryptedApiKey);
  }

  /// Elimina la API Key de Gemini
  Future<void> deleteGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_geminiApiKeyKey);
  }

  /// Guarda si las respuestas deben ser aleatorizadas
  Future<void> saveRandomizeAnswers(bool randomize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_randomizeAnswersKey, randomize);
  }

  /// Obtiene si las respuestas deben ser aleatorizadas, por defecto es false
  Future<bool> getRandomizeAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_randomizeAnswersKey) ?? false;
  }

  /// Guarda si se debe mostrar el número de respuestas correctas
  Future<void> saveShowCorrectAnswerCount(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showCorrectAnswerCountKey, show);
  }

  /// Obtiene si se debe mostrar el número de respuestas correctas, por defecto es false
  Future<bool> getShowCorrectAnswerCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showCorrectAnswerCountKey) ?? false;
  }
}
