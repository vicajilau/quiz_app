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

import 'package:quizdy/core/debug_print.dart';
import 'package:quizdy/data/services/file_service/i_file_service.dart';
import 'package:quizdy/domain/repositories/quiz_file_repository.dart';

import 'package:quizdy/domain/models/quiz/question.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/domain/models/quiz/quiz_metadata.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';

/// Concrete implementation of [QuizFileRepository] in the data layer.
class QuizFileRepositoryImpl implements QuizFileRepository {
  /// Instance of `IFileService` to handle file operations.
  final IFileService _fileService;

  /// Constructor to initialize `QuizFileRepositoryImpl` with a `FileService` instance.
  QuizFileRepositoryImpl({required this._fileService});

  @override
  Future<QuizFile> loadQuizFile(String filePath) async {
    return await _fileService.readQuizFile(filePath);
  }

  @override
  Future<QuizFile> createQuizFile({
    required String title,
    required String description,
    required String version,
    required String author,
    List<Question>? questions,
  }) async {
    final metadata = QuizMetadata(
      title: title,
      description: description,
      version: version,
      author: author,
    );

    final quizFile = QuizFile(metadata: metadata, questions: questions ?? []);

    return quizFile;
  }

  @override
  Future<QuizFile?> saveQuizFile(
    QuizFile quizFile,
    String dialogTitle,
    String fileName,
  ) async {
    return await _fileService.saveQuizFile(quizFile, dialogTitle, fileName);
  }

  @override
  Future<QuizFile?> pickFile() async {
    return await _fileService.pickFile();
  }

  @override
  Future<QuizFile> loadQuizFileContent(String filePath) async {
    return await _fileService.readQuizFileContent(filePath);
  }

  @override
  void registerQuizFile(QuizFile quizFile) {
    _fileService.originalFile = quizFile.deepCopy();
  }

  @override
  void updateActiveQuizFile(QuizFile quizFile) {
    // No-op (active state is now managed directly inside FileBloc/Cubit)
  }

  @override
  Future<QuizFile?> pickFileContent() async {
    return await _fileService.pickFileContent();
  }

  @override
  Future<QuizFile?> pickFileManually() async {
    return await _fileService.pickFile();
  }

  @override
  bool hasQuizFileChanged(QuizFile cachedQuizFile) {
    if (cachedQuizFile.filePath == null) return true;

    final originalFile = _fileService.originalFile;
    if (originalFile == null) return true;

    final hasChanged = originalFile != cachedQuizFile;

    if (!hasChanged) {
      printInDebug('File changed: false');
    } else {
      printInDebug('File changed: true');
      // Verifying which field changed
      if (originalFile.metadata != cachedQuizFile.metadata) {
        printInDebug('Metadata differs');
      }
      if (originalFile.questions.length != cachedQuizFile.questions.length) {
        printInDebug(
          'Questions count differs: ${originalFile.questions.length} vs ${cachedQuizFile.questions.length}',
        );
      }
      if (originalFile.study != cachedQuizFile.study) {
        printInDebug('Study differs');
        if (originalFile.study != null && cachedQuizFile.study != null) {
          if (originalFile.study!.content != cachedQuizFile.study!.content) {
            printInDebug('Study content differs');
            if (originalFile.study!.content.cache.length !=
                cachedQuizFile.study!.content.cache.length) {
              printInDebug(
                'Study chunk length differs: ${originalFile.study!.content.cache.length} vs ${cachedQuizFile.study!.content.cache.length}',
              );
            } else {
              for (
                int i = 0;
                i < originalFile.study!.content.cache.length;
                i++
              ) {
                final ogChunk = originalFile.study!.content.cache[i];
                final cChunk = cachedQuizFile.study!.content.cache[i];
                if (ogChunk != cChunk) {
                  printInDebug(
                    'CHUNK $i DIFFERS! ogStatus: ${ogChunk.status.name}, cStatus: ${cChunk.status.name}, ogPages: ${ogChunk.pages.length}, cPages: ${cChunk.pages.length}',
                  );
                }
              }
            }
          }
        }
      }
    }

    return hasChanged;
  }

  @override
  bool isQuestionNew(int index, Question question) {
    final originalFile = _fileService.originalFile;
    if (originalFile == null) return true;
    if (originalFile.questions.any((q) => q == question)) {
      return false;
    }
    return !originalFile.questions.any(
      (q) => q.identityHash == question.identityHash,
    );
  }

  @override
  bool isQuestionModified(int index, Question question) {
    final originalFile = _fileService.originalFile;
    if (originalFile == null) return false;
    final originals = originalFile.questions.where(
      (q) => q.identityHash == question.identityHash,
    );
    if (originals.isEmpty) return false;
    return !originals.any((original) => original == question);
  }

  @override
  bool isStudyChunkNew(int index, StudyChunk chunk) {
    final originalFile = _fileService.originalFile;
    if (originalFile == null) return true;
    final originalStudy = originalFile.study;
    if (originalStudy == null) return true;
    return !originalStudy.content.cache.any(
      (original) => original.sourceReference == chunk.sourceReference,
    );
  }

  @override
  bool isStudyChunkModified(int index, StudyChunk chunk) {
    if (chunk.status == StudyChunkState.error) return false;
    final originalFile = _fileService.originalFile;
    if (originalFile == null) return false;
    final originalStudy = originalFile.study;
    if (originalStudy == null) return false;
    final originals = originalStudy.content.cache.where(
      (o) => o.sourceReference == chunk.sourceReference,
    );
    if (originals.isEmpty) return false;
    final original = originals.first;
    // Compare ignoring chunkIndex (changes on reorder) and status (changes on download/process)
    return original.copyWith(chunkIndex: 0, status: StudyChunkState.created) !=
        chunk.copyWith(chunkIndex: 0, status: StudyChunkState.created);
  }
}
