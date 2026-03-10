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

import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/domain/models/ai/ai_study_generation_config.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';

abstract class StudyExecutionEvent {
  const StudyExecutionEvent();
}

/// Dispatched when the study mode view is ready and wants to process the actual chunk.
class StudyChunkRequested extends StudyExecutionEvent {
  final int chunkIndex;
  final bool allowFallback;

  const StudyChunkRequested(this.chunkIndex, {this.allowFallback = false});
}

/// Dispatched to return to the index view.
class ReturnToIndexRequested extends StudyExecutionEvent {
  const ReturnToIndexRequested();
}

/// Dispatched to move to the next chunk.
class NextStudyChunkRequested extends StudyExecutionEvent {
  const NextStudyChunkRequested();
}

/// Dispatched to move to the previous chunk.
class PreviousStudyChunkRequested extends StudyExecutionEvent {
  const PreviousStudyChunkRequested();
}

/// Dispatched to add a new empty study chunk at the end.
class AddStudyChunkRequested extends StudyExecutionEvent {
  final String title;
  final String content;

  const AddStudyChunkRequested({required this.title, required this.content});
}

/// Dispatched when the user re-attaches the original file.
class FileReattached extends StudyExecutionEvent {
  final AiFileAttachment file;

  const FileReattached(this.file);
}

/// Dispatched when the user cancels the re-attachment dialog.
class FileReattachmentCancelled extends StudyExecutionEvent {
  const FileReattachmentCancelled();
}

/// Dispatched to reorder chunks in the study list.
class ReorderStudyChunks extends StudyExecutionEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderStudyChunks(this.oldIndex, this.newIndex);
}

/// Dispatched to manually toggle selection mode (Select/Done).
class ToggleStudySelectionMode extends StudyExecutionEvent {
  const ToggleStudySelectionMode();
}

/// Dispatched when the user toggles selection for a specific chunk.
class ToggleChunkSelection extends StudyExecutionEvent {
  final int index;

  const ToggleChunkSelection(this.index);
}

/// Dispatched to exit selection mode and clear all selections.
class ClearSelectionRequested extends StudyExecutionEvent {
  const ClearSelectionRequested();
}

/// Dispatched to delete all currently selected chunks.
class DeleteSelectedChunksRequested extends StudyExecutionEvent {
  const DeleteSelectedChunksRequested();
}

/// Dispatched to download (JIT-process) a chunk from the index view without navigating away.
class DownloadStudyChunkRequested extends StudyExecutionEvent {
  final int chunkIndex;

  const DownloadStudyChunkRequested(this.chunkIndex);
}

/// Dispatched to import a list of existing chunks from another quiz file.
class ImportStudyChunksRequested extends StudyExecutionEvent {
  final List<StudyChunk> chunks;
  final bool insertAtBeginning;

  const ImportStudyChunksRequested({
    required this.chunks,
    required this.insertAtBeginning,
  });
}

/// Dispatched after the file is saved so the index refreshes isNew/isModified badges.
class StudyFileSaved extends StudyExecutionEvent {
  const StudyFileSaved();
}

/// Dispatched to generate new study sections using AI.
class GenerateAiStudyChunksRequested extends StudyExecutionEvent {
  final AiStudyGenerationConfig config;
  final String quizContext;

  const GenerateAiStudyChunksRequested({
    required this.config,
    required this.quizContext,
  });
}
