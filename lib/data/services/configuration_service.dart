// Copyright (C) 2026 Víctor Carreras
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quizdy/domain/models/quiz/question_order.dart';
import 'package:quizdy/domain/models/ai/ai_generation_stored_settings.dart';
import 'package:quizdy/domain/models/ai/ai_study_generation_stored_settings.dart';
import 'package:quizdy/domain/models/quiz/quiz_config_stored_settings.dart';
import 'package:quizdy/domain/models/ai/ai_difficulty_level.dart';
import 'package:quizdy/domain/models/ai/ai_generation_category.dart';
import 'package:quizdy/core/security/encryption_service.dart';

class ConfigurationService {
  static const String _questionOrderKey = 'question_order';
  static const String _examTimeEnabledKey = 'exam_time_enabled';
  static const String _examTimeMinutesKey = 'exam_time_minutes';
  static const String _aiAssistantEnabledKey = 'ai_assistant_enabled';
  static const String _openaiApiKeyKey = 'openai_api_key';
  static const String _geminiApiKeyKey = 'gemini_api_key';
  static const String _customAiBaseUrlKey = 'custom_ai_base_url';
  static const String _customAiApiKeyKey = 'custom_ai_api_key';
  static const String _customAiModelsKey = 'custom_ai_models';
  static const String _randomizeAnswersKey = 'randomize_answers';
  static const String _showCorrectAnswerCountKey = 'show_correct_answer_count';
  static const String _defaultAIModelKey = 'default_ai_model';

  static const String _aiKeepDraftKey = 'ai_keep_draft';
  static const String _aiDraftTextKey = 'ai_draft_text';
  static const String _aiDraftFilePathKey = 'ai_draft_file_path';
  static const String _aiGenerationModelKey = 'ai_generation_model';
  static const String _aiGenerationLanguageKey = 'ai_generation_language';
  static const String _aiGenerationQuestionCountKey =
      'ai_generation_question_count';
  static const String _aiGenerationQuestionTypesKey =
      'ai_generation_question_types';
  static const String _aiGenerationIsAutoDifficultyKey =
      'ai_generation_is_auto_difficulty';
  static const String _aiGenerationDifficultyLevelKey =
      'ai_generation_difficulty_level';
  static const String _aiGenerationCategoryKey = 'ai_generation_category';

  static const String _aiStudyKeepDraftKey = 'ai_study_keep_draft';
  static const String _aiStudyDraftTextKey = 'ai_study_draft_text';
  static const String _aiStudyGenerationModelKey = 'ai_study_generation_model';
  static const String _aiStudyGenerationLanguageKey =
      'ai_study_generation_language';
  static const String _aiStudyGenerationIsAutoDifficultyKey =
      'ai_study_generation_is_auto_difficulty';
  static const String _aiStudyGenerationDifficultyLevelKey =
      'ai_study_generation_difficulty_level';

  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _privacyPolicyAcceptedKey = 'privacy_policy_accepted';

  static const String _lastQuestionCountKey = 'last_question_count';
  static const String _lastQuizModeKey = 'last_quiz_mode';
  static const String _lastQuizSmartModeKey = 'last_quiz_smart_mode';
  static const String _lastQuizEnableMaxIncorrectAnswersKey =
      'last_quiz_enable_max_incorrect_answers';
  static const String _lastQuizMaxIncorrectAnswersKey =
      'last_quiz_max_incorrect_answers';

  final SharedPreferences sharedPreferences;

  final ValueNotifier<bool> aiAvailabilityNotifier = ValueNotifier(false);

  ConfigurationService({required this.sharedPreferences});

  void _refreshAiAvailability() {
    aiAvailabilityNotifier.value = getIsAiAvailable();
  }

