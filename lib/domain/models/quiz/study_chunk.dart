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

import 'package:flutter/foundation.dart';
import 'package:quizdy/domain/models/quiz/source_reference.dart';
import 'package:quizdy/domain/models/quiz/study_page.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';

/// Represents a distinct chunk of study material, often derived from a source document.
///
/// It holds the semantic essence of a specific section (via `aiSummary`) and
/// provides UI-ready sequences (`pages`) for the user to consume interactively.
class StudyChunk {
  /// The sequential index or ordering of this chunk.
  final int chunkIndex;

  /// The current processing state of the chunk.
  final StudyChunkState status;

  /// Link back to the specific part of the source document this chunk originated from.
  final SourceReference sourceReference;

  /// The title of the chunk/section, sourced from the blockType.
  String get title => sourceReference.blockType;

  /// An AI-generated textual summary of the source section.
  final String? aiSummary;

  /// The UI views to present to the user representing this chunk.
  final List<StudyPage> pages;

  /// An optional error message if the chunk generation failed.
  final String? errorMessage;

  /// Constructor for a `StudyChunk`.
  const StudyChunk({
    required this.chunkIndex,
    required this.status,
    required this.sourceReference,
    this.aiSummary,
    this.pages = const [],
    this.errorMessage,
  });

  /// Creates a `StudyChunk` instance from a JSON map.
  ///
  /// - [json]: The JSON map containing the study chunk data.
  /// - Returns: A populated `StudyChunk` instance.
  factory StudyChunk.fromJson(Map<String, dynamic> json) {
    List<StudyPage> parsedPages = [];
    // Check both pages (issue #221) and slides (legacy)
    final pagesJson = (json['pages'] ?? json['slides']) as List<dynamic>?;
    if (pagesJson != null) {
      parsedPages = pagesJson
          .map(
            (pageJson) => StudyPage.fromJson(pageJson as Map<String, dynamic>),
          )
          .toList();
    }

    return StudyChunk(
      chunkIndex: json['chunk_index'] as int? ?? 0,
      status: StudyChunkState.fromString(
        json['status'] as String? ?? 'created',
      ),
      sourceReference: SourceReference.fromJson(
        json['source_reference'] as Map<String, dynamic>? ?? {},
      ),
      aiSummary: json['ai_summary'] as String?,
      pages: parsedPages,
      errorMessage: json['error_message'] as String?,
    );
  }

  /// Converts the `StudyChunk` instance to a JSON map.
  ///
  /// - Returns: A JSON map representation.
  Map<String, dynamic> toJson() {
    return {
      'chunk_index': chunkIndex,
      'status': status.toJson(),
      'source_reference': sourceReference.toJson(),
      if (aiSummary != null) 'ai_summary': aiSummary,
      'pages': pages.map((page) => page.toJson()).toList(),
      if (errorMessage != null) 'error_message': errorMessage,
    };
  }

  /// Creates a copy of the `StudyChunk` with optional parameter modifications.
  StudyChunk copyWith({
    int? chunkIndex,
    StudyChunkState? status,
    SourceReference? sourceReference,
    String? aiSummary,
    List<StudyPage>? pages,
    String? errorMessage,
  }) {
    return StudyChunk(
      chunkIndex: chunkIndex ?? this.chunkIndex,
      status: status ?? this.status,
      sourceReference: sourceReference ?? this.sourceReference.copyWith(),
      aiSummary: aiSummary ?? this.aiSummary,
      pages: pages ?? this.pages.map((s) => s.copyWith()).toList(),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StudyChunk &&
        other.chunkIndex == chunkIndex &&
        other.status == status &&
        other.sourceReference == sourceReference &&
        other.aiSummary == aiSummary &&
        other.errorMessage == errorMessage &&
        listEquals(other.pages, pages);
  }

  @override
  int get hashCode {
    return chunkIndex.hashCode ^
        status.hashCode ^
        sourceReference.hashCode ^
        aiSummary.hashCode ^
        Object.hashAll(pages);
  }

  @override
  String toString() {
    return 'StudyChunk(chunkIndex: $chunkIndex, status: ${status.name}, pages: ${pages.length})';
  }
}
