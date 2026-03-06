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
class ReturnToIndexRequested extends StudyExecutionEvent {}

/// Dispatched to move to the next chunk.
class NextStudyChunkRequested extends StudyExecutionEvent {}

/// Dispatched to move to the previous chunk.
class PreviousStudyChunkRequested extends StudyExecutionEvent {}

/// Dispatched to add a new empty study chunk at the end.
class AddStudyChunkRequested extends StudyExecutionEvent {
  final String title;
  final String content;

  AddStudyChunkRequested({required this.title, required this.content});
}

/// Dispatched when the user re-attaches the original file.
class FileReattached extends StudyExecutionEvent {
  final AiFileAttachment file;

  const FileReattached(this.file);
}

/// Dispatched when the user cancels the re-attachment dialog.
class FileReattachmentCancelled extends StudyExecutionEvent {}
