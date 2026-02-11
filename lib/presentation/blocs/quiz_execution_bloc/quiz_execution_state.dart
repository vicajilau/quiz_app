import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/question_type.dart';

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
  final Map<int, String> essayAnswers; // questionIndex -> essay text
  final int totalQuestions;
  final Set<int>
  validatedQuestions; // Indices of questions that have been checked in Study Mode
  final bool isStudyMode;

  QuizExecutionInProgress({
    required this.questions,
    required this.currentQuestionIndex,
    required this.userAnswers,
    Map<int, String>? essayAnswers,
    Set<int>? validatedQuestions,
    this.isStudyMode = false,
  }) : totalQuestions = questions.length,
       essayAnswers = essayAnswers ?? {},
       validatedQuestions = validatedQuestions ?? {};

  /// Get the current question
  Question get currentQuestion => questions[currentQuestionIndex];

  /// Check if this is the first question
  bool get isFirstQuestion => currentQuestionIndex == 0;

  /// Check if this is the last question
  bool get isLastQuestion => currentQuestionIndex == totalQuestions - 1;

  /// Get selected answers for current question
  List<int> get currentQuestionAnswers =>
      userAnswers[currentQuestionIndex] ?? [];

  /// Check if current question has been validated (checked)
  bool get isCurrentQuestionValidated =>
      validatedQuestions.contains(currentQuestionIndex);

  /// Check if an option is selected for current question
  bool isOptionSelected(int optionIndex) {
    return currentQuestionAnswers.contains(optionIndex);
  }

  /// Check if current question has been answered
  bool get hasCurrentQuestionAnswered {
    // For essay questions, check if there's text
    if (currentQuestion.type == QuestionType.essay) {
      final essayText = essayAnswers[currentQuestionIndex];
      return essayText != null && essayText.trim().isNotEmpty;
    }
    // For other questions, check if there are selected options
    return currentQuestionAnswers.isNotEmpty;
  }

  /// Get total answered questions count
  int get answeredQuestionsCount {
    int count = 0;
    for (int i = 0; i < totalQuestions; i++) {
      if (userAnswers.containsKey(i) && userAnswers[i]!.isNotEmpty) {
        count++;
      } else if (essayAnswers.containsKey(i) &&
          essayAnswers[i]!.trim().isNotEmpty) {
        count++;
      }
    }
    return count;
  }

  /// Get progress percentage based on answered questions
  double get progress =>
      totalQuestions > 0 ? answeredQuestionsCount / totalQuestions : 0.0;

  /// Copy with method for state updates
  QuizExecutionInProgress copyWith({
    List<Question>? questions,
    int? currentQuestionIndex,
    Map<int, List<int>>? userAnswers,
    Map<int, String>? essayAnswers,
    Set<int>? validatedQuestions,
    bool? isStudyMode,
  }) {
    return QuizExecutionInProgress(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      essayAnswers: essayAnswers ?? this.essayAnswers,
      validatedQuestions: validatedQuestions ?? this.validatedQuestions,
      isStudyMode: isStudyMode ?? this.isStudyMode,
    );
  }
}

/// State representing quiz completion with results.
class QuizExecutionCompleted extends QuizExecutionState {
  final List<Question> questions;
  final Map<int, List<int>> userAnswers;
  final Map<int, String> essayAnswers;
  final int correctAnswers;
  final int totalQuestions;
  final double score; // percentage
  final bool isStudyMode;

  QuizExecutionCompleted({
    required this.questions,
    required this.userAnswers,
    required this.essayAnswers,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.isStudyMode,
  }) : score = (correctAnswers / totalQuestions) * 100;

  /// Get details for each question
  List<QuestionResult> get questionResults {
    return questions.asMap().entries.map((entry) {
      final index = entry.key;
      final question = entry.value;
      final userAnswer = userAnswers[index] ?? [];
      final essayAnswer = essayAnswers[index] ?? '';
      final isCorrect = _isAnswerCorrect(question, userAnswer, essayAnswer);

      return QuestionResult(
        question: question,
        userAnswers: userAnswer,
        essayAnswer: essayAnswer,
        correctAnswers: question.correctAnswers,
        isCorrect: isCorrect,
      );
    }).toList();
  }

  bool _isAnswerCorrect(
    Question question,
    List<int> userAnswers,
    String essayAnswer,
  ) {
    // Essay questions are always considered "correct" since they require manual grading
    if (question.type == QuestionType.essay) {
      return essayAnswer.trim().isNotEmpty;
    }

    final correctAnswers = question.correctAnswers;
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
  final String essayAnswer;
  final List<int> correctAnswers;
  final bool isCorrect;

  QuestionResult({
    required this.question,
    required this.userAnswers,
    required this.essayAnswer,
    required this.correctAnswers,
    required this.isCorrect,
  });
}
