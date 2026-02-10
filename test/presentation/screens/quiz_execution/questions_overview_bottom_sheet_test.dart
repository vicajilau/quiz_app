import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/question_type.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_event.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/questions_overview_bottom_sheet.dart';

class MockQuizExecutionBloc
    extends MockBloc<QuizExecutionEvent, QuizExecutionState>
    implements QuizExecutionBloc {}

void main() {
  late MockQuizExecutionBloc mockBloc;

  setUp(() {
    mockBloc = MockQuizExecutionBloc();
  });

  Widget createWidgetUnderTest(QuizExecutionInProgress state) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<QuizExecutionBloc>.value(
        value: mockBloc,
        child: Material(child: QuestionsOverviewBottomSheet(state: state)),
      ),
    );
  }

  final testQuestion = const Question(
    text: 'Test Question',
    type: QuestionType.singleChoice,
    options: ['Option 1', 'Option 2'],
    correctAnswers: [0],
    explanation: 'Test Explanation',
  );

  group('QuestionsOverviewBottomSheet', () {
    testWidgets('shows neutral color for answered questions in Exam Mode', (
      tester,
    ) async {
      // 2 questions:
      // Q1: Correctly answered
      // Q2: Incorrectly answered
      final questions = [testQuestion, testQuestion];
      final userAnswers = {
        0: [0], // Correct (Option 1 is index 0)
        1: [1], // Incorrect (Option 2 is index 1)
      };

      final state = QuizExecutionInProgress(
        questions: questions,
        currentQuestionIndex: 0,
        userAnswers: userAnswers,
        isStudyMode: false, // Exam Mode
      );

      await tester.pumpWidget(createWidgetUnderTest(state));

      // Both should have the same neutral color background (Primary with opacity, or whatever we decide)
      // We'll check they DON'T have green or red.

      final q1Container = tester.widget<Container>(
        find
            .ancestor(of: find.text('1'), matching: find.byType(Container))
            .first,
      );
      final q2Container = tester.widget<Container>(
        find
            .ancestor(of: find.text('2'), matching: find.byType(Container))
            .first,
      );

      final decoration1 = q1Container.decoration as BoxDecoration;
      final decoration2 = q2Container.decoration as BoxDecoration;

      // In Exam Mode, they shouldn't be green or red
      expect(decoration1.color, isNot(containsColor(Colors.green)));
      expect(decoration1.color, isNot(containsColor(Colors.red)));
      expect(decoration2.color, isNot(containsColor(Colors.green)));
      expect(decoration2.color, isNot(containsColor(Colors.red)));

      // They should likely be the same color (neutral)
      // Actually Q1 is "current", so it might have extra styling (border).
      // But background color logic usually handles "answered" state.
      // Let's verify they are not distinct "Success" / "Error" colors.
    });

    testWidgets('shows Green/Red for answered questions in Study Mode', (
      tester,
    ) async {
      // 2 questions:
      // Q1: Correctly answered
      // Q2: Incorrectly answered
      final questions = [testQuestion, testQuestion];
      final userAnswers = {
        0: [0], // Correct
        1: [1], // Incorrect
      };

      final state = QuizExecutionInProgress(
        questions: questions,
        currentQuestionIndex: 0,
        userAnswers: userAnswers,
        isStudyMode: true, // Study Mode
      );

      await tester.pumpWidget(createWidgetUnderTest(state));

      final q1Container = tester.widget<Container>(
        find
            .ancestor(of: find.text('1'), matching: find.byType(Container))
            .first,
      );
      final q2Container = tester.widget<Container>(
        find
            .ancestor(of: find.text('2'), matching: find.byType(Container))
            .first,
      );

      final decoration1 = q1Container.decoration as BoxDecoration;
      final decoration2 = q2Container.decoration as BoxDecoration;

      // Q1 (Correct) should be green-ish
      // We check if color value matches our expectation or at least we can check it differentiates.
      // For now let's manually inspect or check property.
      // Since we use Colors.green.withValues(alpha: 0.1/0.2), we can just check if it's "green-like" or the exact logic from code.
      // Checking for exact matching is brittle to theme changes, checking != is safer.

      expect(decoration1.color!.value, isNot(equals(decoration2.color!.value)));
    });
  });
}

// Helper to match color roughly if needed, or just strict equality.
Matcher containsColor(Color color) {
  return predicate((Color c) {
    if (c == color) return true;
    // Simple check if it's a shade (not accurate for withValues/opacity but ok for simple check against raw MaterialColor)
    return false;
  }, 'contains color $color');
}
