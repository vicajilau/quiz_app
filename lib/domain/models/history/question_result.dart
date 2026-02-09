import 'dart:convert';

/// Represents the result of a single question in a quiz attempt.
class QuestionResult {
  /// Content hash of the question (identifies the question content).
  final String questionHash;

  /// The question text (for display purposes).
  final String questionText;

  /// Whether the question was answered correctly.
  final bool isCorrect;

  /// The indices of options the user selected.
  final List<int> userAnswers;

  /// The indices of the correct answers.
  final List<int> correctAnswers;

  /// The user's essay answer (if applicable).
  final String? essayAnswer;

  const QuestionResult({
    required this.questionHash,
    required this.questionText,
    required this.isCorrect,
    required this.userAnswers,
    required this.correctAnswers,
    this.essayAnswer,
  });

  /// Creates a QuestionResult from a JSON map.
  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      questionHash: json['questionHash'] as String,
      questionText: json['questionText'] as String,
      isCorrect: json['isCorrect'] as bool,
      userAnswers: List<int>.from(json['userAnswers'] as List),
      correctAnswers: List<int>.from(json['correctAnswers'] as List),
      essayAnswer: json['essayAnswer'] as String?,
    );
  }

  /// Converts the QuestionResult to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'questionHash': questionHash,
      'questionText': questionText,
      'isCorrect': isCorrect,
      'userAnswers': userAnswers,
      'correctAnswers': correctAnswers,
      if (essayAnswer != null) 'essayAnswer': essayAnswer,
    };
  }

  /// Encodes a list of QuestionResult to a JSON string.
  static String encodeList(List<QuestionResult> results) {
    return jsonEncode(results.map((r) => r.toJson()).toList());
  }

  /// Decodes a JSON string to a list of QuestionResult.
  static List<QuestionResult> decodeList(String json) {
    final List<dynamic> decoded = jsonDecode(json) as List<dynamic>;
    return decoded
        .map((item) => QuestionResult.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  String toString() {
    return 'QuestionResult(hash: $questionHash, correct: $isCorrect, userAnswers: $userAnswers)';
  }
}

/// Statistics for a question across multiple quiz attempts.
class QuestionFailureStat {
  /// Content hash of the question.
  final String questionHash;

  /// The question text (for display).
  final String questionText;

  /// Total number of times this question was attempted.
  int totalAttempts;

  /// Number of times this question was answered incorrectly.
  int failureCount;

  QuestionFailureStat({
    required this.questionHash,
    required this.questionText,
    this.totalAttempts = 0,
    this.failureCount = 0,
  });

  /// The failure rate as a decimal (0.0 to 1.0).
  double get failureRate =>
      totalAttempts > 0 ? failureCount / totalAttempts : 0;

  /// The failure rate as a percentage (0 to 100).
  double get failurePercentage => failureRate * 100;

  /// The success rate as a percentage (0 to 100).
  double get successPercentage => 100 - failurePercentage;

  @override
  String toString() {
    return 'QuestionFailureStat(hash: $questionHash, failures: $failureCount/$totalAttempts, rate: ${failurePercentage.toStringAsFixed(1)}%)';
  }
}
