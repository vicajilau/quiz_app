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

import 'package:quizdy/domain/models/quiz/question.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';

/// Repository interface to manage quiz file I/O operations and status validation.
abstract class QuizFileRepository {
  /// Loads a QuizFile from the specified file path.
  Future<QuizFile> loadQuizFile(String filePath);

  /// Creates a new QuizFile with the provided metadata and optional questions.
  Future<QuizFile> createQuizFile({
    required String title,
    required String description,
    required String version,
    required String author,
    List<Question>? questions,
  });

  /// Saves a QuizFile. Returns the saved QuizFile (potentially with an updated path) or null if cancelled.
  Future<QuizFile?> saveQuizFile(
    QuizFile quizFile,
    String dialogTitle,
    String fileName,
  );

  /// Triggers a picker to load a QuizFile.
  Future<QuizFile?> pickFile();

  /// Loads the content of a QuizFile without registering or caching.
  Future<QuizFile> loadQuizFileContent(String filePath);

  /// Registers a QuizFile as the active one in the system.
  void registerQuizFile(QuizFile quizFile);

  /// Updates the active QuizFile without overriding the original file cache.
  void updateActiveQuizFile(QuizFile quizFile);

  /// Picks a file manually using a file picker without registering.
  Future<QuizFile?> pickFileContent();

  /// Picks a file manually with side effects.
  Future<QuizFile?> pickFileManually();

  /// Checks if the provided cachedQuizFile differs from the original file loaded.
  bool hasQuizFileChanged(QuizFile cachedQuizFile);

  /// Helper to determine if a question is newly added relative to the original file.
  bool isQuestionNew(int index, Question question);

  /// Helper to determine if an existing question has been modified.
  bool isQuestionModified(int index, Question question);

  /// Helper to determine if a study chunk is newly added relative to the original file.
  bool isStudyChunkNew(int index, StudyChunk chunk);

  /// Helper to determine if an existing study chunk has been modified.
  bool isStudyChunkModified(int index, StudyChunk chunk);
}
