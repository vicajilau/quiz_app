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

part 'srs_metadata.g.dart';

/// Represents the Spaced Repetition System (SRS) metadata for a question.
@HiveType(
  typeId: 0,
) // You might need to change this typeId to a unique one in your app
class SrsMetadata extends HiveObject {
  @HiveField(0)
  String questionIdentity;

  @HiveField(1)
  String fileIdentifier;

  @HiveField(2)
  int interval; // In days

  @HiveField(3)
  int repetition;

  @HiveField(4)
  double easeFactor;

  @HiveField(5)
  DateTime nextReviewDate;

  @HiveField(6)
  int timesCorrect;

  @HiveField(7)
  int timesIncorrect;

  @HiveField(8)
  String questionText;

  SrsMetadata({
    required this.questionIdentity,
    required this.fileIdentifier,
    this.interval = 0,
    this.repetition = 0,
    this.easeFactor = 2.5,
    DateTime? nextReviewDate,
    this.timesCorrect = 0,
    this.timesIncorrect = 0,
    this.questionText = '',
  }) : nextReviewDate = nextReviewDate ?? DateTime.now();

  /// Creates a copy of the `SrsMetadata` with optional parameter modifications.
  SrsMetadata copyWith({
    String? questionIdentity,
    String? fileIdentifier,
    int? interval,
    int? repetition,
    double? easeFactor,
    DateTime? nextReviewDate,
    int? timesCorrect,
    int? timesIncorrect,
    String? questionText,
  }) {
    return SrsMetadata(
      questionIdentity: questionIdentity ?? this.questionIdentity,
      fileIdentifier: fileIdentifier ?? this.fileIdentifier,
      interval: interval ?? this.interval,
      repetition: repetition ?? this.repetition,
      easeFactor: easeFactor ?? this.easeFactor,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      timesCorrect: timesCorrect ?? this.timesCorrect,
      timesIncorrect: timesIncorrect ?? this.timesIncorrect,
      questionText: questionText ?? this.questionText,
    );
  }
}
