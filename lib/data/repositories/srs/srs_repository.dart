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

import 'package:hive_ce/hive.dart';
import 'package:quizdy/domain/models/srs/srs_metadata.dart';

/// Repository for handling SRS metadata operations.
class SrsRepository {
  static const String boxName = 'srs_metadata_box';
  late Box<SrsMetadata> _box;

  Future<void> init() async {
    _box = await Hive.openBox<SrsMetadata>(boxName);
  }

  /// Gets the metadata for a specific question.
  SrsMetadata getMetadataForQuestion(
    String questionIdentity,
    String fileIdentifier,
  ) {
    final key = _generateKey(fileIdentifier, questionIdentity);
    return _box.get(key) ??
        SrsMetadata(
          questionIdentity: questionIdentity,
          fileIdentifier: fileIdentifier,
        );
  }

  /// Saves the metadata for a specific question.
  Future<void> saveMetadata(SrsMetadata metadata) async {
    final key = _generateKey(
      metadata.fileIdentifier,
      metadata.questionIdentity,
    );
    await _box.put(key, metadata);
  }

  /// Gets all questions that are due for review.
  List<SrsMetadata> getDueQuestions({String? fileIdentifier}) {
    final now = DateTime.now();
    return _box.values.where((metadata) {
      final isDue =
          metadata.nextReviewDate.isBefore(now) ||
          metadata.nextReviewDate.isAtSameMomentAs(now);
      if (fileIdentifier != null) {
        return isDue && metadata.fileIdentifier == fileIdentifier;
      }
      return isDue;
    }).toList();
  }

  /// Gets the statistics grouped by file identifier.
  Map<String, List<SrsMetadata>> getStatsGroupedByFile() {
    final Map<String, List<SrsMetadata>> grouped = {};
    for (final metadata in _box.values) {
      if (!grouped.containsKey(metadata.fileIdentifier)) {
        grouped[metadata.fileIdentifier] = [];
      }
      grouped[metadata.fileIdentifier]!.add(metadata);
    }
    return grouped;
  }

  /// Gets statistics for a specific file identifier.
  List<SrsMetadata> getStatsForFile(String fileIdentifier) {
    return _box.values
        .where((m) => m.fileIdentifier == fileIdentifier)
        .toList();
  }

  /// Deletes all statistics for a specific file identifier.
  Future<void> deleteStatsForFile(String fileIdentifier) async {
    final keysToDelete = _box.values
        .where((m) => m.fileIdentifier == fileIdentifier)
        .map((m) => _generateKey(m.fileIdentifier, m.questionIdentity))
        .toList();

    await _box.deleteAll(keysToDelete);
  }

  /// Resets statistics to zero for a specific file identifier, preserving question text.
  Future<void> resetStatsForFile(String fileIdentifier) async {
    final toUpdate = _box.values
        .where((m) => m.fileIdentifier == fileIdentifier)
        .toList();
    for (final metadata in toUpdate) {
      final resetMetadata = metadata.copyWith(
        interval: 0,
        repetition: 0,
        easeFactor: 2.5,
        nextReviewDate: DateTime.now(),
        timesCorrect: 0,
        timesIncorrect: 0,
      );
      await saveMetadata(resetMetadata);
    }
  }

  /// Deletes all statistics.
  Future<void> deleteAllStats() async {
    await _box.clear();
  }

  /// Resets all statistics to zero, preserving question texts.
  Future<void> resetAllStats() async {
    final toUpdate = _box.values.toList();
    for (final metadata in toUpdate) {
      final resetMetadata = metadata.copyWith(
        interval: 0,
        repetition: 0,
        easeFactor: 2.5,
        nextReviewDate: DateTime.now(),
        timesCorrect: 0,
        timesIncorrect: 0,
      );
      await saveMetadata(resetMetadata);
    }
  }

  String _generateKey(String fileIdentifier, String questionIdentity) {
    return '${fileIdentifier}_$questionIdentity';
  }
}
