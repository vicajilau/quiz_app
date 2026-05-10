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

import 'package:quizdy/domain/models/srs/srs_metadata.dart';

/// Service implementing the Spaced Repetition System algorithm (based on SM-2).
class AnkiAlgorithmService {
  /// Calculates the next review metadata for a question based on its score.
  /// Score ranges from 0 (completely incorrect) to 5 (perfect response).
  /// If the app only uses boolean correctness (correct/incorrect), we can map
  /// correct to 4 (or 5) and incorrect to 0 (or 1).
  static SrsMetadata calculateNextReview(SrsMetadata current, int score) {
    int interval = current.interval;
    int repetition = current.repetition;
    double easeFactor = current.easeFactor;
    int timesCorrect = current.timesCorrect;
    int timesIncorrect = current.timesIncorrect;

    // Constrain score between 0 and 5
    score = score.clamp(0, 5);

    if (score >= 3) {
      // Correct response
      if (repetition == 0) {
        interval = 1;
      } else if (repetition == 1) {
        interval = 6;
      } else {
        interval = (interval * easeFactor).round();
      }
      repetition += 1;
      timesCorrect += 1;
    } else {
      // Incorrect response
      repetition = 0;
      interval = 1;
      timesIncorrect += 1;
    }

    // Update ease factor
    easeFactor = easeFactor + (0.1 - (5 - score) * (0.08 + (5 - score) * 0.02));
    if (easeFactor < 1.3) {
      easeFactor = 1.3;
    }

    // Calculate next review date
    DateTime nextReviewDate = DateTime.now().add(Duration(days: interval));

    return current.copyWith(
      interval: interval,
      repetition: repetition,
      easeFactor: easeFactor,
      nextReviewDate: nextReviewDate,
      timesCorrect: timesCorrect,
      timesIncorrect: timesIncorrect,
    );
  }
}
