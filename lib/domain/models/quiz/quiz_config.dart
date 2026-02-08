class QuizConfig {
  final int questionCount;
  final bool isStudyMode;
  final int? timeLimitMinutes;
  final bool enableTimeLimit;

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
