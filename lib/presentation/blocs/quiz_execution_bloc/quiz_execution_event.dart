import '../../../domain/models/quiz/question.dart';

/// Abstract class representing the base event for quiz execution operations.
abstract class QuizExecutionEvent {}

/// Event triggered when the quiz execution starts.
class QuizExecutionStarted extends QuizExecutionEvent {
  final List<Question> questions;

  QuizExecutionStarted(this.questions);
}

/// Event triggered when a user selects an answer.
class AnswerSelected extends QuizExecutionEvent {
  final int optionIndex;
  final bool isSelected;

  AnswerSelected(this.optionIndex, this.isSelected);
}

/// Event triggered when a user changes essay answer text.
class EssayAnswerChanged extends QuizExecutionEvent {
  final String text;

  EssayAnswerChanged(this.text);
}

/// Event triggered when the user wants to go to the next question.
class NextQuestionRequested extends QuizExecutionEvent {}

/// Event triggered when the user wants to go to the previous question.
class PreviousQuestionRequested extends QuizExecutionEvent {}

/// Event triggered when the user submits the quiz.
class QuizSubmitted extends QuizExecutionEvent {}

/// Event triggered when the user wants to restart the quiz.
class QuizRestarted extends QuizExecutionEvent {}
