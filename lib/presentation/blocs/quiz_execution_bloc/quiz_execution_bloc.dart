import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/core/service_locator.dart';
import 'package:quiz_app/data/services/quiz_record/quiz_record_service.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/question_type.dart';
import 'package:quiz_app/domain/models/history/quiz_record.dart';
import 'package:quiz_app/domain/models/history/question_result.dart' as history;
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_event.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';

/// BLoC for managing quiz execution state and logic.
class QuizExecutionBloc extends Bloc<QuizExecutionEvent, QuizExecutionState> {
  final QuizRecordService _recordService;

  // Track quiz metadata for record saving
  DateTime? _quizStartTime;
  String? _currentQuizId;
  String? _currentQuizTitle;
  String? _currentQuizVersion;
  String? _currentQuizAuthor;

  QuizExecutionBloc({QuizRecordService? recordService})
    : _recordService =
          recordService ?? ServiceLocator.instance.getIt<QuizRecordService>(),
      super(QuizExecutionInitial()) {
    // Handle quiz start
    on<QuizExecutionStarted>((event, emit) {
      // Track quiz start time and metadata
      // Preserve existing metadata if new values are null (for retry scenarios)
      _quizStartTime = DateTime.now();
      _currentQuizId = event.quizId ?? _currentQuizId;
      _currentQuizTitle = event.quizTitle ?? _currentQuizTitle;
      _currentQuizVersion = event.quizVersion ?? _currentQuizVersion;
      _currentQuizAuthor = event.quizAuthor ?? _currentQuizAuthor;

      emit(
        QuizExecutionInProgress(
          questions: event.questions,
          currentQuestionIndex: 0,
          userAnswers: {},
          isStudyMode: event.isStudyMode,
        ),
      );
    });

    // Handle answer selection
    on<AnswerSelected>((event, emit) {
      if (state is QuizExecutionInProgress) {
        final currentState = state as QuizExecutionInProgress;
        final currentQuestionIndex = currentState.currentQuestionIndex;
        final currentQuestion = currentState.currentQuestion;
        final newUserAnswers = Map<int, List<int>>.from(
          currentState.userAnswers,
        );

        // Get current answers for this question
        final currentAnswers = List<int>.from(
          newUserAnswers[currentQuestionIndex] ?? [],
        );

        // Handle different question types
        if (currentQuestion.type == QuestionType.multipleChoice) {
          // Multiple choice: allow multiple selections
          if (event.isSelected) {
            // Add answer if not already present
            if (!currentAnswers.contains(event.optionIndex)) {
              currentAnswers.add(event.optionIndex);
            }
          } else {
            // Remove answer if present
            currentAnswers.remove(event.optionIndex);
          }
        } else {
          // Single choice, true/false, essay: allow only one selection
          if (event.isSelected) {
            // Clear all previous answers and set only the selected one
            currentAnswers.clear();
            currentAnswers.add(event.optionIndex);
          }
          // For single selection types, we don't handle deselection
          // The radio button behavior handles this automatically
        }

        // Update the answers map
        newUserAnswers[currentQuestionIndex] = currentAnswers;

        emit(currentState.copyWith(userAnswers: newUserAnswers));
      }
    });

    // Handle essay answer changes
    on<EssayAnswerChanged>((event, emit) {
      if (state is QuizExecutionInProgress) {
        final currentState = state as QuizExecutionInProgress;
        final currentQuestionIndex = currentState.currentQuestionIndex;
        final newEssayAnswers = Map<int, String>.from(
          currentState.essayAnswers,
        );

        // Update the essay answer for current question
        newEssayAnswers[currentQuestionIndex] = event.text;

        emit(currentState.copyWith(essayAnswers: newEssayAnswers));
      }
    });

    // Handle Check Answer (Study Mode)
    on<CheckAnswerRequested>((event, emit) {
      if (state is QuizExecutionInProgress) {
        final currentState = state as QuizExecutionInProgress;
        final currentQuestionIndex = currentState.currentQuestionIndex;

        // Add current question to validated set
        final newValidatedQuestions = Set<int>.from(
          currentState.validatedQuestions,
        )..add(currentQuestionIndex);

        emit(currentState.copyWith(validatedQuestions: newValidatedQuestions));
      }
    });

    // Handle next question
    on<NextQuestionRequested>((event, emit) {
      if (state is QuizExecutionInProgress) {
        final currentState = state as QuizExecutionInProgress;

        // Check if current question has been answered
        // In Study Mode, we allow skipping (Next without answering)
        if (!currentState.isStudyMode &&
            !currentState.hasCurrentQuestionAnswered) {
          // Don't proceed if no answer is selected in Exam Mode
          return;
        }

        if (!currentState.isLastQuestion) {
          emit(
            currentState.copyWith(
              currentQuestionIndex: currentState.currentQuestionIndex + 1,
            ),
          );
        }
      }
    });

    // Handle previous question
    on<PreviousQuestionRequested>((event, emit) {
      if (state is QuizExecutionInProgress) {
        final currentState = state as QuizExecutionInProgress;
        if (!currentState.isFirstQuestion) {
          emit(
            currentState.copyWith(
              currentQuestionIndex: currentState.currentQuestionIndex - 1,
            ),
          );
        }
      }
    });

    // Handle quiz submission
    on<QuizSubmitted>((event, emit) async {
      if (state is QuizExecutionInProgress) {
        final currentState = state as QuizExecutionInProgress;

        // Calculate correct answers
        int correctCount = 0;
        for (int i = 0; i < currentState.questions.length; i++) {
          final question = currentState.questions[i];
          final userAnswer = currentState.userAnswers[i] ?? [];
          final essayAnswer = currentState.essayAnswers[i] ?? '';

          if (_isAnswerCorrect(question, userAnswer, essayAnswer)) {
            correctCount++;
          }
        }

        final completedState = QuizExecutionCompleted(
          questions: currentState.questions,
          userAnswers: currentState.userAnswers,
          essayAnswers: currentState.essayAnswers,
          correctAnswers: correctCount,
          totalQuestions: currentState.totalQuestions,
        );

        // Save quiz record (non-blocking)
        await _saveQuizRecord(
          currentState: currentState,
          correctCount: correctCount,
          score: completedState.score,
        );

        emit(completedState);
      }
    });

    // Handle quiz restart
    on<QuizRestarted>((event, emit) {
      if (state is QuizExecutionCompleted) {
        final completedState = state as QuizExecutionCompleted;
        // Reset start time for new attempt
        _quizStartTime = DateTime.now();

        emit(
          QuizExecutionInProgress(
            questions: completedState.questions,
            currentQuestionIndex: 0,
            userAnswers: {},
            essayAnswers: {},
            validatedQuestions: {},
            isStudyMode: false,
          ),
        );
      }
    });
  }

