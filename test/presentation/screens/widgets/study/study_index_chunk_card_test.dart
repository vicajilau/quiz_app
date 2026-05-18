// Copyright (C) 2026 Víctor Carreras
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/domain/models/quiz/question.dart';
import 'package:quizdy/domain/models/quiz/question_type.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/domain/models/quiz/quiz_metadata.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/domain/models/quiz/source_reference.dart';
import 'package:quizdy/domain/models/srs/srs_metadata.dart';
import 'package:quizdy/data/repositories/srs/srs_repository.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_index_chunk_card.dart';
import 'package:quizdy/presentation/screens/widgets/study/widgets/study_section_mastery_indicator.dart';

class MockSrsRepository extends Mock implements SrsRepository {}

void main() {
  late MockSrsRepository mockSrsRepository;

  const testMetadata = QuizMetadata(
    title: 'Test Title',
    description: 'Test Desc',
    version: '1.0',
    author: 'Test Author',
  );

  final testChunk = const StudyChunk(
    id: 'test-chunk-1',
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

  final testQuestion1 = const Question(
    text: 'What is prime?',
    type: QuestionType.singleChoice,
    options: ['A', 'B'],
    correctAnswers: [0],
    explanation: '',
    studySectionId: 'test-chunk-1',
  );

  final testQuestion2 = const Question(
    text: 'What is composite?',
    type: QuestionType.singleChoice,
    options: ['A', 'B'],
    correctAnswers: [1],
    explanation: '',
    studySectionId: 'test-chunk-1',
  );

  Widget createWidgetUnderTest(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  setUp(() {
    mockSrsRepository = MockSrsRepository();

    final getIt = ServiceLocator.getIt;
    if (!getIt.isRegistered<SrsRepository>()) {
      getIt.registerSingleton<SrsRepository>(mockSrsRepository);
    }
  });

  tearDown(() {
    final getIt = ServiceLocator.getIt;
    if (getIt.isRegistered<SrsRepository>()) {
      getIt.unregister<SrsRepository>();
    }
  });

  group('StudySectionMasteryIndicator Tests', () {
    testWidgets('renders mastery percentage correctly', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          const StudySectionMasteryIndicator(
            percentage: 85.0,
            tooltipText: 'Mastery: 85%',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('85%'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('StudyIndexChunkCard Mastery Percentage Integration Tests', () {
    testWidgets('does NOT show mastery indicator when quizFile is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          Builder(
            builder: (context) => StudyIndexChunkCard(
              chunk: testChunk,
              index: 0,
              total: 1,
              localizations: AppLocalizations.of(context)!,
              onTap: () {},
              quizFile: null,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(StudySectionMasteryIndicator), findsNothing);
    });

    testWidgets(
      'does NOT show mastery indicator when no questions are linked',
      (tester) async {
        final quizFile = QuizFile(
          metadata: testMetadata,
          questions: [], // No questions linked
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            Builder(
              builder: (context) => StudyIndexChunkCard(
                chunk: testChunk,
                index: 0,
                total: 1,
                localizations: AppLocalizations.of(context)!,
                onTap: () {},
                quizFile: quizFile,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(StudySectionMasteryIndicator), findsNothing);
      },
    );

    testWidgets(
      'shows correct mastery indicator (e.g. 50%) based on SRS repetition score',
      (tester) async {
        final quizFile = QuizFile(
          metadata: testMetadata,
          questions: [testQuestion1, testQuestion2],
        );

        // Mocking SRS answers: Question 1 correct (repetition > 0), Question 2 unanswered (timesCorrect = 0, timesIncorrect = 0)
        final identity1 = testQuestion1.identityHash.toString();
        final identity2 = testQuestion2.identityHash.toString();
        final fileId = quizFile.filePath ?? quizFile.metadata.title;

        when(
          () => mockSrsRepository.getMetadataForQuestion(identity1, fileId),
        ).thenReturn(
          SrsMetadata(
            questionIdentity: identity1,
            fileIdentifier: fileId,
            repetition: 2,
            timesCorrect: 2,
          ),
        );

        when(
          () => mockSrsRepository.getMetadataForQuestion(identity2, fileId),
        ).thenReturn(
          SrsMetadata(
            questionIdentity: identity2,
            fileIdentifier: fileId,
            repetition: 0,
            timesCorrect: 0,
          ),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            Builder(
              builder: (context) => StudyIndexChunkCard(
                chunk: testChunk,
                index: 0,
                total: 1,
                localizations: AppLocalizations.of(context)!,
                onTap: () {},
                quizFile: quizFile,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(StudySectionMasteryIndicator), findsOneWidget);
        expect(find.text('50%'), findsOneWidget);
      },
    );

    testWidgets(
      'shows correct mastery indicator (e.g. 100%) when all answers correct',
      (tester) async {
        final quizFile = QuizFile(
          metadata: testMetadata,
          questions: [testQuestion1, testQuestion2],
        );

        final identity1 = testQuestion1.identityHash.toString();
        final identity2 = testQuestion2.identityHash.toString();
        final fileId = quizFile.filePath ?? quizFile.metadata.title;

        when(
          () => mockSrsRepository.getMetadataForQuestion(identity1, fileId),
        ).thenReturn(
          SrsMetadata(
            questionIdentity: identity1,
            fileIdentifier: fileId,
            repetition: 3,
            timesCorrect: 3,
          ),
        );

        when(
          () => mockSrsRepository.getMetadataForQuestion(identity2, fileId),
        ).thenReturn(
          SrsMetadata(
            questionIdentity: identity2,
            fileIdentifier: fileId,
            repetition: 1,
            timesCorrect: 1,
          ),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            Builder(
              builder: (context) => StudyIndexChunkCard(
                chunk: testChunk,
                index: 0,
                total: 1,
                localizations: AppLocalizations.of(context)!,
                onTap: () {},
                quizFile: quizFile,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(StudySectionMasteryIndicator), findsOneWidget);
        expect(find.text('100%'), findsOneWidget);
      },
    );
  });
}
