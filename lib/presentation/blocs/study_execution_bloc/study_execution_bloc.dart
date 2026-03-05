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
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/data/services/ai/ai_jit_processing_service.dart';
import 'package:quizdy/data/services/ai/gemini_service.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_event.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_state.dart';
import 'package:quizdy/domain/models/ai/ai_difficulty_level.dart';

class StudyExecutionBloc
    extends Bloc<StudyExecutionEvent, StudyExecutionState> {
  final AiJitProcessingService _jitProcessingService;
  final AppLocalizations _localizations;
  final void Function(
    double progress,
    int processedChunks,
    List<StudyChunk> chunks,
  )?
  onProgressChanged;
  final bool _isAutoDifficulty;
  final AiDifficultyLevel? _difficultyLevel;

  StudyExecutionBloc({
    required AiJitProcessingService jitProcessingService,
    required AppLocalizations localizations,
    required List<StudyChunk> initialChunks,
    required String documentTitle,
    String? documentSummary,
    AiFileAttachment? fileAttachment,
    String? fileUri,
    bool isAutoDifficulty = true,
    AiDifficultyLevel? difficultyLevel,
    this.onProgressChanged,
  }) : _jitProcessingService = jitProcessingService,
       _localizations = localizations,
       _isAutoDifficulty = isAutoDifficulty,
       _difficultyLevel = difficultyLevel,
       super(
         _initialProgress(
           initialChunks,
           documentTitle,
           documentSummary,
           fileAttachment: fileAttachment,
           fileUri: fileUri,
         ),
       ) {
    on<StudyChunkRequested>(_onStudyChunkRequested);
    on<NextStudyChunkRequested>(_onNextStudyChunkRequested);
    on<PreviousStudyChunkRequested>(_onPreviousStudyChunkRequested);
    on<ReturnToIndexRequested>(_onReturnToIndexRequested);
  }

  static StudyExecutionState _initialProgress(
    List<StudyChunk> chunks,
    String documentTitle,
    String? documentSummary, {
    AiFileAttachment? fileAttachment,
    String? fileUri,
  }) {
    var state = StudyExecutionState(
      chunks: chunks,
      fileAttachment: fileAttachment,
      fileUri: fileUri,
      documentTitle: documentTitle,
      documentSummary: documentSummary,
    );

    if (chunks.isEmpty) return state;

    int processedChunksCount = chunks
        .where((c) => c.status == StudyChunkState.completed)
        .length;

    final progress = (processedChunksCount / chunks.length * 100).clamp(
      0.0,
      100.0,
    );

    return state.copyWith(
      progressPercentage: progress,
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

    // Set the current chunk and exit index mode
    emit(
      state.copyWith(currentChunkIndex: event.chunkIndex, isIndexMode: false),
    );

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

    // Ensure we have a fileUri (multimodal File API upload)
    String? fileUri = state.fileUri;
    String? fileMimeType = state.fileAttachment?.mimeType;

    if (fileUri == null && state.fileAttachment != null) {
      try {
        fileUri = await ServiceLocator.getIt<GeminiService>().uploadFile(
          state.fileAttachment!,
          _localizations,
        );
        emit(state.copyWith(fileUri: fileUri));
      } catch (e) {
        final errorChunk = chunk.copyWith(status: StudyChunkState.error);
        final chunksError = List<StudyChunk>.from(state.chunks);
        chunksError[event.chunkIndex] = errorChunk;
        emit(state.copyWith(chunks: chunksError, error: e.toString()));
        return;
      }
    }

    if (fileUri == null) {
      final errorChunk = chunk.copyWith(status: StudyChunkState.error);
      final chunksError = List<StudyChunk>.from(state.chunks);
      chunksError[event.chunkIndex] = errorChunk;
      emit(
        state.copyWith(
          chunks: chunksError,
          error: _localizations.aiErrorResponse,
        ),
      );
      return;
    }

    // Wait for the JIT Processing Service
    final processedChunk = await _jitProcessingService.processChunk(
      chunk: processingChunk,
      fileUri: fileUri,
      fileMimeType: fileMimeType ?? 'application/pdf',
      localizations: _localizations,
      isAutoDifficulty: _isAutoDifficulty,
      difficultyLevel: _difficultyLevel,
    );

    // Update the state with the finished chunk (either completed or error)
    final chunksFinished = List<StudyChunk>.from(state.chunks);
    chunksFinished[event.chunkIndex] = processedChunk;

    final newState = _updateProgress(state.copyWith(chunks: chunksFinished));
    emit(newState);

    // Notify progress change for persistence
    onProgressChanged?.call(
      newState.progressPercentage,
      newState.processedChunks,
      newState.chunks,
    );
  }

  StudyExecutionState _updateProgress(StudyExecutionState currentState) {
    if (currentState.chunks.isEmpty) return currentState;

    int processedChunksCount = currentState.chunks
        .where((c) => c.status == StudyChunkState.completed)
        .length;

    final progress = (processedChunksCount / currentState.chunks.length * 100)
        .clamp(0.0, 100.0);

    return currentState.copyWith(
      progressPercentage: progress,
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

  void _onReturnToIndexRequested(
    ReturnToIndexRequested event,
    Emitter<StudyExecutionState> emit,
  ) {
    emit(state.copyWith(isIndexMode: true));
  }
}
