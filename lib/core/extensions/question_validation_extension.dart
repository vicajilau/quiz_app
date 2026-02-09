import 'package:collection/collection.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/question_type.dart';

extension QuestionValidationExtension on Question {
  /// Checks if the provided user answers are correct for this question.
  ///
  /// - [userAnswers]: A list of indices representing the user's selected options.
  ///
  /// Returns `true` if the answers are correct, `false` otherwise.
  /// For Essay questions, this always returns `true` (as they need manual grading,
  /// but we treat them as "complete/correct" for simple status checks usually,
  /// though typically essay correctness is a different concept).
  /// However, for the purpose of "Green/Red" status map, we might want to consider
  /// what "Correct" means for Essay.
  /// Based on `QuizExecutionState._isAnswerCorrect`:
  /// "Essay questions are always considered "correct" since they require manual grading"
  /// So we will follow that logic.
  bool isAnswerCorrect(List<int> userAnswers) {
    if (type == QuestionType.essay) {
      // Essay questions are effectively "always correct" in auto-grading context
      // until manual grading is implemented.
      // But usually we only check if it is ANSWERED.
      // If we are strictly checking "is the answer content correct", for essay it's ambiguous.
      // But if this is used for "Green/Red" map:
      // If answered -> Green? Or just Blue?
      // The user asked for "Green if correct, Red if incorrect".
      // If essay is "always correct", it will be Green if answered.
      return true;
    }

    // For other types, compare correctAnswers with userAnswers
    final sortedCorrect = List<int>.from(correctAnswers)..sort();
    final sortedUser = List<int>.from(userAnswers)..sort();
    return const ListEquality().equals(sortedCorrect, sortedUser);
  }
}
