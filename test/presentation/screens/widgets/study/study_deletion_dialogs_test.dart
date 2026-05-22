// Copyright (C) 2026 Víctor Carreras
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:quizdy/domain/use_cases/check_file_changes_use_case.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_bloc.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_event.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_state.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_bloc.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_event.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_state.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_bottom_navigation.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_index_view.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_index_chunk_card.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';
import 'package:quizdy/data/repositories/srs/srs_repository.dart';
import 'package:quizdy/domain/models/srs/srs_metadata.dart';

class MockFileBloc extends MockBloc<FileEvent, FileState> implements FileBloc {}

class MockStudyExecutionBloc
    extends MockBloc<StudyExecutionEvent, StudyExecutionState>
    implements StudyExecutionBloc {}

class MockCheckFileChangesUseCase extends Mock
    implements CheckFileChangesUseCase {}

class MockSrsRepository extends Mock implements SrsRepository {}

void main() {
  late MockFileBloc mockFileBloc;
  late MockStudyExecutionBloc mockStudyBloc;
  late MockCheckFileChangesUseCase mockCheckFileChangesUseCase;
  late MockSrsRepository mockSrsRepository;

  setUp(() {
    mockFileBloc = MockFileBloc();
    mockStudyBloc = MockStudyExecutionBloc();
    mockCheckFileChangesUseCase = MockCheckFileChangesUseCase();

    // Set up standard mock returns
    registerFallbackValue(
      QuizFile(
        metadata: const QuizMetadata(
          title: '',
          description: '',
          version: '',
          author: '',
        ),
        questions: [],
      ),
    );
    registerFallbackValue(
      const StudyChunk(
        id: '',
        chunkIndex: 0,
        status: StudyChunkState.created,
        sourceReference: SourceReference(
          documentId: '',
          startPage: 0,
          endPage: 0,
          startOffset: 0,
          endOffset: 0,
          blockType: '',
        ),
      ),
    );
    when(() => mockCheckFileChangesUseCase.execute(any())).thenReturn(false);
    when(
      () => mockCheckFileChangesUseCase.isStudyChunkNew(any(), any()),
    ).thenReturn(false);
    when(
      () => mockCheckFileChangesUseCase.isStudyChunkModified(any(), any()),
    ).thenReturn(false);

    mockSrsRepository = MockSrsRepository();
    when(
      () => mockSrsRepository.getMetadataForQuestion(any(), any()),
    ).thenReturn(
      SrsMetadata(
        questionIdentity: '',
        fileIdentifier: '',
        repetition: 0,
        timesCorrect: 0,
      ),
    );

    // Register singleton Mock in GetIt
    final getIt = ServiceLocator.getIt;
    if (!getIt.isRegistered<CheckFileChangesUseCase>()) {
      getIt.registerSingleton<CheckFileChangesUseCase>(
        mockCheckFileChangesUseCase,
      );
    }
    if (!getIt.isRegistered<SrsRepository>()) {
      getIt.registerSingleton<SrsRepository>(mockSrsRepository);
    }
  });

  tearDown(() {
    final getIt = ServiceLocator.getIt;
    if (getIt.isRegistered<CheckFileChangesUseCase>()) {
      getIt.unregister<CheckFileChangesUseCase>();
    }
    if (getIt.isRegistered<SrsRepository>()) {
      getIt.unregister<SrsRepository>();
    }
  });

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
      home: MultiBlocProvider(
        providers: [
          BlocProvider<FileBloc>.value(value: mockFileBloc),
          BlocProvider<StudyExecutionBloc>.value(value: mockStudyBloc),
        ],
        child: MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: SizedBox(width: 400, child: Scaffold(body: child)),
        ),
      ),
    );
  }

  group('StudyIndexView Deletion Dialogs', () {
    testWidgets(
      'shows warning dialog when deleting a section WITH associated questions',
      (tester) async {
        // Mock FileLoaded state with a linked question
        final fileState = FileLoaded(
          QuizFile(
            metadata: testMetadata,
            study: null,
            questions: [testQuestion],
          ),
        );
        when(() => mockFileBloc.state).thenReturn(fileState);

        final studyState = StudyExecutionState(
          chunks: [testChunk],
          currentChunkIndex: 0,
          processedChunks: 1,
          progressPercentage: 100,
          isIndexMode: true,
        );
        when(() => mockStudyBloc.state).thenReturn(studyState);

        await tester.pumpWidget(
          createWidgetUnderTest(
            Builder(
              builder: (context) => StudyIndexView(
                state: studyState,
                localizations: AppLocalizations.of(context)!,
              ),
            ),
          ),
        );

        // Directly trigger onDelete callback from the StudyIndexChunkCard widget to bypass hover dependency
        final cardFinder = find.byType(StudyIndexChunkCard);
        expect(cardFinder, findsOneWidget);
        final StudyIndexChunkCard cardWidget = tester.widget(cardFinder);
        expect(cardWidget.onDelete, isNotNull);
        cardWidget.onDelete!();
        await tester.pumpAndSettle();

        // Check for specialized warning
        expect(
          find.textContaining('This section has associated questions.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'shows standard confirmation dialog when deleting a section WITHOUT associated questions',
      (tester) async {
        // Mock FileLoaded state with NO linked questions
        final fileState = FileLoaded(
          QuizFile(metadata: testMetadata, study: null, questions: []),
        );
        when(() => mockFileBloc.state).thenReturn(fileState);

        final studyState = StudyExecutionState(
          chunks: [testChunk],
          currentChunkIndex: 0,
          processedChunks: 1,
          progressPercentage: 100,
          isIndexMode: true,
        );
        when(() => mockStudyBloc.state).thenReturn(studyState);

        await tester.pumpWidget(
          createWidgetUnderTest(
            Builder(
              builder: (context) => StudyIndexView(
                state: studyState,
                localizations: AppLocalizations.of(context)!,
              ),
            ),
          ),
        );

        final cardFinder = find.byType(StudyIndexChunkCard);
        expect(cardFinder, findsOneWidget);
        final StudyIndexChunkCard cardWidget = tester.widget(cardFinder);
        expect(cardWidget.onDelete, isNotNull);
        cardWidget.onDelete!();
        await tester.pumpAndSettle();

        // Check for standard confirmation message
        expect(
          find.textContaining('Are you sure you want to delete'),
          findsOneWidget,
        );
        // Make sure the specialized warning is NOT present
        expect(
          find.textContaining('This section has associated questions.'),
          findsNothing,
        );
      },
    );
  });

  group('StudyBottomNavigation Bulk Deletion Dialogs', () {
    testWidgets(
      'shows bulk deletion warning dialog when selected sections have associated questions',
      (tester) async {
        // Mock FileLoaded state with a linked question
        final fileState = FileLoaded(
          QuizFile(
            metadata: testMetadata,
            study: null,
            questions: [testQuestion],
          ),
        );
        when(() => mockFileBloc.state).thenReturn(fileState);

        // Mock StudyExecutionState in selection mode with selected chunk
        final studyState = StudyExecutionState(
          chunks: [testChunk],
          currentChunkIndex: 0,
          processedChunks: 1,
          progressPercentage: 100,
          isIndexMode: true,
          isSelectionMode: true,
          selectedIndices: {0},
        );
        when(() => mockStudyBloc.state).thenReturn(studyState);

        await tester.pumpWidget(
          createWidgetUnderTest(
            StudyBottomNavigation(
              quizFile: fileState.quizFile,
              onSave: () {},
              onImport: () {},
              onAddChunk: () {},
              onGenerateAI: () {},
            ),
          ),
        );

        // Find the bulk delete button by checking for a QuizdyButton with a title starting with 'Delete'
        final deleteBtnFinder = find.byWidgetPredicate(
          (widget) =>
              widget is QuizdyButton && widget.title.startsWith('Delete'),
        );
        expect(deleteBtnFinder, findsOneWidget);
        await tester.tap(deleteBtnFinder);
        await tester.pumpAndSettle();

        // Check for specialized warning
        expect(
          find.textContaining('This section has associated questions.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'shows standard bulk deletion confirmation dialog when selected sections have NO associated questions',
      (tester) async {
        // Mock FileLoaded state with NO linked questions
        final fileState = FileLoaded(
          QuizFile(metadata: testMetadata, study: null, questions: []),
        );
        when(() => mockFileBloc.state).thenReturn(fileState);

        // Mock StudyExecutionState in selection mode with selected chunk
        final studyState = StudyExecutionState(
          chunks: [testChunk],
          currentChunkIndex: 0,
          processedChunks: 1,
          progressPercentage: 100,
          isIndexMode: true,
          isSelectionMode: true,
          selectedIndices: {0},
        );
        when(() => mockStudyBloc.state).thenReturn(studyState);

        await tester.pumpWidget(
          createWidgetUnderTest(
            StudyBottomNavigation(
              quizFile: fileState.quizFile,
              onSave: () {},
              onImport: () {},
              onAddChunk: () {},
              onGenerateAI: () {},
            ),
          ),
        );

        final deleteBtnFinder = find.byWidgetPredicate(
          (widget) =>
              widget is QuizdyButton && widget.title.startsWith('Delete'),
        );
        expect(deleteBtnFinder, findsOneWidget);
        await tester.tap(deleteBtnFinder);
        await tester.pumpAndSettle();

        // Check for standard confirmation message
        expect(
          find.textContaining('Are you sure you want to delete'),
          findsOneWidget,
        );
        // Make sure the specialized warning is NOT present
        expect(
          find.textContaining('This section has associated questions.'),
          findsNothing,
        );
      },
    );
  });
}
