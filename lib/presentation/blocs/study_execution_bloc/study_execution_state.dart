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
import 'package:collection/collection.dart';

class StudyExecutionState {
  final List<StudyChunk> chunks;
  final int currentChunkIndex;
  final String documentText;
  final String documentTitle;
  final bool isLoading;
  final double coveragePercentage;
  final int processedChunks;
  final String? error;

  const StudyExecutionState({
    this.chunks = const [],
    this.currentChunkIndex = 0,
    this.documentText = '',
    this.documentTitle = '',
    this.isLoading = false,
    this.coveragePercentage = 0.0,
    this.processedChunks = 0,
    this.error,
  });

  StudyExecutionState copyWith({
    List<StudyChunk>? chunks,
    int? currentChunkIndex,
    String? documentText,
    String? documentTitle,
    bool? isLoading,
    double? coveragePercentage,
    int? processedChunks,
    String? error,
  }) {
    return StudyExecutionState(
      chunks: chunks ?? this.chunks,
      currentChunkIndex: currentChunkIndex ?? this.currentChunkIndex,
      documentText: documentText ?? this.documentText,
      documentTitle: documentTitle ?? this.documentTitle,
      isLoading: isLoading ?? this.isLoading,
      coveragePercentage: coveragePercentage ?? this.coveragePercentage,
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
        other.documentText == documentText &&
        other.documentTitle == documentTitle &&
        other.isLoading == isLoading &&
        other.coveragePercentage == coveragePercentage &&
        other.processedChunks == processedChunks &&
        other.error == error;
  }

  @override
  int get hashCode {
    return chunks.hashCode ^
        currentChunkIndex.hashCode ^
        documentText.hashCode ^
        documentTitle.hashCode ^
        isLoading.hashCode ^
        coveragePercentage.hashCode ^
        processedChunks.hashCode ^
        error.hashCode;
  }
}