  /// Gets whether onboarding has been completed
  bool getOnboardingCompleted() {
    return sharedPreferences.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Marks onboarding as completed
  Future<void> setOnboardingCompleted(bool completed) async {
    await sharedPreferences.setBool(_onboardingCompletedKey, completed);
  }

  /// Gets whether the privacy policy has been accepted
  bool getPrivacyPolicyAccepted() {
    return sharedPreferences.getBool(_privacyPolicyAcceptedKey) ?? false;
  }

  /// Marks privacy policy as accepted
  Future<void> setPrivacyPolicyAccepted(bool accepted) async {
    await sharedPreferences.setBool(_privacyPolicyAcceptedKey, accepted);
  }

  /// Saves the selected question order to SharedPreferences
  Future<void> saveQuestionOrder(QuestionOrder order) async {
    await sharedPreferences.setString(_questionOrderKey, order.name);
  }

  /// Gets the saved question order, defaults to random
  QuestionOrder getQuestionOrder() {
    final orderValue = sharedPreferences.getString(_questionOrderKey);
    if (orderValue != null) {
      return QuestionOrder.fromString(orderValue);
    }
    return QuestionOrder.random;
  }

  /// Saves whether exam time limit is enabled
  Future<void> saveExamTimeEnabled(bool enabled) async {
    await sharedPreferences.setBool(_examTimeEnabledKey, enabled);
  }

  /// Gets whether exam time limit is enabled, defaults to false
  bool getExamTimeEnabled() {
    return sharedPreferences.getBool(_examTimeEnabledKey) ?? false;
  }

  /// Saves the exam time limit in minutes
  Future<void> saveExamTimeMinutes(int minutes) async {
    await sharedPreferences.setInt(_examTimeMinutesKey, minutes);
  }

  /// Gets the exam time limit in minutes, defaults to 60
  int getExamTimeMinutes() {
    return sharedPreferences.getInt(_examTimeMinutesKey) ?? 60;
  }

  /// Saves whether AI assistant is enabled
  Future<void> saveAIAssistantEnabled(bool enabled) async {
    await sharedPreferences.setBool(_aiAssistantEnabledKey, enabled);
    _refreshAiAvailability();
  }

  /// Gets whether AI assistant is enabled, defaults to true
  bool _getAIAssistantEnabled() {
    return sharedPreferences.getBool(_aiAssistantEnabledKey) ?? true;
  }

  /// Saves OpenAI API Key securely (encrypted)
  Future<void> saveOpenAIApiKey(String apiKey) async {
    final encryptedApiKey = EncryptionService.encrypt(apiKey);
    await sharedPreferences.setString(_openaiApiKeyKey, encryptedApiKey);
    _refreshAiAvailability();
  }

  /// Gets OpenAI API Key (decrypted)
  String? getOpenAIApiKey() {
    final encryptedApiKey = sharedPreferences.getString(_openaiApiKeyKey);
    if (encryptedApiKey == null || encryptedApiKey.isEmpty) {
      return null;
    }
    return EncryptionService.decrypt(encryptedApiKey);
  }

  /// Deletes OpenAI API Key
  Future<void> deleteOpenAIApiKey() async {
    await sharedPreferences.remove(_openaiApiKeyKey);
    _refreshAiAvailability();
  }

  /// Saves Gemini API Key securely (encrypted)
  Future<void> saveGeminiApiKey(String apiKey) async {
    final encryptedApiKey = EncryptionService.encrypt(apiKey);
    await sharedPreferences.setString(_geminiApiKeyKey, encryptedApiKey);
    _refreshAiAvailability();
  }

  /// Gets Gemini API Key (decrypted)
  String? getGeminiApiKey() {
    final encryptedApiKey = sharedPreferences.getString(_geminiApiKeyKey);
    if (encryptedApiKey == null || encryptedApiKey.isEmpty) {
      return null;
    }
    return EncryptionService.decrypt(encryptedApiKey);
  }

  /// Deletes Gemini API Key
  Future<void> deleteGeminiApiKey() async {
    await sharedPreferences.remove(_geminiApiKeyKey);
    _refreshAiAvailability();
  }

  /// Saves whether answers should be randomized
  Future<void> saveRandomizeAnswers(bool randomize) async {
    await sharedPreferences.setBool(_randomizeAnswersKey, randomize);
  }

  /// Gets whether answers should be randomized, defaults to false
  bool getRandomizeAnswers() {
    return sharedPreferences.getBool(_randomizeAnswersKey) ?? false;
  }

  /// Saves whether to show correct answer count
  Future<void> saveShowCorrectAnswerCount(bool show) async {
    await sharedPreferences.setBool(_showCorrectAnswerCountKey, show);
  }

  /// Gets whether to show correct answer count, defaults to false
  bool getShowCorrectAnswerCount() {
    return sharedPreferences.getBool(_showCorrectAnswerCountKey) ?? false;
  }

  /// Saves the default AI model
  Future<void> saveDefaultAIModel(String model) async {
    await sharedPreferences.setString(_defaultAIModelKey, model);
  }

  /// Gets the default AI model, returns null if not set
  String? getDefaultAIModel() {
    return sharedPreferences.getString(_defaultAIModelKey);
  }

  /// Deletes the default AI model setting
  Future<void> deleteDefaultAISettings() async {
    await sharedPreferences.remove(_defaultAIModelKey);
  }

  /// Saves whether to keep AI text draft
  Future<void> saveAiKeepDraft(bool keep) async {
    await sharedPreferences.setBool(_aiKeepDraftKey, keep);
  }

  /// Gets whether to keep AI text draft, defaults to true
  bool getAiKeepDraft() {
    return sharedPreferences.getBool(_aiKeepDraftKey) ?? true;
  }

  /// Saves the AI generation settings
  Future<void> saveAiGenerationSettings(
    AiGenerationStoredSettings settings,
  ) async {
    if (settings.modelName != null) {
      await sharedPreferences.setString(
        _aiGenerationModelKey,
        settings.modelName!,
      );
    }
    if (settings.language != null) {
      await sharedPreferences.setString(
        _aiGenerationLanguageKey,
        settings.language!,
      );
    }
    if (settings.questionCount != null) {
      await sharedPreferences.setInt(
        _aiGenerationQuestionCountKey,
        settings.questionCount!,
      );
    }
    if (settings.questionTypes != null) {
      await sharedPreferences.setStringList(
        _aiGenerationQuestionTypesKey,
        settings.questionTypes!,
      );
    }

    if (settings.draftText != null) {
      await sharedPreferences.setString(_aiDraftTextKey, settings.draftText!);
    } else {
      await sharedPreferences.remove(_aiDraftTextKey);
    }

    if (settings.draftFilePath != null) {
      await sharedPreferences.setString(
        _aiDraftFilePathKey,
        settings.draftFilePath!,
      );
    } else {
      await sharedPreferences.remove(_aiDraftFilePathKey);
    }

    if (settings.isAutoDifficulty != null) {
      await sharedPreferences.setBool(
        _aiGenerationIsAutoDifficultyKey,
        settings.isAutoDifficulty!,
      );
    }
    if (settings.difficultyLevel != null) {
      await sharedPreferences.setString(
        _aiGenerationDifficultyLevelKey,
        settings.difficultyLevel!.name,
      );
    }
    if (settings.category != null) {
      await sharedPreferences.setString(
        _aiGenerationCategoryKey,
        settings.category!.name,
      );
    }
  }

  /// Gets the AI generation settings
  AiGenerationStoredSettings getAiGenerationSettings() {
    return AiGenerationStoredSettings(
      modelName: sharedPreferences.getString(_aiGenerationModelKey),
      language: sharedPreferences.getString(_aiGenerationLanguageKey),
      questionCount: sharedPreferences.getInt(_aiGenerationQuestionCountKey),
      questionTypes: sharedPreferences.getStringList(
        _aiGenerationQuestionTypesKey,
      ),
      draftText: sharedPreferences.getString(_aiDraftTextKey),
      draftFilePath: sharedPreferences.getString(_aiDraftFilePathKey),
      isAutoDifficulty: sharedPreferences.getBool(
        _aiGenerationIsAutoDifficultyKey,
      ),
      difficultyLevel: () {
        final name = sharedPreferences.getString(
          _aiGenerationDifficultyLevelKey,
        );
        if (name == null) return null;
        try {
          return AiDifficultyLevel.values.byName(name);
        } catch (_) {
          return null;
        }
      }(),
      category: () {
        final name = sharedPreferences.getString(_aiGenerationCategoryKey);
        if (name == null) return null;
        try {
          return AiGenerationCategory.values.byName(name);
        } catch (_) {
          return null;
        }
      }(),
    );
  }

  /// Saves whether to keep AI study text draft
  Future<void> saveAiStudyKeepDraft(bool keep) async {
    await sharedPreferences.setBool(_aiStudyKeepDraftKey, keep);
  }

  /// Gets whether to keep AI study text draft, defaults to true
  bool getAiStudyKeepDraft() {
    return sharedPreferences.getBool(_aiStudyKeepDraftKey) ?? true;
  }

  /// Saves the AI Study generation settings
  Future<void> saveAiStudyGenerationSettings(
    AiStudyGenerationStoredSettings settings,
  ) async {
    if (settings.modelName != null) {
      await sharedPreferences.setString(
        _aiStudyGenerationModelKey,
        settings.modelName!,
      );
    }
    if (settings.language != null) {
      await sharedPreferences.setString(
        _aiStudyGenerationLanguageKey,
        settings.language!,
      );
    }
    if (settings.draftText != null) {
      await sharedPreferences.setString(
        _aiStudyDraftTextKey,
        settings.draftText!,
      );
    }

    if (settings.isAutoDifficulty != null) {
      await sharedPreferences.setBool(
        _aiStudyGenerationIsAutoDifficultyKey,
        settings.isAutoDifficulty!,
      );
    }
    if (settings.difficultyLevel != null) {
      await sharedPreferences.setString(
        _aiStudyGenerationDifficultyLevelKey,
        settings.difficultyLevel!.name,
      );
    }
  }

  /// Gets the AI Study generation settings
  AiStudyGenerationStoredSettings getAiStudyGenerationSettings() {
    return AiStudyGenerationStoredSettings(
      modelName: sharedPreferences.getString(_aiStudyGenerationModelKey),
      language: sharedPreferences.getString(_aiStudyGenerationLanguageKey),
      draftText: sharedPreferences.getString(_aiStudyDraftTextKey),
      isAutoDifficulty: sharedPreferences.getBool(
        _aiStudyGenerationIsAutoDifficultyKey,
      ),
      difficultyLevel: () {
        final name = sharedPreferences.getString(
          _aiStudyGenerationDifficultyLevelKey,
        );
        if (name == null) return null;
        try {
          return AiDifficultyLevel.values.byName(name);
        } catch (_) {
          return null;
        }
      }(),
    );
  }

  static const String _lastQuizSubtractPointsKey = 'last_quiz_subtract_points';
  static const String _lastQuizPenaltyAmountKey = 'last_quiz_penalty_amount';

  /// Saves the Quiz Config settings
  Future<void> saveQuizConfigSettings(QuizConfigStoredSettings settings) async {
    if (settings.questionCount != null) {
      await sharedPreferences.setInt(
        _lastQuestionCountKey,
        settings.questionCount!,
      );
    } else {
      await sharedPreferences.remove(_lastQuestionCountKey);
    }
    if (settings.isStudyMode != null) {
      await sharedPreferences.setBool(_lastQuizModeKey, settings.isStudyMode!);
    }
    if (settings.isSmartMode != null) {
      await sharedPreferences.setBool(
        _lastQuizSmartModeKey,
        settings.isSmartMode!,
      );
    }
    if (settings.subtractPoints != null) {
      await sharedPreferences.setBool(
        _lastQuizSubtractPointsKey,
        settings.subtractPoints!,
      );
    }
    if (settings.penaltyAmount != null) {
      await sharedPreferences.setDouble(
        _lastQuizPenaltyAmountKey,
        settings.penaltyAmount!,
      );
    }
    if (settings.enableMaxIncorrectAnswers != null) {
      await sharedPreferences.setBool(
        _lastQuizEnableMaxIncorrectAnswersKey,
        settings.enableMaxIncorrectAnswers!,
      );
    }
    if (settings.maxIncorrectAnswers != null) {
      await sharedPreferences.setInt(
        _lastQuizMaxIncorrectAnswersKey,
        settings.maxIncorrectAnswers!,
      );
    }

    if (settings.questionOrder != null) {
      await sharedPreferences.setString(
        _questionOrderKey,
        settings.questionOrder!.name,
      );
    }
    if (settings.randomizeAnswers != null) {
      await sharedPreferences.setBool(
        _randomizeAnswersKey,
        settings.randomizeAnswers!,
      );
    }
    if (settings.showCorrectAnswerCount != null) {
      await sharedPreferences.setBool(
        _showCorrectAnswerCountKey,
        settings.showCorrectAnswerCount!,
      );
    }
  }

  /// Gets the Quiz Config settings
  QuizConfigStoredSettings getQuizConfigSettings() {
    return QuizConfigStoredSettings(
      questionCount: sharedPreferences.getInt(_lastQuestionCountKey),
      isStudyMode: sharedPreferences.getBool(_lastQuizModeKey),
      isSmartMode: sharedPreferences.getBool(_lastQuizSmartModeKey),
      subtractPoints: sharedPreferences.getBool(_lastQuizSubtractPointsKey),
      penaltyAmount: sharedPreferences.getDouble(_lastQuizPenaltyAmountKey),
      enableMaxIncorrectAnswers: sharedPreferences.getBool(
        _lastQuizEnableMaxIncorrectAnswersKey,
      ),
      maxIncorrectAnswers: sharedPreferences.getInt(
        _lastQuizMaxIncorrectAnswersKey,
      ),
      questionOrder: QuestionOrder.fromString(
        sharedPreferences.getString(_questionOrderKey),
      ),
      randomizeAnswers: sharedPreferences.getBool(_randomizeAnswersKey),
      showCorrectAnswerCount: sharedPreferences.getBool(
        _showCorrectAnswerCountKey,
      ),
    );
  }

  /// Saves Custom AI Base URL
  Future<void> saveCustomAiBaseUrl(String baseUrl) async {
    await sharedPreferences.setString(_customAiBaseUrlKey, baseUrl);
    _refreshAiAvailability();
  }

  /// Gets Custom AI Base URL
  String? getCustomAiBaseUrl() {
    return sharedPreferences.getString(_customAiBaseUrlKey);
  }

  /// Deletes Custom AI Base URL
  Future<void> deleteCustomAiBaseUrl() async {
    await sharedPreferences.remove(_customAiBaseUrlKey);
    _refreshAiAvailability();
  }

  /// Saves Custom AI API Key securely (encrypted)
  Future<void> saveCustomAiApiKey(String apiKey) async {
    final encryptedApiKey = EncryptionService.encrypt(apiKey);
    await sharedPreferences.setString(_customAiApiKeyKey, encryptedApiKey);
  }

  /// Gets Custom AI API Key (decrypted)
  String? getCustomAiApiKey() {
    final encryptedApiKey = sharedPreferences.getString(_customAiApiKeyKey);
    if (encryptedApiKey == null || encryptedApiKey.isEmpty) {
      return null;
    }
    return EncryptionService.decrypt(encryptedApiKey);
  }

  /// Deletes Custom AI API Key
  Future<void> deleteCustomAiApiKey() async {
    await sharedPreferences.remove(_customAiApiKeyKey);
  }

  /// Saves Custom AI Models list
  Future<void> saveCustomAiModels(List<String> models) async {
    await sharedPreferences.setStringList(_customAiModelsKey, models);
    _refreshAiAvailability();
  }

  /// Gets Custom AI Models list
  List<String> getCustomAiModels() {
    return sharedPreferences.getStringList(_customAiModelsKey) ?? const [];
  }

  /// Deletes Custom AI Models list
  Future<void> deleteCustomAiModels() async {
    await sharedPreferences.remove(_customAiModelsKey);
    _refreshAiAvailability();
  }

  /// Checks if AI Assistant is available (enabled and has at least one API key or custom config)
  bool getIsAiAvailable() {
    final isEnabled = _getAIAssistantEnabled();
    final openAiKey = getOpenAIApiKey();
    final geminiKey = getGeminiApiKey();
    final customBaseUrl = getCustomAiBaseUrl();
    final customModels = getCustomAiModels();

    return isEnabled &&
        ((openAiKey != null && openAiKey.isNotEmpty) ||
            (geminiKey != null && geminiKey.isNotEmpty) ||
            (customBaseUrl != null &&
                customBaseUrl.isNotEmpty &&
                customModels.isNotEmpty));
  }
}
