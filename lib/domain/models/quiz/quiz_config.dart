/// Configuration settings for a quiz session.
class QuizConfig {
  /// The total number of questions to be included in the quiz.
  final int questionCount;

  /// Whether the quiz should run in study mode (true) or exam mode (false).
  final bool isStudyMode;

  /// The time limit for the quiz in minutes, if applicable.
  final int? timeLimitMinutes;

  /// Whether a time limit is enabled for the quiz.
  final bool enableTimeLimit;

  /// Creates a [QuizConfig] instance with the specified settings.
  const QuizConfig({
    required this.questionCount,
    this.isStudyMode = false,
    this.enableTimeLimit = false,
    this.timeLimitMinutes,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuizConfig &&
        other.questionCount == questionCount &&
        other.isStudyMode == isStudyMode &&
        other.enableTimeLimit == enableTimeLimit &&
        other.timeLimitMinutes == timeLimitMinutes;
  }

  @override
  int get hashCode =>
      questionCount.hashCode ^
      isStudyMode.hashCode ^
      enableTimeLimit.hashCode ^
      timeLimitMinutes.hashCode;

  @override
  String toString() =>
      'QuizConfig(questionCount: $questionCount, isStudyMode: $isStudyMode, enableTimeLimit: $enableTimeLimit, timeLimitMinutes: $timeLimitMinutes)';
}
