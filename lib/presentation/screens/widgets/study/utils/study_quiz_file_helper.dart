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
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:quizdy/core/constants/quiz_metadata.dart';
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/domain/models/quiz/quiz_metadata.dart';
import 'package:quizdy/domain/models/quiz/study.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/domain/models/quiz/study_content.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_state.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_state.dart';

class StudyQuizFileHelper {
  static QuizFile getCurrentQuizFile({
    required StudyExecutionState studyState,
    required FileState fileState,
    QuizFile? initialQuizFile,
    AiGenerationMode? generationMode,
    String? originalText,
  }) {
    QuizFile updatedQuizFile(QuizFile qf) {
      final processedChunks = studyState.chunks
          .where((c) => c.status != StudyChunkState.created)
          .length;
      final studyContent = StudyContent(
        progressPercentage: studyState.progressPercentage,
        totalChunks: studyState.chunks.length,
        processedChunks: processedChunks,
        cache: studyState.chunks,
      );

      return qf.copyWith(
        fileUri: studyState.fileUri,
        fileExpirationTime: studyState.fileExpirationTime,
        fileContentHash:
            qf.fileContentHash ?? studyState.fileAttachment?.contentHash,
        study:
            qf.study?.copyWith(content: studyContent) ??
            Study(
              content: studyContent,
              generationMode: generationMode,
              originalText: originalText,
            ),
      );
    }

    if (fileState is FileLoaded) {
      return updatedQuizFile(fileState.quizFile);
    } else if (fileState is FileSaved) {
      return updatedQuizFile(fileState.quizFile);
    } else if (initialQuizFile != null) {
      return updatedQuizFile(initialQuizFile);
    } else {
      return QuizFile(
        metadata: QuizMetadata(
          title: studyState.documentTitle,
          description: studyState.documentSummary ?? '',
          version: QuizMetadataConstants.version,
          author: '',
        ),
        questions: const [],
        study: Study(
          content: StudyContent(
            progressPercentage: studyState.progressPercentage,
            totalChunks: studyState.chunks.length,
            processedChunks: studyState.chunks
                .where((c) => c.status != StudyChunkState.created)
                .length,
            cache: studyState.chunks,
          ),
          generationMode: generationMode,
          originalText: originalText,
        ),
        fileContentHash: studyState.fileAttachment?.contentHash,
        fileUri: studyState.fileUri,
        fileExpirationTime: studyState.fileExpirationTime,
      );
    }
  }
}
