import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/question_type.dart';
import 'package:quiz_app/domain/models/quiz/quiz_config.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_event.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';

void main() {
  group('QuizExecutionBloc Scoring', () {
    late QuizExecutionBloc quizExecutionBloc;

    setUp(() {
      quizExecutionBloc = QuizExecutionBloc();
    });

    tearDown(() {
      quizExecutionBloc.close();
    });

    final testQuestion = const Question(
      text: 'Question 1',
      type: QuestionType.singleChoice,
      options: ['A', 'B'],
      correctAnswers: [0],
      explanation: 'Explanation',
    );

    blocTest<QuizExecutionBloc, QuizExecutionState>(
      'calculates score correctly with NO penalty',
      build: () => quizExecutionBloc,
      act: (bloc) {
        bloc.add(
          QuizExecutionStarted(
            [testQuestion],
            quizConfig: const QuizConfig(
              questionCount: 1,
              isStudyMode: false,
              subtractPoints: false,
            ),
          ),
        );
        // Answer incorrectly
        bloc.add(AnswerSelected(1, true)); // Option B (index 1) is wrong
        bloc.add(QuizSubmitted());
      },
      expect: () => [
        isA<QuizExecutionInProgress>(),
        isA<QuizExecutionInProgress>(), // After AnswerSelected
        isA<QuizExecutionCompleted>().having((s) => s.score, 'score', 0.0),
      ],
    );

    blocTest<QuizExecutionBloc, QuizExecutionState>(
      'calculates score correctly WITH penalty',
      build: () => quizExecutionBloc,
      act: (bloc) {
        bloc.add(
          QuizExecutionStarted(
            [testQuestion],
            quizConfig: const QuizConfig(
              questionCount: 1,
              isStudyMode: false,
              subtractPoints: true,
              penaltyAmount: 0.5,
            ),
          ),
        );
        // Answer incorrectly
        bloc.add(AnswerSelected(1, true)); // Option B (index 1) is wrong
        bloc.add(QuizSubmitted());
      },
      expect: () => [
        isA<QuizExecutionInProgress>(),
        isA<QuizExecutionInProgress>(),
        isA<QuizExecutionCompleted>().having(
          (s) => s.score,
          'score',
          -50.0,
        ), // -0.5 / 1 * 100 = -50%
      ],
    );

    blocTest<QuizExecutionBloc, QuizExecutionState>(
      'calculates score correctly with mixed results and penalty',
      build: () => quizExecutionBloc,
      act: (bloc) {
        bloc.add(
          QuizExecutionStarted(
            [testQuestion, testQuestion], // 2 questions
            quizConfig: const QuizConfig(
              questionCount: 2,
              isStudyMode: false,
              subtractPoints: true,
              penaltyAmount: 0.5,
            ),
          ),
        );
        // Question 1: Correct
        bloc.add(AnswerSelected(0, true));
        // Question 2: Incorrect
        // We probably need to move to next question first?
        // Or if we just add answer, does it affect current question?
        // Wait, AnswerSelected takes optionIndex. It operates on `currentQuestionIndex`.
        // So I must move to next question!
        bloc.add(NextQuestionRequested());
        bloc.add(AnswerSelected(1, true));
        bloc.add(QuizSubmitted());
      },
      expect: () => [
        isA<QuizExecutionInProgress>(),
        isA<QuizExecutionInProgress>(), // Answer 1
        isA<QuizExecutionInProgress>(), // Next Question
        isA<QuizExecutionInProgress>(), // Answer 2
        isA<QuizExecutionCompleted>().having(
          (s) => s.score,
          'score',
          25.0,
        ), // (1 - 0.5) / 2 * 100 = 0.5 / 2 * 100 = 25%
      ],
    );

    blocTest<QuizExecutionBloc, QuizExecutionState>(
      'calculates score correctly with unanswered questions (no penalty for unanswered)',
      build: () => quizExecutionBloc,
      act: (bloc) {
        bloc.add(
          QuizExecutionStarted(
            [testQuestion, testQuestion], // 2 questions
            quizConfig: const QuizConfig(
              questionCount: 2,
              isStudyMode: false,
              subtractPoints: true,
              penaltyAmount: 0.5,
            ),
          ),
        );
        // Question 1: Incorrect
        bloc.add(AnswerSelected(1, true));
        // Question 2: Unanswered
        // Just submit. But wait, if we are at Q1, and submit, does it count Q2?
        // Yes, the loop iterates over all questions.
        bloc.add(QuizSubmitted());
      },
      expect: () => [
        isA<QuizExecutionInProgress>(),
        isA<QuizExecutionInProgress>(), // Answer 1
        isA<QuizExecutionCompleted>().having(
          (s) => s.score,
          'score',
          -25.0,
        ), // (0 - 0.5) / 2 * 100 = -25%
      ],
    );
  });
}