  /// Saves the quiz record to persistent storage.
  Future<void> _saveQuizRecord({
    required QuizExecutionInProgress currentState,
    required int correctCount,
    required double score,
  }) async {
    // Only save if we have quiz metadata
    if (_quizStartTime == null || _currentQuizId == null) {
      debugPrint('Quiz record not saved: missing quiz metadata');
      return;
    }

    try {
      // Build question results
      final questionResults = <history.QuestionResult>[];
      for (int i = 0; i < currentState.questions.length; i++) {
        final question = currentState.questions[i];
        final userAnswers = currentState.userAnswers[i] ?? [];
        final essayAnswer = currentState.essayAnswers[i];

        questionResults.add(
          history.QuestionResult(
            questionHash: question.contentHash,
            questionText: question.text,
            isCorrect: _isAnswerCorrect(
              question,
              userAnswers,
              essayAnswer ?? '',
            ),
            userAnswers: userAnswers,
            correctAnswers: question.correctAnswers,
            essayAnswer: essayAnswer,
          ),
        );
      }

      final record = QuizRecord.fromQuizCompletion(
        quizId: _currentQuizId!,
        quizTitle: _currentQuizTitle ?? 'Unknown Quiz',
        quizVersion: _currentQuizVersion ?? '1.0',
        quizAuthor: _currentQuizAuthor,
        startedAt: _quizStartTime!,
        questionResults: questionResults,
        essayAnswers: currentState.essayAnswers,
        correctCount: correctCount,
        totalQuestions: currentState.totalQuestions,
        score: score,
        isStudyMode: currentState.isStudyMode,
      );

      await _recordService.saveRecord(record);
      debugPrint('Quiz record saved: ${record.id}');
    } catch (e) {
      // Log error but don't fail the quiz completion
      debugPrint('Error saving quiz record: $e');
    }
  }

  /// Helper method to check if answer is correct
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
