import 'dart:math';
import '../models/quiz/question.dart';

/// Service to handle quiz question selection and randomization
class QuizService {
  static final Random _random = Random();

  /// Selects a random subset of questions from the provided list
  ///
  /// - [allQuestions]: The complete list of questions
  /// - [count]: The number of questions to select
  /// - Returns: A randomized list of the specified number of questions
  ///
  /// If count > allQuestions.length, questions will be repeated to reach the desired count
  /// If count <= allQuestions.length, a random subset will be selected
  static List<Question> selectRandomQuestions(
    List<Question> allQuestions,
    int count,
  ) {
    if (allQuestions.isEmpty || count <= 0) {
      return [];
    }

    final result = <Question>[];
    final shuffledQuestions = List<Question>.from(allQuestions);
    shuffledQuestions.shuffle(_random);

    if (count <= allQuestions.length) {
      // Take the first 'count' questions from the shuffled list
      return shuffledQuestions.take(count).toList();
    } else {
      // Need to repeat questions to reach the desired count
      int remainingCount = count;

      while (remainingCount > 0) {
        final questionsToAdd = shuffledQuestions
            .take(
              remainingCount > shuffledQuestions.length
                  ? shuffledQuestions.length
                  : remainingCount,
            )
            .toList();

        result.addAll(questionsToAdd);
        remainingCount -= questionsToAdd.length;

        // Shuffle again for the next iteration to avoid patterns
        if (remainingCount > 0) {
          shuffledQuestions.shuffle(_random);
        }
      }

      return result;
    }
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
