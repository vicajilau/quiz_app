import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/core/theme/app_theme.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/question_type.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_event.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/quiz_navigation_buttons.dart';

class MockQuizExecutionBloc
    extends MockBloc<QuizExecutionEvent, QuizExecutionState>
    implements QuizExecutionBloc {}

class FakeQuizExecutionEvent extends Fake implements QuizExecutionEvent {}

void main() {
  late MockQuizExecutionBloc mockBloc;

  setUp(() {
    mockBloc = MockQuizExecutionBloc();
    registerFallbackValue(FakeQuizExecutionEvent());
  });

  Widget createWidgetUnderTest(QuizExecutionInProgress state) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<QuizExecutionBloc>.value(
        value: mockBloc,
        child: Scaffold(
          body: QuizNavigationButtons(
            state: state,
            isStudyMode: state.isStudyMode,
          ),
        ),
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

  group('QuizNavigationButtons - Exam Mode', () {
    testWidgets('shows Skip button when question is NOT answered', (
      tester,
    ) async {
      final state = QuizExecutionInProgress(
        questions: [testQuestion, testQuestion],
        currentQuestionIndex: 0,
        userAnswers: {},
        isStudyMode: false,
      );

      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      // Verify "Skip" icon first (easier to match than text if localization issues)
      expect(
        find.byIcon(Icons.skip_next),
        findsOneWidget,
        reason: 'Skip icon not found',
      );
      expect(find.text('Skip'), findsOneWidget, reason: 'Skip text not found');

      // Verify functionality
      await tester.tap(find.text('Skip'));
      verify(
        () => mockBloc.add(any(that: isA<NextQuestionRequested>())),
      ).called(1);
    });

    testWidgets('shows Next button when question IS answered', (tester) async {
      final state = QuizExecutionInProgress(
        questions: [testQuestion, testQuestion],
        currentQuestionIndex: 0,
        userAnswers: {
          0: [0],
        },
        isStudyMode: false,
      );

      expect(
        state.hasCurrentQuestionAnswered,
        isTrue,
        reason: 'State should be answered',
      );

      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.pumpAndSettle();

      // Verify "Next" icon first
      expect(
        find.byIcon(Icons.chevron_right),
        findsOneWidget,
        reason: 'Next icon not found',
      );
      expect(find.text('Next'), findsOneWidget, reason: 'Next text not found');

      // Verify functionality
      await tester.tap(find.text('Next'));
      verify(
        () => mockBloc.add(any(that: isA<NextQuestionRequested>())),
      ).called(1);
    });
  });
}
