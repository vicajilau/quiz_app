// Copyright (C) 2026 Víctor Carreras
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/domain/models/quiz/question.dart';
import 'package:quizdy/domain/models/quiz/question_type.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/domain/models/quiz/quiz_metadata.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/domain/models/quiz/source_reference.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_content_view.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';

void main() {
  const testMetadata = QuizMetadata(
    title: 'Test Title',
    description: 'Test Desc',
    version: '1.0',
    author: 'Test Author',
  );

  final testChunk = const StudyChunk(
    id: 'test-chunk-id-1',
    chunkIndex: 0,
    status: StudyChunkState.completed,
    sourceReference: SourceReference(
      documentId: 'doc-1',
      startPage: 1,
      endPage: 1,
      startOffset: 0,
      endOffset: 10,
      blockType: 'Test Section',
    ),
  );

  final testQuestion = const Question(
    text: 'What is prime?',
    type: QuestionType.singleChoice,
    options: ['A', 'B'],
    correctAnswers: [0],
    explanation: '',
    studySectionId: 'test-chunk-id-1',
  );

  Widget createWidgetUnderTest(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  group('StudyContentView Practice Banner Tests', () {
    testWidgets(
      'renders the premium practice banner card when there are linked questions',
      (tester) async {
        final quizFile = QuizFile(
          metadata: testMetadata,
          questions: [testQuestion],
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            Builder(
              builder: (context) => StudyContentView(
                currentChunk: testChunk,
                currentChunkIndex: 0,
                localizations: AppLocalizations.of(context)!,
                quizFile: quizFile,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify that the practice banner title and count subtitle are visible
        expect(find.text('Practice Section Questions'), findsOneWidget);
        expect(find.textContaining('1 linked question'), findsOneWidget);
        expect(find.byType(QuizdyButton), findsOneWidget);
        expect(find.text('Test your knowledge'), findsOneWidget);
      },
    );

    testWidgets(
      'does NOT render the practice banner when there are no linked questions',
      (tester) async {
        final quizFile = QuizFile(
          metadata: testMetadata,
          questions: [], // No linked questions
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            Builder(
              builder: (context) => StudyContentView(
                currentChunk: testChunk,
                currentChunkIndex: 0,
                localizations: AppLocalizations.of(context)!,
                quizFile: quizFile,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify that the banner is not present
        expect(find.text('Practice Section Questions'), findsNothing);
        expect(find.text('Test your knowledge'), findsNothing);
      },
    );
  });
}
