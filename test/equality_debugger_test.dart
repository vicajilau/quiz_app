import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/domain/models/quiz/quiz_file.dart';
import 'package:quiz_app/domain/models/quiz/quiz_metadata.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/question_type.dart';

void main() {
  test('QuizFile deepCopy equality test', () {
    final metadata = const QuizMetadata(
      title: 'Test Quiz',
      description: 'Description',
      version: '1.0',
      author: 'Author',
    );

    final question = const Question(
      type: QuestionType.multipleChoice,
      text: 'Question 1',
      options: ['A', 'B'],
      correctAnswers: [0],
      explanation: 'Exp',
      isEnabled: true,
    );

    final file = QuizFile(
      metadata: metadata,
      questions: [question],
      filePath: '/path/to/file.quiz',
    );

    final copy = file.deepCopy();

    expect(
      file == copy,
      isTrue,
      reason: 'File and its deep copy should be equal',
    );
    expect(
      file.hashCode == copy.hashCode,
      isTrue,
      reason: 'HashCodes should be equal',
    );

    // Test with modified copy
    final modified = copy.copyWith(filePath: '/path/to/other.quiz');
    expect(
      file == modified,
      isFalse,
      reason: 'Modified file should not be equal',
    );
  });

  test('Question equality test', () {
    final q1 = const Question(
      type: QuestionType.multipleChoice,
      text: 'Q',
      options: ['A'],
      correctAnswers: [0],
      explanation: 'E',
    );

    final q2 = const Question(
      type: QuestionType.multipleChoice,
      text: 'Q',
      options: ['A'],
      correctAnswers: [0],
      explanation: 'E',
    );

    expect(q1 == q2, isTrue);
    expect(q1.hashCode == q2.hashCode, isTrue);
  });
}
