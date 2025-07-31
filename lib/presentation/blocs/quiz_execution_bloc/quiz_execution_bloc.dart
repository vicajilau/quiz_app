import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/models/quiz/question_type.dart';
import 'quiz_execution_event.dart';
import 'quiz_execution_state.dart';

/// BLoC for managing quiz execution state and logic.
class QuizExecutionBloc extends Bloc<QuizExecutionEvent, QuizExecutionState> {
  QuizExecutionBloc() : super(QuizExecutionInitial()) {
    // Handle quiz start
    on<QuizExecutionStarted>((event, emit) {
      emit(
        QuizExecutionInProgress(
          questions: event.questions,
          currentQuestionIndex: 0,
          userAnswers: {},
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

    // Handle next question
    on<NextQuestionRequested>((event, emit) {
      if (state is QuizExecutionInProgress) {
        final currentState = state as QuizExecutionInProgress;

        // Check if current question has been answered
        if (!currentState.hasCurrentQuestionAnswered) {
          // Don't proceed if no answer is selected
          // You could emit a specific state here to show an error message if needed
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
    on<QuizSubmitted>((event, emit) {
      if (state is QuizExecutionInProgress) {
        final currentState = state as QuizExecutionInProgress;

        // Calculate correct answers
        int correctCount = 0;
        for (int i = 0; i < currentState.questions.length; i++) {
          final question = currentState.questions[i];
          final userAnswer = currentState.userAnswers[i] ?? [];

          if (_isAnswerCorrect(question.correctAnswers, userAnswer)) {
            correctCount++;
          }
        }

        emit(
          QuizExecutionCompleted(
            questions: currentState.questions,
            userAnswers: currentState.userAnswers,
            correctAnswers: correctCount,
            totalQuestions: currentState.totalQuestions,
          ),
        );
      }
    });

    // Handle quiz restart
    on<QuizRestarted>((event, emit) {
      if (state is QuizExecutionCompleted) {
        final completedState = state as QuizExecutionCompleted;
        emit(
          QuizExecutionInProgress(
            questions: completedState.questions,
            currentQuestionIndex: 0,
            userAnswers: {},
          ),
        );
      }
    });
  }

  /// Helper method to check if answer is correct
  bool _isAnswerCorrect(List<int> correctAnswers, List<int> userAnswers) {
    if (correctAnswers.length != userAnswers.length) return false;
    final sortedCorrect = List<int>.from(correctAnswers)..sort();
    final sortedUser = List<int>.from(userAnswers)..sort();
    return sortedCorrect.toString() == sortedUser.toString();
  }
}
