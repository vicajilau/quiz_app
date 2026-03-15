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
import 'package:quizdy/domain/models/quiz/source_reference.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_event.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_state.dart';
import 'package:quizdy/domain/models/ai/ai_difficulty_level.dart';
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';
import 'package:quizdy/domain/use_cases/initialize_quiz_chunks_use_case.dart';

class StudyExecutionBloc
    extends Bloc<StudyExecutionEvent, StudyExecutionState> {
  final AiJitProcessingService _jitProcessingService;
  final AppLocalizations _localizations;
  final void Function(
    double progress,
    int processedChunks,
    List<StudyChunk> chunks,
    String? fileUri,
    DateTime? fileExpirationTime,
  )?
  onProgressChanged;
  final bool _isAutoDifficulty;
  final AiDifficultyLevel? _difficultyLevel;
  final String? _originalText;
  final String? _language;
  final AiGenerationMode? _generationMode;

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
    String? originalText,
    String? language,
    AiGenerationMode? generationMode,
    DateTime? fileExpirationTime,
    this.onProgressChanged,
  }) : _jitProcessingService = jitProcessingService,
       _localizations = localizations,
       _isAutoDifficulty = isAutoDifficulty,
       _difficultyLevel = difficultyLevel,
       _originalText = originalText,
       _language = language,
       _generationMode = generationMode,
       super(
         _initialProgress(
           initialChunks,
           documentTitle,
           documentSummary,
           fileAttachment: fileAttachment,
           fileUri: fileUri,
           fileExpirationTime: fileExpirationTime,
         ),
       ) {
    on<StudyChunkRequested>(_onStudyChunkRequested);
    on<NextStudyChunkRequested>(_onNextStudyChunkRequested);
    on<PreviousStudyChunkRequested>(_onPreviousStudyChunkRequested);
    on<AddStudyChunkRequested>(_onAddStudyChunkRequested);
    on<ReturnToIndexRequested>(_onReturnToIndexRequested);
    on<FileReattached>(_onFileReattached);
    on<FileReattachmentCancelled>(_onFileReattachmentCancelled);
    on<ReorderStudyChunks>(_onReorderStudyChunks);
    on<ToggleStudySelectionMode>(_onToggleStudySelectionMode);
    on<ToggleChunkSelection>(_onToggleChunkSelection);
    on<ClearSelectionRequested>(_onClearSelectionRequested);
    on<DownloadStudyChunkRequested>(_onDownloadStudyChunkRequested);
    on<GenerateAiStudyChunksRequested>(_onGenerateAiStudyChunksRequested);
    on<DeleteSelectedChunksRequested>(_onDeleteSelectedChunksRequested);
    on<ImportStudyChunksRequested>(_onImportStudyChunksRequested);
    on<StudyFileSaved>(
      (_, emit) => emit(state.copyWith(savedVersion: state.savedVersion + 1)),
    );
  }

  static StudyExecutionState _initialProgress(
    List<StudyChunk> chunks,
    String documentTitle,
    String? documentSummary, {
    AiFileAttachment? fileAttachment,
    String? fileUri,
    DateTime? fileExpirationTime,
  }) {
    var state = StudyExecutionState(
      chunks: chunks,
      fileAttachment: fileAttachment,
      fileUri: fileUri,
      fileExpirationTime: fileExpirationTime,
      documentTitle: documentTitle,
      documentSummary: documentSummary,
    );

    if (chunks.isEmpty) return state;

    int processedChunksCount = chunks
        .where(
          (c) =>
              c.status == StudyChunkState.completed ||
              c.status == StudyChunkState.downloaded,
        )
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

    // If content is already available but not yet marked as visited, mark it as completed now.
    if (chunk.status == StudyChunkState.downloaded) {
      final visitedChunk = chunk.copyWith(status: StudyChunkState.completed);
      final chunksVisited = List<StudyChunk>.from(state.chunks);
      chunksVisited[event.chunkIndex] = visitedChunk;
      emit(_updateProgress(state.copyWith(chunks: chunksVisited)));
      return;
    }

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

    String? fileUri = state.fileUri;
    DateTime? fileExpirationTime = state.fileExpirationTime;
    String? fileMimeType = state.fileAttachment?.mimeType;

    // Check if file is expired (with 10-minute buffer)
    final bool isExpired =
        fileExpirationTime != null &&
        DateTime.now()
            .add(const Duration(minutes: 10))
            .isAfter(fileExpirationTime);

    if ((fileUri == null || isExpired) && state.fileAttachment != null) {
      try {
        final uploadResult = await ServiceLocator.getIt<GeminiService>()
            .uploadFile(state.fileAttachment!, _localizations);
        fileUri = uploadResult.fileUri;
        fileExpirationTime = uploadResult.expirationTime;
        emit(
          state.copyWith(
            fileUri: fileUri,
            fileExpirationTime: fileExpirationTime,
          ),
        );
      } catch (e) {
        final errorChunk = chunk.copyWith(status: StudyChunkState.error);
        final chunksError = List<StudyChunk>.from(state.chunks);
        chunksError[event.chunkIndex] = errorChunk;
        emit(state.copyWith(chunks: chunksError, error: e.toString()));
        return;
      }
    }

    if ((fileUri == null || isExpired) &&
        _originalText == null &&
        !event.allowFallback) {
      if (state.fileAttachment != null) {
        // Revert chunk back to created — the user needs to re-attach the file
        final revertedChunk = chunk.copyWith(status: StudyChunkState.created);
        final chunksReverted = List<StudyChunk>.from(state.chunks);
        chunksReverted[event.chunkIndex] = revertedChunk;
        emit(
          state.copyWith(chunks: chunksReverted, needsFileReattachment: true),
        );
        return;
      }
    }

    // Wait for the JIT Processing Service
    final processedChunk = await _jitProcessingService.processChunk(
      chunk: processingChunk,
      fileUri: fileUri,
      fileMimeType: fileMimeType,
      originalText: _originalText,
      localizations: _localizations,
      docTitle: state.documentTitle,
      docSummary: state.documentSummary,
      isAutoDifficulty: _isAutoDifficulty,
      difficultyLevel: _difficultyLevel,
      language: _language ?? _localizations.localeName,
      generationMode: _generationMode,
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
      newState.fileUri,
      newState.fileExpirationTime,
    );
  }

  Future<void> _onDownloadStudyChunkRequested(
    DownloadStudyChunkRequested event,
    Emitter<StudyExecutionState> emit,
  ) async {
    if (event.chunkIndex < 0 || event.chunkIndex >= state.chunks.length) {
      return;
    }

    final chunk = state.chunks[event.chunkIndex];

    // Only download chunks that need processing.
    if (chunk.status == StudyChunkState.completed ||
        chunk.status == StudyChunkState.downloaded ||
        chunk.status == StudyChunkState.processing) {
      return;
    }

    // Mark as processing (stays in index mode).
    final processingChunk = chunk.copyWith(status: StudyChunkState.processing);
    final chunksProcessing = List<StudyChunk>.from(state.chunks);
    chunksProcessing[event.chunkIndex] = processingChunk;
    emit(state.copyWith(chunks: chunksProcessing));

    String? fileUri = state.fileUri;
    DateTime? fileExpirationTime = state.fileExpirationTime;
    final String? fileMimeType = state.fileAttachment?.mimeType;

    final bool isExpired =
        fileExpirationTime != null &&
        DateTime.now()
            .add(const Duration(minutes: 10))
            .isAfter(fileExpirationTime);

    if ((fileUri == null || isExpired) && state.fileAttachment != null) {
      try {
        final uploadResult = await ServiceLocator.getIt<GeminiService>()
            .uploadFile(state.fileAttachment!, _localizations);
        fileUri = uploadResult.fileUri;
        fileExpirationTime = uploadResult.expirationTime;
        emit(
          state.copyWith(
            fileUri: fileUri,
            fileExpirationTime: fileExpirationTime,
          ),
        );
      } catch (e) {
        final errorChunk = chunk.copyWith(status: StudyChunkState.error);
        final chunksError = List<StudyChunk>.from(state.chunks);
        chunksError[event.chunkIndex] = errorChunk;
        emit(state.copyWith(chunks: chunksError, error: e.toString()));
        return;
      }
    }

    final processedChunk = await _jitProcessingService.processChunk(
      chunk: processingChunk,
      fileUri: fileUri,
      fileMimeType: fileMimeType,
      originalText: _originalText,
      localizations: _localizations,
      docTitle: state.documentTitle,
      docSummary: state.documentSummary,
      isAutoDifficulty: _isAutoDifficulty,
      difficultyLevel: _difficultyLevel,
      language: _language ?? _localizations.localeName,
      generationMode: _generationMode,
    );

    final chunksFinished = List<StudyChunk>.from(state.chunks);
    chunksFinished[event.chunkIndex] = processedChunk;

    final newState = _updateProgress(state.copyWith(chunks: chunksFinished));
    emit(newState);

    onProgressChanged?.call(
      newState.progressPercentage,
      newState.processedChunks,
      newState.chunks,
      newState.fileUri,
      newState.fileExpirationTime,
    );
  }

  StudyExecutionState _updateProgress(StudyExecutionState currentState) {
    if (currentState.chunks.isEmpty) {
      return currentState.copyWith(progressPercentage: 0.0, processedChunks: 0);
    }

    int processedChunksCount = currentState.chunks
        .where(
          (c) =>
              c.status == StudyChunkState.completed ||
              c.status == StudyChunkState.downloaded,
        )
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

  void _onAddStudyChunkRequested(
    AddStudyChunkRequested event,
    Emitter<StudyExecutionState> emit,
  ) {
    final int newIndex = state.chunks.length;
    final newChunk = StudyChunk(
      chunkIndex: newIndex,
      status: StudyChunkState.created,
      aiSummary: event.content.isNotEmpty ? event.content : null,
      sourceReference: SourceReference(
        documentId: 'custom',
        startPage: 0,
        endPage: 0,
        startOffset: 0,
        endOffset: 0,
        blockType: event.title.isNotEmpty
            ? event.title
            : _localizations.studyScreenCustomChapter,
      ),
    );

    final modifiedChunks = List<StudyChunk>.from(state.chunks)..add(newChunk);

    final newState = _updateProgress(state.copyWith(chunks: modifiedChunks));
    emit(newState);

    onProgressChanged?.call(
      newState.progressPercentage,
      newState.processedChunks,
      newState.chunks,
      newState.fileUri,
      newState.fileExpirationTime,
    );
  }

  void _onReturnToIndexRequested(
    ReturnToIndexRequested event,
    Emitter<StudyExecutionState> emit,
  ) {
    emit(state.copyWith(isIndexMode: true));
  }

  Future<void> _onFileReattached(
    FileReattached event,
    Emitter<StudyExecutionState> emit,
  ) async {
    emit(
      state.copyWith(fileAttachment: event.file, needsFileReattachment: false),
    );
    // Re-trigger processing of the current chunk
    add(StudyChunkRequested(state.currentChunkIndex));
  }

  void _onFileReattachmentCancelled(
    FileReattachmentCancelled event,
    Emitter<StudyExecutionState> emit,
  ) {
    emit(state.copyWith(needsFileReattachment: false));
    // Trigger processing with fallback allowed
    add(StudyChunkRequested(state.currentChunkIndex, allowFallback: true));
  }

  void _onReorderStudyChunks(
    ReorderStudyChunks event,
    Emitter<StudyExecutionState> emit,
  ) {
    if (event.oldIndex == event.newIndex) return;

    final List<StudyChunk> newChunks = List.from(state.chunks);
    final Set<int> selectedIndices = state.selectedIndices;

    // Batch Reorder: If the dragged item is selected, move ALL selected items together.
    if (selectedIndices.contains(event.oldIndex)) {
      // 1. Collect all selected items in their original order
      final List<MapEntry<int, StudyChunk>> itemsToMove = [];
      final List<int> sortedOldIndices = selectedIndices.toList()..sort();

      // 2. Remove all selected items from the list (from end to start to maintain indices)
      for (final idx in sortedOldIndices.reversed) {
        itemsToMove.insert(0, MapEntry(idx, newChunks.removeAt(idx)));
      }

      // 3. Calculate the new insertion index after removals
      // event.newIndex is the position in the ORIGINAL list.
      // We need to count how many selected items were BEFORE the original newIndex.
      int insertionIndex = event.newIndex;
      int selectedBeforeNewIndex = 0;
      for (final idx in sortedOldIndices) {
        if (idx < event.newIndex) {
          selectedBeforeNewIndex++;
        }
      }
      insertionIndex -= selectedBeforeNewIndex;

      // Ensure index is within bounds
      if (insertionIndex < 0) insertionIndex = 0;
      if (insertionIndex > newChunks.length) insertionIndex = newChunks.length;

      // 4. Insert all selected items at the new position
      for (int i = 0; i < itemsToMove.length; i++) {
        newChunks.insert(insertionIndex + i, itemsToMove[i].value);
      }

      // 5. Update selection indices to the new consecutive range
      final Set<int> newSelectedIndices = {};
      for (int i = 0; i < itemsToMove.length; i++) {
        newSelectedIndices.add(insertionIndex + i);
      }

      emit(
        state.copyWith(
          chunks: _reindexChunks(newChunks),
          selectedIndices: newSelectedIndices,
        ),
      );
      return;
    }

    // Single Reorder: Standard behavior when dragging an unselected item
    int newIdx = event.newIndex;
    if (event.oldIndex < event.newIndex) {
      newIdx -= 1;
    }
    final chunk = newChunks.removeAt(event.oldIndex);
    newChunks.insert(newIdx, chunk);

    // Update selected indices (none of which are the moved item)
    final Set<int> newSelectedIndices = {};
    for (final index in state.selectedIndices) {
      if (index > event.oldIndex && index <= newIdx) {
        newSelectedIndices.add(index - 1);
      } else if (index < event.oldIndex && index >= newIdx) {
        newSelectedIndices.add(index + 1);
      } else {
        newSelectedIndices.add(index);
      }
    }

    emit(
      state.copyWith(
        chunks: _reindexChunks(newChunks),
        selectedIndices: newSelectedIndices,
      ),
    );
  }

  List<StudyChunk> _reindexChunks(List<StudyChunk> chunks) {
    final List<StudyChunk> reindexed = [];
    for (int i = 0; i < chunks.length; i++) {
      reindexed.add(chunks[i].copyWith(chunkIndex: i));
    }
    return reindexed;
  }

  void _onToggleStudySelectionMode(
    ToggleStudySelectionMode event,
    Emitter<StudyExecutionState> emit,
  ) {
    if (state.isSelectionMode) {
      // If turning off, clear selection
      emit(state.copyWith(isSelectionMode: false, selectedIndices: {}));
    } else {
      // If turning on, clear reordering
      emit(state.copyWith(isSelectionMode: true, selectedIndices: {}));
    }
  }

  void _onToggleChunkSelection(
    ToggleChunkSelection event,
    Emitter<StudyExecutionState> emit,
  ) {
    final newSelectedIndices = Set<int>.from(state.selectedIndices);
    if (newSelectedIndices.contains(event.index)) {
      newSelectedIndices.remove(event.index);
    } else {
      newSelectedIndices.add(event.index);
    }

    emit(state.copyWith(selectedIndices: newSelectedIndices));
  }

  void _onClearSelectionRequested(
    ClearSelectionRequested event,
    Emitter<StudyExecutionState> emit,
  ) {
    emit(state.copyWith(isSelectionMode: false, selectedIndices: {}));
  }

  Future<void> _onGenerateAiStudyChunksRequested(
    GenerateAiStudyChunksRequested event,
    Emitter<StudyExecutionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final initializeUseCase = InitializeQuizChunksUseCase(
        aiService: event.config.preferredService,
      );
      final documentId = 'study_${DateTime.now().millisecondsSinceEpoch}';
      final effectiveQuizContext = event.quizContext;

      List<StudyChunk> generatedChunks = [];

      if (event.config.hasFile) {
        final result = await initializeUseCase.generateChunksOnly(
          file: event.config.file!,
          documentId: documentId,
          localizations: _localizations,
          extraContext:
              '$effectiveQuizContext\n\nAdditional Instructions: ${event.config.content}',
          language: event.config.language,
        );
        generatedChunks = result['chunks'] as List<StudyChunk>;
      } else {
        final result = await initializeUseCase.generateChunksFromText(
          content:
              '$effectiveQuizContext\n\nUser Prompt: ${event.config.content}',
          generationMode: event.config.generationMode,
          documentId: documentId,
          localizations: _localizations,
          language: event.config.language,
          selectedQuestions: event.config.selectedQuestions,
        );
        generatedChunks = result['chunks'] as List<StudyChunk>;
      }

      // Append and re-index
      final int startIndex = state.chunks.length;
      final List<StudyChunk> appendedChunks = List.from(state.chunks);
      for (int i = 0; i < generatedChunks.length; i++) {
        appendedChunks.add(
          generatedChunks[i].copyWith(chunkIndex: startIndex + i),
        );
      }

      final newState = _updateProgress(
        state.copyWith(chunks: appendedChunks, isLoading: false),
      );
      emit(newState);

      onProgressChanged?.call(
        newState.progressPercentage,
        newState.processedChunks,
        newState.chunks,
        newState.fileUri,
        newState.fileExpirationTime,
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onDeleteSelectedChunksRequested(
    DeleteSelectedChunksRequested event,
    Emitter<StudyExecutionState> emit,
  ) {
    if (state.selectedIndices.isEmpty) return;

    final updatedChunks = List<StudyChunk>.from(state.chunks);
    final indicesToDelete = state.selectedIndices.toList()
      ..sort((a, b) => b.compareTo(a));

    for (final index in indicesToDelete) {
      updatedChunks.removeAt(index);
    }

    // Re-index remaining chunks
    for (int i = 0; i < updatedChunks.length; i++) {
      updatedChunks[i] = updatedChunks[i].copyWith(chunkIndex: i);
    }

    // Adjust currentChunkIndex if needed
    int newCurrentIndex = state.currentChunkIndex;
    if (updatedChunks.isEmpty) {
      newCurrentIndex = 0;
    } else if (newCurrentIndex >= updatedChunks.length) {
      newCurrentIndex = updatedChunks.length - 1;
    }

    final newState = _updateProgress(
      state.copyWith(
        chunks: updatedChunks,
        currentChunkIndex: newCurrentIndex,
        isSelectionMode: updatedChunks.isNotEmpty,
        selectedIndices: {},
      ),
    );
    emit(newState);

    // Notify progress change for persistence
    onProgressChanged?.call(
      newState.progressPercentage,
      newState.processedChunks,
      newState.chunks,
      newState.fileUri,
      newState.fileExpirationTime,
    );
  }

  void _onImportStudyChunksRequested(
    ImportStudyChunksRequested event,
    Emitter<StudyExecutionState> emit,
  ) {
    final currentChunks = List<StudyChunk>.from(state.chunks);
    final List<StudyChunk> mergedChunks = event.insertAtBeginning
        ? [...event.chunks, ...currentChunks]
        : [...currentChunks, ...event.chunks];

    // Re-index all chunks
    final reindexed = mergedChunks
        .asMap()
        .entries
        .map((e) => e.value.copyWith(chunkIndex: e.key))
        .toList();

    final newState = _updateProgress(state.copyWith(chunks: reindexed));
    emit(newState);

    onProgressChanged?.call(
      newState.progressPercentage,
      newState.processedChunks,
      newState.chunks,
      newState.fileUri,
      newState.fileExpirationTime,
    );
  }
}
