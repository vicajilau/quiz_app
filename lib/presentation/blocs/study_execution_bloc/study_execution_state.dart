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

import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:collection/collection.dart';

class StudyExecutionState {
  final List<StudyChunk> chunks;
  final int currentChunkIndex;
  final AiFileAttachment? fileAttachment;
  final String? fileUri;
  final String documentTitle;
  final String? documentSummary;
  final bool isLoading;
  final bool isIndexMode;
  final double progressPercentage;
  final int processedChunks;
  final String? error;

  const StudyExecutionState({
    this.chunks = const [],
    this.currentChunkIndex = 0,
    this.fileAttachment,
    this.fileUri,
    this.documentTitle = '',
    this.documentSummary,
    this.isLoading = false,
    this.isIndexMode = true,
    this.progressPercentage = 0.0,
    this.processedChunks = 0,
    this.error,
  });

  StudyExecutionState copyWith({
    List<StudyChunk>? chunks,
    int? currentChunkIndex,
    AiFileAttachment? fileAttachment,
    String? fileUri,
    String? documentTitle,
    String? documentSummary,
    bool? isLoading,
    bool? isIndexMode,
    double? progressPercentage,
    int? processedChunks,
    String? error,
  }) {
    return StudyExecutionState(
      chunks: chunks ?? this.chunks,
      currentChunkIndex: currentChunkIndex ?? this.currentChunkIndex,
      fileAttachment: fileAttachment ?? this.fileAttachment,
      fileUri: fileUri ?? this.fileUri,
      documentTitle: documentTitle ?? this.documentTitle,
      documentSummary: documentSummary ?? this.documentSummary,
      isLoading: isLoading ?? this.isLoading,
      isIndexMode: isIndexMode ?? this.isIndexMode,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      processedChunks: processedChunks ?? this.processedChunks,
      error: error, // Can be null to clear error
    );
  }

  /// Helper to get the currently active chunk
  StudyChunk? get currentChunk {
    if (chunks.isEmpty ||
        currentChunkIndex < 0 ||
        currentChunkIndex >= chunks.length) {
      return null;
    }
    return chunks[currentChunkIndex];
  }

  /// Checks if there's a next chunk available.
  bool get hasNext => currentChunkIndex < chunks.length - 1;

  /// Checks if there's a previous chunk available.
  bool get hasPrevious => currentChunkIndex > 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is StudyExecutionState &&
        listEquals(other.chunks, chunks) &&
        other.currentChunkIndex == currentChunkIndex &&
        other.fileAttachment == fileAttachment &&
        other.fileUri == fileUri &&
        other.documentTitle == documentTitle &&
        other.documentSummary == documentSummary &&
        other.isLoading == isLoading &&
        other.isIndexMode == isIndexMode &&
        other.progressPercentage == progressPercentage &&
        other.processedChunks == processedChunks &&
        other.error == error;
  }

  @override
  int get hashCode {
    return chunks.hashCode ^
        currentChunkIndex.hashCode ^
        fileAttachment.hashCode ^
        fileUri.hashCode ^
        documentTitle.hashCode ^
        documentSummary.hashCode ^
        isLoading.hashCode ^
        isIndexMode.hashCode ^
        progressPercentage.hashCode ^
        processedChunks.hashCode ^
        error.hashCode;
  }
}
