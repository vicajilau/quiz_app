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

import 'package:quizdy/data/repositories/quiz_file_repository.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/domain/models/quiz/question.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';

/// Use case for checking if a QuizFile has changed.
class CheckFileChangesUseCase {
  final QuizFileRepository _fileRepository;

  /// Constructor that receives the repository as a dependency.
  CheckFileChangesUseCase({required QuizFileRepository fileRepository})
    : _fileRepository = fileRepository;

  /// Executes the business logic to check if the file has changed.
  ///
  /// [cachedFile] is the QuizFile that needs to be checked for changes.
  /// It calls the repository method to check whether the file has changed.
  /// Returns true if the file has changed, false otherwise.
  bool execute(QuizFile cachedFile) {
    // Calls the repository to check if the file has changed
    return _fileRepository.hasQuizFileChanged(cachedFile);
  }

  /// Checks if a question at a specific index is new.
  bool isQuestionNew(int index, Question question) {
    return _fileRepository.isQuestionNew(index, question);
  }

  /// Checks if a question at a specific index was modified.
  bool isQuestionModified(int index, Question question) {
    return _fileRepository.isQuestionModified(index, question);
  }

  /// Checks if a study chunk at a specific index is new.
  bool isStudyChunkNew(int index, StudyChunk chunk) {
    return _fileRepository.isStudyChunkNew(index, chunk);
  }

  /// Checks if a study chunk at a specific index was modified.
  bool isStudyChunkModified(int index, StudyChunk chunk) {
    return _fileRepository.isStudyChunkModified(index, chunk);
  }
}
