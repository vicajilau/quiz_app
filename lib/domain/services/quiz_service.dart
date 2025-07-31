import 'dart:math';
import '../models/quiz/question.dart';
import '../models/quiz/question_order.dart';

/// Service to handle quiz question selection and randomization
class QuizService {
  static final Random _random = Random();

  /// Selects questions from the provided list based on count and order preference
  ///
  /// - [allQuestions]: The complete list of questions
  /// - [count]: The number of questions to select
  /// - [order]: The order preference for questions (default: random)
  /// - Returns: A list of questions in the specified order
  ///
  /// If count > allQuestions.length, questions will be repeated to reach the desired count
  /// If count <= allQuestions.length, a subset will be selected
  static List<Question> selectQuestions(
    List<Question> allQuestions,
    int count, {
    QuestionOrder order = QuestionOrder.random,
  }) {
    if (allQuestions.isEmpty || count <= 0) {
      return [];
    }

    List<Question> orderedQuestions;

    switch (order) {
      case QuestionOrder.ascending:
        orderedQuestions = List<Question>.from(allQuestions);
        break;
      case QuestionOrder.descending:
        orderedQuestions = List<Question>.from(allQuestions.reversed);
        break;
      case QuestionOrder.random:
        orderedQuestions = List<Question>.from(allQuestions);
        orderedQuestions.shuffle(_random);
        break;
    }

    final result = <Question>[];

    if (count <= orderedQuestions.length) {
      // Take the first 'count' questions from the ordered list
      return orderedQuestions.take(count).toList();
    } else {
      // Need to repeat questions to reach the desired count
      int remainingCount = count;

      while (remainingCount > 0) {
        final questionsToAdd = orderedQuestions
            .take(
              remainingCount > orderedQuestions.length
                  ? orderedQuestions.length
                  : remainingCount,
            )
            .toList();

        result.addAll(questionsToAdd);
        remainingCount -= questionsToAdd.length;

        // For random order, shuffle again for the next iteration to avoid patterns
        if (remainingCount > 0 && order == QuestionOrder.random) {
          orderedQuestions.shuffle(_random);
        }
      }

      return result;
    }
  }

  /// Legacy method for backward compatibility
  ///
  /// - [allQuestions]: The complete list of questions
  /// - [count]: The number of questions to select
  /// - Returns: A randomized list of the specified number of questions
  static List<Question> selectRandomQuestions(
    List<Question> allQuestions,
    int count,
  ) {
    return selectQuestions(allQuestions, count, order: QuestionOrder.random);
  }

  /// Shuffles a list of questions randomly
  ///
  /// - [questions]: The list of questions to shuffle
  /// - Returns: A new shuffled list of questions
  static List<Question> shuffleQuestions(List<Question> questions) {
    final shuffledQuestions = List<Question>.from(questions);
    shuffledQuestions.shuffle(_random);
    return shuffledQuestions;
  }
}
