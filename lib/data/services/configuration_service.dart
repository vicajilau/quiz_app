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
  static const String _defaultAIServiceKey = 'default_ai_service';
  static const String _defaultAIModelKey = 'default_ai_model';

  static const String _aiKeepDraftKey = 'ai_keep_draft';
  static const String _aiDraftTextKey = 'ai_draft_text';
  static const String _aiGenerationServiceKey = 'ai_generation_service';
  static const String _aiGenerationModelKey = 'ai_generation_model';
  static const String _aiGenerationLanguageKey = 'ai_generation_language';
  static const String _aiGenerationQuestionCountKey =
      'ai_generation_question_count';
  static const String _aiGenerationQuestionTypesKey =
      'ai_generation_question_types';

  static ConfigurationService? _instance;
  static ConfigurationService get instance =>
      _instance ??= ConfigurationService._();

  ConfigurationService._();

  /// Saves the selected question order to SharedPreferences
  Future<void> saveQuestionOrder(QuestionOrder order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_questionOrderKey, order.value);
  }

  /// Gets the saved question order, defaults to random
  Future<QuestionOrder> getQuestionOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final orderValue = prefs.getString(_questionOrderKey);

    if (orderValue != null) {
      return QuestionOrder.fromString(orderValue);
    }

    return QuestionOrder.random; // Valor por defecto
  }

  /// Saves whether exam time limit is enabled
  Future<void> saveExamTimeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_examTimeEnabledKey, enabled);
  }

  /// Gets whether exam time limit is enabled, defaults to false
  Future<bool> getExamTimeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_examTimeEnabledKey) ?? false;
  }

  /// Saves the exam time limit in minutes
  Future<void> saveExamTimeMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_examTimeMinutesKey, minutes);
  }

  /// Gets the exam time limit in minutes, defaults to 60
  Future<int> getExamTimeMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_examTimeMinutesKey) ?? 60;
  }

  /// Saves whether AI assistant is enabled
  Future<void> saveAIAssistantEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_aiAssistantEnabledKey, enabled);
  }

  /// Gets whether AI assistant is enabled, defaults to true
  Future<bool> getAIAssistantEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_aiAssistantEnabledKey) ?? true;
  }

  /// Saves OpenAI API Key securely (encrypted)
  Future<void> saveOpenAIApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedApiKey = EncryptionService.encrypt(apiKey);
    await prefs.setString(_openaiApiKeyKey, encryptedApiKey);
  }

  /// Gets OpenAI API Key (decrypted)
  Future<String?> getOpenAIApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedApiKey = prefs.getString(_openaiApiKeyKey);

    if (encryptedApiKey == null || encryptedApiKey.isEmpty) {
      return null;
    }

    return EncryptionService.decrypt(encryptedApiKey);
  }

  /// Deletes OpenAI API Key
  Future<void> deleteOpenAIApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_openaiApiKeyKey);
  }

  /// Saves Gemini API Key securely (encrypted)
  Future<void> saveGeminiApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedApiKey = EncryptionService.encrypt(apiKey);
    await prefs.setString(_geminiApiKeyKey, encryptedApiKey);
  }

  /// Gets Gemini API Key (decrypted)
  Future<String?> getGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedApiKey = prefs.getString(_geminiApiKeyKey);

    if (encryptedApiKey == null || encryptedApiKey.isEmpty) {
      return null;
    }

    return EncryptionService.decrypt(encryptedApiKey);
  }

  /// Deletes Gemini API Key
  Future<void> deleteGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_geminiApiKeyKey);
  }

  /// Saves whether answers should be randomized
  Future<void> saveRandomizeAnswers(bool randomize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_randomizeAnswersKey, randomize);
  }

  /// Gets whether answers should be randomized, defaults to false
  Future<bool> getRandomizeAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_randomizeAnswersKey) ?? false;
  }

  /// Saves whether to show correct answer count
  Future<void> saveShowCorrectAnswerCount(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showCorrectAnswerCountKey, show);
  }

  /// Gets whether to show correct answer count, defaults to false
  Future<bool> getShowCorrectAnswerCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showCorrectAnswerCountKey) ?? false;
  }

  /// Saves the default AI service name
  Future<void> saveDefaultAIService(String serviceName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultAIServiceKey, serviceName);
  }

  /// Gets the default AI service name, returns null if not set
  Future<String?> getDefaultAIService() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultAIServiceKey);
  }

  /// Saves the default AI model
  Future<void> saveDefaultAIModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultAIModelKey, model);
  }

  /// Gets the default AI model, returns null if not set
  Future<String?> getDefaultAIModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultAIModelKey);
  }

  /// Deletes the default AI service and model
  Future<void> deleteDefaultAISettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_defaultAIServiceKey);
    await prefs.remove(_defaultAIModelKey);
  }

  /// Saves whether to keep AI text draft
  Future<void> saveAiKeepDraft(bool keep) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_aiKeepDraftKey, keep);
  }

  /// Gets whether to keep AI text draft, defaults to true
  Future<bool> getAiKeepDraft() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_aiKeepDraftKey) ?? true;
  }

  /// Saves the AI text draft
  Future<void> saveAiDraftText(String text) async {
    final prefs = await SharedPreferences.getInstance();
    if (text.isEmpty) {
      await prefs.remove(_aiDraftTextKey);
    } else {
      await prefs.setString(_aiDraftTextKey, text);
    }
  }

  /// Gets the AI text draft
  Future<String?> getAiDraftText() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_aiDraftTextKey);
  }

  /// Saves the AI generation service name
  Future<void> saveAiGenerationService(String serviceName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_aiGenerationServiceKey, serviceName);
  }

  /// Gets the AI generation service name
  Future<String?> getAiGenerationService() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_aiGenerationServiceKey);
  }

  /// Saves the AI generation model name
  Future<void> saveAiGenerationModel(String modelName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_aiGenerationModelKey, modelName);
  }

  /// Gets the AI generation model name
  Future<String?> getAiGenerationModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_aiGenerationModelKey);
  }

  /// Saves the AI generation language code
  Future<void> saveAiGenerationLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_aiGenerationLanguageKey, languageCode);
  }

  /// Gets the AI generation language code
  Future<String?> getAiGenerationLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_aiGenerationLanguageKey);
  }

  /// Saves the AI generation question count
  Future<void> saveAiGenerationQuestionCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_aiGenerationQuestionCountKey, count);
  }

  /// Gets the AI generation question count
  Future<int?> getAiGenerationQuestionCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_aiGenerationQuestionCountKey);
  }

  /// Saves the AI generation question types (as list of strings)
  Future<void> saveAiGenerationQuestionTypes(List<String> types) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_aiGenerationQuestionTypesKey, types);
  }

  /// Gets the AI generation question types
  Future<List<String>?> getAiGenerationQuestionTypes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_aiGenerationQuestionTypesKey);
  }
}
