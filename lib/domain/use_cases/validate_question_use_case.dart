import 'package:quiz_app/domain/models/custom_exceptions/question_error.dart';
import 'package:quiz_app/domain/models/custom_exceptions/question_error_type.dart';
import 'package:quiz_app/domain/models/quiz/quiz_file.dart';

class ValidateQuestionUseCase {
  /// Validate a question for a quiz
  static QuestionError validateQuestion(
    String questionText,
    List<String> options,
    List<int> correctAnswers,
    int? questionPosition,
    QuizFile quizFile,
  ) {
    final text = questionText.trim();

    // Validate question text
    if (text.isEmpty) {
      return QuestionError(
        errorType: QuestionErrorType.emptyText,
        param1: questionPosition,
      );
    }

    // Check for duplicate question text
    if (quizFile.questions.any((q) {
      final currentIndex = quizFile.questions.indexOf(q);
      return q.text.trim() == text &&
          (questionPosition == null || currentIndex != questionPosition);
    })) {
      return QuestionError(errorType: QuestionErrorType.duplicatedText);
    }

    // Validate options
    if (options.length < 2) {
      return QuestionError(
        errorType: QuestionErrorType.insufficientOptions,
        param1: text,
      );
    }

    // Check for empty options
    for (int i = 0; i < options.length; i++) {
      if (options[i].trim().isEmpty) {
        return QuestionError(
          errorType: QuestionErrorType.emptyOption,
          param1: i,
          param2: text,
        );
      }
    }

    // Validate correct answers
    if (correctAnswers.isEmpty ||
        correctAnswers.any((index) => index < 0 || index >= options.length)) {
      return QuestionError(
        errorType: QuestionErrorType.invalidCorrectAnswers,
        param1: text,
      );
    }

    return QuestionError.success();
  }
}
