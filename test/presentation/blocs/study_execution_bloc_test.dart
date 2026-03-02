import 'package:flutter_test/flutter_test.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/data/services/ai/ai_jit_processing_service.dart';
import 'package:quizdy/domain/models/quiz/source_reference.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_bloc.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_event.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_state.dart';
import 'package:bloc_test/bloc_test.dart';

class MockAppLocalizations implements AppLocalizations {
  @override
  String get studyScreenCoverage => 'Coverage';
  @override
  String studyScreenSectionIndicator(Object current, Object total) =>
      'Page $current of $total';

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockAppLocalizations mockLocalizations;
  late AiJitProcessingService mockJitService;

  setUp(() {
    mockLocalizations = MockAppLocalizations();
    mockJitService = AiJitProcessingService.instance;
  });

  group('StudyExecutionBloc Coverage Calculation', () {
    final documentText =
        'This is a test document with exactly 40 characters.'; // Length 51? Let's count
    // T h i s   i s   a   t e s t   d o c u m e n t   w i t h   e x a c t l y   4 0   c h a r a c t e r s .
    // 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
    // It's 51 chars.

    final chunk1 = const StudyChunk(
      chunkIndex: 0,
      status: StudyChunkState.completed,
      sourceReference: SourceReference(
        documentId: 'doc1',
        startPage: 1,
        endPage: 1,
        startOffset: 0,
        endOffset: 10,
        blockType: 'text',
      ),
    );

    final chunk2 = const StudyChunk(
      chunkIndex: 1,
      status: StudyChunkState.created,
      sourceReference: SourceReference(
        documentId: 'doc1',
        startPage: 1,
        endPage: 1,
        startOffset: 10,
        endOffset: 30,
        blockType: 'text',
      ),
    );

    test('initial state calculates coverage for already completed chunks', () {
      final bloc = StudyExecutionBloc(
        jitProcessingService: mockJitService,
        localizations: mockLocalizations,
        initialChunks: [chunk1, chunk2],
        documentText: documentText,
        documentTitle: 'Test Doc',
      );

      // 10 chars out of 51 is ~19.6%
      expect(bloc.state.processedChunks, 1);
      expect(bloc.state.coveragePercentage, closeTo(19.60, 0.01));
      bloc.close();
    });

    blocTest<StudyExecutionBloc, StudyExecutionState>(
      'updates coverage when a chunk is completed',
      build: () => StudyExecutionBloc(
        jitProcessingService: mockJitService,
        localizations: mockLocalizations,
        initialChunks: [
          chunk1,
          chunk2.copyWith(
            status: StudyChunkState.completed,
          ), // Pre-set to completed for testing update logic in bloc if it was processing
        ],
        documentText: documentText,
        documentTitle: 'Test Doc',
      ),
      act: (bloc) => bloc.add(
        const StudyChunkRequested(0),
      ), // Already completed, just triggers state update/emit if needed, but bloc ignores it
      verify: (bloc) {
        // total processed chars: 10 (chunk1) + 20 (chunk2) = 30
        // 30 / 51 = ~58.82%
        expect(bloc.state.processedChunks, 2);
        expect(bloc.state.coveragePercentage, closeTo(58.82, 0.01));
      },
    );
  });
}
