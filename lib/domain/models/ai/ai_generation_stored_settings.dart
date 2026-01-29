/// DTO representing the saved settings for AI question generation.
class AiGenerationStoredSettings {
  /// The name of the selected AI service (e.g., 'Google Gemini', 'OpenAI').
  final String? serviceName;

  /// The name of the selected model for the service.
  final String? modelName;

  /// The language code selected for generation.
  final String? language;

  /// The number of questions to generate.
  final int? questionCount;

  /// The list of selected question types.
  final List<String>? questionTypes;

  /// The drafted text content.
  final String? draftText;

  /// Creates a new instance of [AiGenerationStoredSettings].
  const AiGenerationStoredSettings({
    this.serviceName,
    this.modelName,
    this.language,
    this.questionCount,
    this.questionTypes,
    this.draftText,
  });
}
