/// A Data Transfer Object (DTO) for storing quiz configuration settings.
///
/// This class encapsulates the user's preferred settings for quiz execution,
/// such as the number of questions and the quiz mode (Study vs. Exam).
class QuizConfigStoredSettings {
  /// The number of questions selected for the quiz.
  final int? questionCount;

  /// Whether the quiz should run in Study Mode (true) or Exam Mode (false).
  final bool? isStudyMode;

  /// Creates a [QuizConfigStoredSettings] instance.
  const QuizConfigStoredSettings({
    this.questionCount,
    this.isStudyMode,
    this.subtractPoints,
    this.penaltyAmount,
  });

  /// Whether to subtract points for incorrect answers.
  final bool? subtractPoints;

  /// The amount of points to subtract for each incorrect answer.
  final double? penaltyAmount;
}
