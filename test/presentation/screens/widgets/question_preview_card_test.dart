// Copyright (C) 2026 Víctor Carreras
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/domain/models/quiz/question.dart';
import 'package:quizdy/domain/models/quiz/question_type.dart';
import 'package:quizdy/domain/use_cases/check_file_changes_use_case.dart';
import 'package:quizdy/presentation/screens/widgets/question_preview_card.dart';

class MockCheckFileChangesUseCase extends Mock
    implements CheckFileChangesUseCase {}

void main() {
  late MockCheckFileChangesUseCase mockCheckFileChangesUseCase;

  setUp(() {
    mockCheckFileChangesUseCase = MockCheckFileChangesUseCase();
    registerFallbackValue(
      const Question(
        text: '',
        type: QuestionType.singleChoice,
        options: [],
        correctAnswers: [],
        explanation: '',
      ),
    );
    when(
      () => mockCheckFileChangesUseCase.isQuestionNew(any(), any()),
    ).thenReturn(false);
    when(
      () => mockCheckFileChangesUseCase.isQuestionModified(any(), any()),
    ).thenReturn(false);

    final getIt = ServiceLocator.getIt;
    if (!getIt.isRegistered<CheckFileChangesUseCase>()) {
      getIt.registerSingleton<CheckFileChangesUseCase>(
        mockCheckFileChangesUseCase,
      );
    }
  });

  tearDown(() {
    final getIt = ServiceLocator.getIt;
    if (getIt.isRegistered<CheckFileChangesUseCase>()) {
      getIt.unregister<CheckFileChangesUseCase>();
    }
  });

  const testQuestion = Question(
    text: 'What is prime?',
    type: QuestionType.singleChoice,
    options: ['A', 'B'],
    correctAnswers: [0],
    explanation: 'Explanation text here',
  );

  Widget createWidgetUnderTest({required Widget child}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  group('QuestionPreviewCard Warnings', () {
    testWidgets('displays warning message when question is unlinked', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          child: QuestionPreviewCard(
            question: testQuestion,
            index: 0,
            onEdit: () {},
            onDelete: () {},
            onToggle: () {},
            isUnlinked: true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find the unlinked study section warning
      expect(find.text('Not linked to a study section'), findsOneWidget);
    });

    testWidgets(
      'does NOT display warning message when question is NOT unlinked',
      (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            child: QuestionPreviewCard(
              question: testQuestion,
              index: 0,
              onEdit: () {},
              onDelete: () {},
              onToggle: () {},
              isUnlinked: false,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should NOT find the unlinked study section warning
        expect(find.text('Not linked to a study section'), findsNothing);
      },
    );
  });
}
