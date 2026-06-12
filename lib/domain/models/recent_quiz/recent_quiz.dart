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

import 'package:quizdy/domain/models/quiz/quiz_file.dart';

/// Represents a recently loaded or edited quiz in the history database.
class RecentQuiz {
  /// Unique identifier of the recent quiz (typically the filePath, or generated ID if unsaved).
  final String id;

  /// Title of the quiz.
  final String title;

  /// Description or summary of the quiz content.
  final String description;

  /// Study progress percentage (0.0 to 1.0).
  final double progress;

  /// The date and time when this quiz was last opened.
  final DateTime lastOpened;

  /// The file path on the device, if any.
  final String? filePath;

  /// The full quiz file data.
  final QuizFile quizFile;

  RecentQuiz({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.lastOpened,
    this.filePath,
    required this.quizFile,
  });

  /// Converts the `RecentQuiz` to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'progress': progress,
      'lastOpened': lastOpened.toIso8601String(),
      'filePath': filePath,
      'quizFile': quizFile.toJson(),
    };
  }

  /// Creates a `RecentQuiz` from a JSON map.
  factory RecentQuiz.fromJson(Map<String, dynamic> json) {
    double progressValue = (json['progress'] as num?)?.toDouble() ?? 0.0;
    // Normalize progress if it was saved on a 0-100 scale in previous sessions
    if (progressValue > 1.0) {
      progressValue = progressValue / 100.0;
    }

    return RecentQuiz(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      progress: progressValue,
      lastOpened: DateTime.parse(json['lastOpened'] as String),
      filePath: json['filePath'] as String?,
      quizFile: QuizFile.fromJson(
        json['quizFile'] as Map<String, dynamic>,
        filePath: json['filePath'] as String?,
      ),
    );
  }

  /// Creates a copy of this `RecentQuiz` with optional updates.
  RecentQuiz copyWith({
    String? id,
    String? title,
    String? description,
    double? progress,
    DateTime? lastOpened,
    String? filePath,
    QuizFile? quizFile,
  }) {
    return RecentQuiz(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      lastOpened: lastOpened ?? this.lastOpened,
      filePath: filePath ?? this.filePath,
      quizFile: quizFile ?? this.quizFile,
    );
  }
}
