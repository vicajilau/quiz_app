import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/question_type.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_event.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/quiz_question_options.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/widgets/question_option_tile.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class FakeQuizExecutionBloc extends Bloc<QuizExecutionEvent, QuizExecutionState>
    implements QuizExecutionBloc {
  FakeQuizExecutionBloc(super.initialState);
}

void main() {
  testWidgets('QuizQuestionOptions renders options correctly', (
    WidgetTester tester,
  ) async {
    // Setup data
    const question = Question(
      type: QuestionType.singleChoice,
      text: 'Test Question',
      options: ['Option A', 'Option B'],
      correctAnswers: [0],
      explanation: 'Explanation',
    );

    final state = QuizExecutionInProgress(
      questions: [question],
      currentQuestionIndex: 0,
      userAnswers: {},
    );

    final bloc = FakeQuizExecutionBloc(state);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: BlocProvider<QuizExecutionBloc>.value(
          value: bloc,
          child: Material(child: QuizQuestionOptions(state: state)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify QuestionOptionTile are present
    expect(find.byType(QuestionOptionTile), findsNWidgets(2));
    expect(find.text('Option A'), findsOneWidget);
    expect(find.text('Option B'), findsOneWidget);
  });
}
