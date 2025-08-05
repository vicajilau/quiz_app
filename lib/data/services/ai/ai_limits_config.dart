/// Configuration class for AI service limits
/// This allows for easy adjustment of limits without modifying individual services
class AILimitsConfig {
  static const int _defaultWordLimit = 3000;
  static const int _minWordRequirement = 10;

  // Static configuration that can be easily modified
  static const Map<String, AIServiceLimits> _serviceLimits = {
    'OpenAI GPT': AIServiceLimits(
      maxWords: 2000,
      maxCharacters: 8000,
      description: 'Conservative limit for GPT models',
    ),
    'Google Gemini': AIServiceLimits(
      maxWords: 8000,
      maxCharacters: 30000,
      description: 'Higher context window for Gemini',
    ),
  };

  /// Get limits for a specific service by name
  static AIServiceLimits? getLimitsForService(String serviceName) {
    return _serviceLimits[serviceName];
  }

  /// Get default word limit
  static int get defaultWordLimit => _defaultWordLimit;

  /// Get minimum word requirement
  static int get minWordRequirement => _minWordRequirement;

  /// Check if a service has custom limits configured
  static bool hasCustomLimits(String serviceName) {
    return _serviceLimits.containsKey(serviceName);
  }

  /// Get all configured service names
  static Set<String> get configuredServices => _serviceLimits.keys.toSet();
}

/// Data class for AI service limits
class AIServiceLimits {
  final int maxWords;
  final int? maxCharacters;
  final String description;

  const AIServiceLimits({
    required this.maxWords,
    this.maxCharacters,
    required this.description,
  });

  /// Validate content against these limits
  bool isContentValid(String content) {
    final wordCount = content.trim().isEmpty
        ? 0
        : content.split(RegExp(r'\s+')).length;
    if (wordCount > maxWords) return false;

    if (maxCharacters != null && content.length > maxCharacters!) return false;

    return wordCount >= AILimitsConfig.minWordRequirement;
  }

  /// Get word count from content
  int getWordCount(String content) {
    return content.trim().isEmpty ? 0 : content.split(RegExp(r'\s+')).length;
  }

  /// Get progress percentage (0.0 to 1.0)
  double getWordProgress(String content) {
    final wordCount = getWordCount(content);
    return (wordCount / maxWords).clamp(0.0, 1.0);
  }
}
