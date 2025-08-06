import 'dart:math';
import '../../domain/models/quiz/question.dart';
import '../../domain/models/quiz/question_order.dart';

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

  /// Randomizes the order of answer options for a question
  ///
  /// - [question]: The question whose options should be randomized
  /// - Returns: A new Question with randomized options
  static Question randomizeAnswerOptions(Question question) {
    // Create a copy of the question with shuffled options
    final shuffledOptions = List<String>.from(question.options);
    shuffledOptions.shuffle(_random);

    // Create mapping from old index to new index
    final indexMapping = <int, int>{};
    for (int i = 0; i < question.options.length; i++) {
      final originalOption = question.options[i];
      final newIndex = shuffledOptions.indexOf(originalOption);
      indexMapping[i] = newIndex;
    }

    // Update correct answers based on the new positions
    final newCorrectAnswers = question.correctAnswers.map((oldIndex) {
      return indexMapping[oldIndex] ?? oldIndex;
    }).toList();

    return Question(
      type: question.type,
      text: question.text,
      image: question.image,
      options: shuffledOptions,
      correctAnswers: newCorrectAnswers,
      explanation: question.explanation,
    );
  }

  /// Randomizes answer options for a list of questions
  ///
  /// - [questions]: The list of questions to process
  /// - Returns: A new list of questions with randomized options
  static List<Question> randomizeQuestionsAnswers(List<Question> questions) {
    return questions.map(randomizeAnswerOptions).toList();
  }
}
