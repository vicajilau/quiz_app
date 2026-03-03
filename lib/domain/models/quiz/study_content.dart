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
import 'package:quizdy/domain/models/quiz/study_chunk.dart';

/// Represents the actual content and progress data mapping to an ongoing study session.
class StudyContent {
  /// The percentage (0-100) of the source material covered/processed.
  final double progressPercentage;

  /// The total expected number of chunks.
  final int totalChunks;

  /// The number of chunks successfully processed so far.
  final int processedChunks;

  /// The list of study chunks holding the material and related UI states.
  final List<StudyChunk> cache;

  /// Constructor for `StudyContent`.
  const StudyContent({
    required this.progressPercentage,
    required this.totalChunks,
    required this.processedChunks,
    required this.cache,
  });

  /// Creates a `StudyContent` instance from a JSON map.
  ///
  /// - [json]: The JSON map containing the study content data.
  /// - Returns: A populated `StudyContent` instance.
  factory StudyContent.fromJson(Map<String, dynamic> json) {
    final cacheJson = json['cache'] as List<dynamic>? ?? [];
    final cache = cacheJson
        .map(
          (chunkJson) => StudyChunk.fromJson(chunkJson as Map<String, dynamic>),
        )
        .toList();

    return StudyContent(
      progressPercentage:
          (json['progress_percentage'] as num?)?.toDouble() ??
          (json['coverage_percentage'] as num?)?.toDouble() ??
          0.0,
      totalChunks: json['total_chunks'] as int? ?? 0,
      processedChunks: json['processed_chunks'] as int? ?? 0,
      cache: cache,
    );
  }

  /// Converts the `StudyContent` instance to a JSON map.
  ///
  /// - Returns: A JSON map representation.
  Map<String, dynamic> toJson() {
    return {
      'progress_percentage': progressPercentage,
      'total_chunks': totalChunks,
      'processed_chunks': processedChunks,
      'cache': cache.map((chunk) => chunk.toJson()).toList(),
    };
  }

  /// Creates a copy of the `StudyContent` with optional parameter modifications.
  StudyContent copyWith({
    double? progressPercentage,
    int? totalChunks,
    int? processedChunks,
    List<StudyChunk>? cache,
  }) {
    return StudyContent(
      progressPercentage: progressPercentage ?? this.progressPercentage,
      totalChunks: totalChunks ?? this.totalChunks,
      processedChunks: processedChunks ?? this.processedChunks,
      cache: cache ?? this.cache.map((c) => c.copyWith()).toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StudyContent &&
        other.progressPercentage == progressPercentage &&
        other.totalChunks == totalChunks &&
        other.processedChunks == processedChunks &&
        listEquals(other.cache, cache);
  }

  @override
  int get hashCode {
    return progressPercentage.hashCode ^
        totalChunks.hashCode ^
        processedChunks.hashCode ^
        Object.hashAll(cache);
  }

  @override
  String toString() {
    return 'StudyContent(coverage: $progressPercentage%, total: $totalChunks, processed: $processedChunks, cache: ${cache.length})';
  }
}
