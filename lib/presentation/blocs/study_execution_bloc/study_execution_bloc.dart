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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/data/services/ai/ai_jit_processing_service.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_event.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_state.dart';

class StudyExecutionBloc
    extends Bloc<StudyExecutionEvent, StudyExecutionState> {
  final AiJitProcessingService _jitProcessingService;
  final AppLocalizations _localizations;
  final void Function(
    double coverage,
    int processedChunks,
    List<StudyChunk> chunks,
  )?
  onProgressChanged;

  StudyExecutionBloc({
    required AiJitProcessingService jitProcessingService,
    required AppLocalizations localizations,
    required List<StudyChunk> initialChunks,
    required String documentText,
    required String documentTitle,
    this.onProgressChanged,
  }) : _jitProcessingService = jitProcessingService,
       _localizations = localizations,
       super(_initialProgress(initialChunks, documentText, documentTitle)) {
    on<StudyChunkRequested>(_onStudyChunkRequested);
    on<NextStudyChunkRequested>(_onNextStudyChunkRequested);
    on<PreviousStudyChunkRequested>(_onPreviousStudyChunkRequested);
  }

  static StudyExecutionState _initialProgress(
    List<StudyChunk> chunks,
    String documentText,
    String documentTitle,
  ) {
    var state = StudyExecutionState(
      chunks: chunks,
      documentText: documentText,
      documentTitle: documentTitle,
    );

    if (documentText.isEmpty) return state;

    int processedChars = 0;
    int processedChunksCount = 0;

    for (final chunk in chunks) {
      if (chunk.status == StudyChunkState.completed) {
        processedChunksCount++;
        final start = chunk.sourceReference.startOffset;
        final end = chunk.sourceReference.endOffset;
        if (end > start) {
          processedChars += (end - start);
        }
      }
    }

    final coverage = (processedChars / documentText.length * 100).clamp(
      0.0,
      100.0,
    );

    return state.copyWith(
      coveragePercentage: coverage,
      processedChunks: processedChunksCount,
    );
  }

  Future<void> _onStudyChunkRequested(
    StudyChunkRequested event,
    Emitter<StudyExecutionState> emit,
  ) async {
    if (event.chunkIndex < 0 || event.chunkIndex >= state.chunks.length) {
      return;
    }

    // Set the current chunk
    emit(state.copyWith(currentChunkIndex: event.chunkIndex));

    final chunk = state.chunks[event.chunkIndex];

    // Only process if it's created or encountered an error. If it's already completed or processing, do nothing.
    if (chunk.status == StudyChunkState.completed ||
        chunk.status == StudyChunkState.processing) {
      return;
    }

    // Mark as processing
    final processingChunk = chunk.copyWith(status: StudyChunkState.processing);
    final chunksProcessing = List<StudyChunk>.from(state.chunks);
    chunksProcessing[event.chunkIndex] = processingChunk;
    emit(state.copyWith(chunks: chunksProcessing));

    // Wait for the JIT Processing Service
    final processedChunk = await _jitProcessingService.processChunk(
      processingChunk,
      state.documentText,
      _localizations,
    );

    // Update the state with the finished chunk (either completed or error)
    final chunksFinished = List<StudyChunk>.from(state.chunks);
    chunksFinished[event.chunkIndex] = processedChunk;

    final newState = _updateProgress(state.copyWith(chunks: chunksFinished));
    emit(newState);

    // Notify progress change for persistence
    onProgressChanged?.call(
      newState.coveragePercentage,
      newState.processedChunks,
      newState.chunks,
    );
  }

  StudyExecutionState _updateProgress(StudyExecutionState currentState) {
    if (currentState.documentText.isEmpty) return currentState;

    int processedChars = 0;
    int processedChunksCount = 0;

    for (final chunk in currentState.chunks) {
      if (chunk.status == StudyChunkState.completed) {
        processedChunksCount++;
        final start = chunk.sourceReference.startOffset;
        final end = chunk.sourceReference.endOffset;
        // Ensure we don't count negative lengths or hallucinated offsets
        if (end > start) {
          processedChars += (end - start);
        }
      }
    }

    final coverage = (processedChars / currentState.documentText.length * 100)
        .clamp(0.0, 100.0);

    return currentState.copyWith(
      coveragePercentage: coverage,
      processedChunks: processedChunksCount,
    );
  }

  void _onNextStudyChunkRequested(
    NextStudyChunkRequested event,
    Emitter<StudyExecutionState> emit,
  ) {
    if (state.hasNext) {
      add(StudyChunkRequested(state.currentChunkIndex + 1));
    }
  }

  void _onPreviousStudyChunkRequested(
    PreviousStudyChunkRequested event,
    Emitter<StudyExecutionState> emit,
  ) {
    if (state.hasPrevious) {
      add(StudyChunkRequested(state.currentChunkIndex - 1));
    }
  }
}
