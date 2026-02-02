class QuizConfig {
  final int questionCount;
  final bool isStudyMode;

  const QuizConfig({required this.questionCount, this.isStudyMode = false});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuizConfig &&
        other.questionCount == questionCount &&
        other.isStudyMode == isStudyMode;
  }

  @override
  int get hashCode => questionCount.hashCode ^ isStudyMode.hashCode;

  @override
  String toString() =>
      'QuizConfig(questionCount: $questionCount, isStudyMode: $isStudyMode)';
}
