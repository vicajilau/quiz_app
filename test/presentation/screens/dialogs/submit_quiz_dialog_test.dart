import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_app/core/theme/app_theme.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/question_type.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_event.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'package:quiz_app/presentation/screens/dialogs/submit_quiz_dialog.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';

class MockQuizExecutionBloc
    extends MockBloc<QuizExecutionEvent, QuizExecutionState>
    implements QuizExecutionBloc {}

void main() {
  late MockQuizExecutionBloc mockBloc;

  setUp(() {
    mockBloc = MockQuizExecutionBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => SubmitQuizDialog.show(context, mockBloc),
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      ),
    );
  }

  final testQuestion = const Question(
    text: 'Test Question',
    type: QuestionType.singleChoice,
    options: ['Option A', 'Option B'],
    correctAnswers: [0],
    explanation: 'Explanation',
  );

  testWidgets('shows standard confirmation when all questions are answered', (
    tester,
  ) async {
    final state = QuizExecutionInProgress(
      questions: [testQuestion],
      currentQuestionIndex: 0,
      userAnswers: {
        0: [0],
      }, // Answered
      isStudyMode: false,
    );
    when(() => mockBloc.state).thenReturn(state);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Are you sure you want to finish the quiz? You won\'t be able to change your answers afterwards.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('unanswered'), findsNothing);
  });

  testWidgets('shows warning when there are unanswered questions', (
    tester,
  ) async {
    final state = QuizExecutionInProgress(
      questions: [testQuestion, testQuestion], // 2 questions
      currentQuestionIndex: 0,
      userAnswers: {
        0: [0],
      }, // Only 1 answered
      isStudyMode: false,
    );
    when(() => mockBloc.state).thenReturn(state);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // "You have 1 unanswered question. Are you sure..."
    expect(
      find.textContaining('You have 1 unanswered question'),
      findsOneWidget,
    );
  });

  testWidgets('shows warning with plural when multiple unanswered questions', (
    tester,
  ) async {
    final state = QuizExecutionInProgress(
      questions: [testQuestion, testQuestion, testQuestion], // 3 questions
      currentQuestionIndex: 0,
      userAnswers: {}, // 0 answered
      isStudyMode: false,
    );
    when(() => mockBloc.state).thenReturn(state);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // "You have 3 unanswered questions. Are you sure..."
    expect(
      find.textContaining('You have 3 unanswered questions'),
      findsOneWidget,
    );
  });
}
