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

import 'package:flutter_test/flutter_test.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/data/services/ai/ai_jit_processing_service.dart';
import 'package:quizdy/domain/models/quiz/source_reference.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_bloc.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_event.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_state.dart';
import 'package:quizdy/domain/models/ai/ai_difficulty_level.dart';
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';
import 'package:bloc_test/bloc_test.dart';

class MockAppLocalizations implements AppLocalizations {
  @override
  String get studyScreenCoverage => 'Coverage';
  @override
  String studyScreenSectionIndicator(Object current, Object total) =>
      'Page $current of $total';
  @override
  String get localeName => 'en';

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAiJitProcessingService extends AiJitProcessingService {
  @override
  Future<StudyChunk> processChunk({
    required StudyChunk chunk,
    String? fileUri,
    String? fileMimeType,
    String? originalText,
    required AppLocalizations localizations,
    String? docTitle,
    String? docSummary,
    bool isAutoDifficulty = true,
    AiDifficultyLevel? difficultyLevel,
    required String language,
    AiGenerationMode? generationMode,
  }) async {
    return chunk.copyWith(status: StudyChunkState.downloaded);
  }
}

void main() {
  late MockAppLocalizations mockLocalizations;
  late AiJitProcessingService mockJitService;

  setUp(() {
    mockLocalizations = MockAppLocalizations();
    mockJitService = FakeAiJitProcessingService();
  });

  group('StudyExecutionBloc Coverage Calculation', () {
    final chunk1 = const StudyChunk(
      id: 'test_chunk_1',
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
      id: 'test_chunk_2',
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
        documentTitle: 'Test Doc',
      );

      // (1 / 2) * 100 = 50%
      expect(bloc.state.processedChunks, 1);
      expect(bloc.state.progressPercentage, equals(50.0));
      bloc.close();
    });

    blocTest<StudyExecutionBloc, StudyExecutionState>(
      'updates coverage when a chunk is completed',
      build: () => StudyExecutionBloc(
        jitProcessingService: mockJitService,
        localizations: mockLocalizations,
        initialChunks: [
          chunk1,
          chunk2.copyWith(status: StudyChunkState.completed),
        ],
        documentTitle: 'Test Doc',
      ),
      act: (bloc) => bloc.add(const StudyChunkRequested(0)),
      verify: (bloc) {
        expect(bloc.state.processedChunks, 2);
        expect(bloc.state.progressPercentage, equals(100.0));
      },
    );

    blocTest<StudyExecutionBloc, StudyExecutionState>(
      'DownloadAllStudyChunksRequested updates isDownloadingAll correctly and processes pending chunks',
      build: () => StudyExecutionBloc(
        jitProcessingService: mockJitService,
        localizations: mockLocalizations,
        initialChunks: [chunk1, chunk2],
        documentTitle: 'Test Doc',
      ),
      act: (bloc) => bloc.add(const DownloadAllStudyChunksRequested()),
      expect: () => [
        isA<StudyExecutionState>().having(
          (s) => s.isDownloadingAll,
          'isDownloadingAll',
          true,
        ),
        isA<StudyExecutionState>().having(
          (s) => s.isDownloadingAll,
          'isDownloadingAll',
          true,
        ),
        isA<StudyExecutionState>().having(
          (s) => s.isDownloadingAll,
          'isDownloadingAll',
          true,
        ),
        isA<StudyExecutionState>().having(
          (s) => s.isDownloadingAll,
          'isDownloadingAll',
          false,
        ),
      ],
      verify: (bloc) {
        expect(bloc.state.chunks[1].status, StudyChunkState.downloaded);
        expect(bloc.state.isDownloadingAll, false);
      },
    );
  });
}
