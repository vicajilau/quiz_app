import '../../../domain/models/quiz/question.dart';

/// Abstract class representing the base state for quiz execution.
abstract class QuizExecutionState {}

/// Initial state when no quiz execution is in progress.
class QuizExecutionInitial extends QuizExecutionState {}

/// State representing a quiz in progress.
class QuizExecutionInProgress extends QuizExecutionState {
  final List<Question> questions;
  final int currentQuestionIndex;
  final Map<int, List<int>>
  userAnswers; // questionIndex -> selected option indices
  final int totalQuestions;

  QuizExecutionInProgress({
    required this.questions,
    required this.currentQuestionIndex,
    required this.userAnswers,
  }) : totalQuestions = questions.length;

  /// Get the current question
  Question get currentQuestion => questions[currentQuestionIndex];

  /// Check if this is the first question
  bool get isFirstQuestion => currentQuestionIndex == 0;

  /// Check if this is the last question
  bool get isLastQuestion => currentQuestionIndex == totalQuestions - 1;

  /// Get selected answers for current question
  List<int> get currentQuestionAnswers =>
      userAnswers[currentQuestionIndex] ?? [];

  /// Check if an option is selected for current question
  bool isOptionSelected(int optionIndex) {
    return currentQuestionAnswers.contains(optionIndex);
  }

  /// Get progress percentage
  double get progress => (currentQuestionIndex + 1) / totalQuestions;

  /// Copy with method for state updates
  QuizExecutionInProgress copyWith({
    List<Question>? questions,
    int? currentQuestionIndex,
    Map<int, List<int>>? userAnswers,
  }) {
    return QuizExecutionInProgress(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userAnswers: userAnswers ?? this.userAnswers,
    );
  }
}

/// State representing quiz completion with results.
class QuizExecutionCompleted extends QuizExecutionState {
  final List<Question> questions;
  final Map<int, List<int>> userAnswers;
  final int correctAnswers;
  final int totalQuestions;
  final double score; // percentage

  QuizExecutionCompleted({
    required this.questions,
    required this.userAnswers,
    required this.correctAnswers,
    required this.totalQuestions,
  }) : score = (correctAnswers / totalQuestions) * 100;

  /// Get details for each question
  List<QuestionResult> get questionResults {
    return questions.asMap().entries.map((entry) {
      final index = entry.key;
      final question = entry.value;
      final userAnswer = userAnswers[index] ?? [];
      final isCorrect = _isAnswerCorrect(question.correctAnswers, userAnswer);

      return QuestionResult(
        question: question,
        userAnswers: userAnswer,
        correctAnswers: question.correctAnswers,
        isCorrect: isCorrect,
      );
    }).toList();
  }

  bool _isAnswerCorrect(List<int> correctAnswers, List<int> userAnswers) {
    if (correctAnswers.length != userAnswers.length) return false;
    final sortedCorrect = List<int>.from(correctAnswers)..sort();
    final sortedUser = List<int>.from(userAnswers)..sort();
    return sortedCorrect.toString() == sortedUser.toString();
  }
}

/// Class to represent individual question results
class QuestionResult {
  final Question question;
  final List<int> userAnswers;
  final List<int> correctAnswers;
  final bool isCorrect;

  QuestionResult({
    required this.question,
    required this.userAnswers,
    required this.correctAnswers,
    required this.isCorrect,
  });
}
