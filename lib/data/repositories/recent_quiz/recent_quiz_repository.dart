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

import 'dart:convert';
import 'package:hive_ce/hive.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/domain/models/recent_quiz/recent_quiz.dart';

/// Repository for handling persistence of recent study/quiz sessions.
class RecentQuizRepository {
  static const String boxName = 'recent_quizzes_box';
  late Box<String> _box;

  /// Initializes the repository by opening the Hive box.
  Future<void> init() async {
    _box = await Hive.openBox<String>(boxName);
  }

  /// Saves a quiz file as a recent study in the database.
  Future<void> saveRecentQuiz(QuizFile quizFile) async {
    // Generate a unique ID: use file path if present, otherwise generate from title hash
    final id =
        quizFile.filePath ?? 'unsaved_${quizFile.metadata.title.hashCode}';

    // Extract progress percentage from study content if present (normalize to 0.0 - 1.0)
    final double progress =
        (quizFile.study?.content.progressPercentage ?? 0.0) / 100.0;

    final recentQuiz = RecentQuiz(
      id: id,
      title: quizFile.metadata.title,
      description: quizFile.metadata.description,
      progress: progress,
      lastOpened: DateTime.now(),
      filePath: quizFile.filePath,
      quizFile: quizFile,
    );

    await _box.put(id, jsonEncode(recentQuiz.toJson()));
  }

  /// Returns the list of all recent quizzes, sorted by last opened timestamp descending.
  List<RecentQuiz> getRecentQuizzes() {
    final list = _box.values
        .map((s) {
          try {
            return RecentQuiz.fromJson(jsonDecode(s) as Map<String, dynamic>);
          } catch (e) {
            // Gracefully handle any formatting/evolution changes
            return null;
          }
        })
        .whereType<RecentQuiz>()
        .toList();

    // Sort: most recently opened first
    list.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));
    return list;
  }

  /// Deletes a recent study from the list.
  Future<void> removeRecentQuiz(String id) async {
    await _box.delete(id);
  }

  /// Clears the history database completely.
  Future<void> clearAll() async {
    await _box.clear();
  }
}
