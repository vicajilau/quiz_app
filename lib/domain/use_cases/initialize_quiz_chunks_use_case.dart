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

import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/data/repositories/ai/ai_repository_factory.dart';
import 'package:quizdy/data/services/ai/ai_document_chunking_service.dart';
import 'package:quizdy/domain/models/ai/ai_difficulty_level.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';
import 'package:quizdy/domain/models/quiz/question.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/domain/models/quiz/source_reference.dart';
import 'package:quizdy/domain/models/quiz/study.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/domain/models/quiz/study_content.dart';

/// Use case that configures the `.quiz` file with chunk boundaries identified by AI.
class InitializeQuizChunksUseCase {
  final AiDocumentChunkingService _chunkingService;
  final AiRepositoryFactory _repositoryFactory;

  InitializeQuizChunksUseCase({
    AiDocumentChunkingService? chunkingService,
    AiRepositoryFactory? repositoryFactory,
  }) : _chunkingService =
           chunkingService ?? ServiceLocator.getIt<AiDocumentChunkingService>(),
       _repositoryFactory =
           repositoryFactory ?? ServiceLocator.getIt<AiRepositoryFactory>();

  /// Executes the AI chunking and returns a new [QuizFile] updated with the `study` mapping.
  Future<QuizFile> execute({
    required QuizFile quizFile,
    required AiFileAttachment file,
    required String documentId,
    required AppLocalizations localizations,
    required AiGenerationMode generationMode,
    String? originalText,
    required String language,
    bool isAutoDifficulty = true,
    AiDifficultyLevel? difficultyLevel,
  }) async {
    final result = await generateChunksOnly(
      file: file,
      documentId: documentId,
      localizations: localizations,
      extraContext: quizFile
          .metadata
          .description, // Use description as context if available
      language: language,
    );
    final chunks = result['chunks'] as List<StudyChunk>;

    final studyContent = StudyContent(
      progressPercentage: 0.0,
      totalChunks: chunks.length,
      processedChunks: 0,
      cache: chunks,
    );

    final study = Study(
      content: studyContent,
      generationMode: generationMode,
      originalText: originalText,
      language: language,
      isAutoDifficulty: isAutoDifficulty,
      difficultyLevel: difficultyLevel,
    );

    // Ensure the quizFile also stores the fileAttachment or at least its metadata
    // The UI should ideally pass the fileUri to the Bloc for JIT chunk generation.
    return quizFile.copyWith(
      study: study,
      fileAttachment: file,
      fileContentHash: file.contentHash,
      fileUri: result['fileUri'] as String?,
      fileExpirationTime: result['fileExpirationTime'] as DateTime?,
    );
  }

  /// Helper to generate chunks directly from a file without requiring a QuizFile.
  Future<Map<String, dynamic>> generateChunksOnly({
    required AiFileAttachment file,
    required String documentId,
    required AppLocalizations localizations,
    String? extraContext,
    required String language,
  }) async {
    final aiRepository = await _repositoryFactory.createDefault();

    final uploadResult = await aiRepository.uploadFile(file, localizations);
    final fileUri = uploadResult.fileUri;
    final fileExpirationTime = uploadResult.expirationTime;

    final indexResult = await _chunkingService.generateIndexWithAi(
      aiRepository: aiRepository,
      fileUri: fileUri,
      fileMimeType: file.mimeType,
      documentId: documentId,
      localizations: localizations,
      extraContext: extraContext,
      language: language,
    );

    final references = indexResult['references'] as List<SourceReference>;
    final chunks = references.asMap().entries.map((entry) {
      return StudyChunk(
        chunkIndex: entry.key,
        status: StudyChunkState.created,
        sourceReference: entry.value,
        aiSummary: null,
      );
    }).toList();

    return {
      'chunks': chunks,
      'fileUri': fileUri,
      'fileExpirationTime': fileExpirationTime,
      'title': indexResult['title'] as String?,
      'description': indexResult['description'] as String?,
    };
  }

  /// Helper to generate chunks directly from text content or topics without requiring a file.
  Future<Map<String, dynamic>> generateChunksFromText({
    required String content,
    required AiGenerationMode generationMode,
    required String documentId,
    required AppLocalizations localizations,
    required String language,
    List<Question>? selectedQuestions,
  }) async {
    final aiRepository = await _repositoryFactory.createDefault();

    final indexResult = await _chunkingService.generateIndexFromTextWithAi(
      aiRepository: aiRepository,
      content: content,
      generationMode: generationMode,
      documentId: documentId,
      localizations: localizations,
      language: language,
      selectedQuestions: selectedQuestions,
    );

    final references = indexResult['references'] as List<SourceReference>;
    final chunks = references.asMap().entries.map((entry) {
      return StudyChunk(
        chunkIndex: entry.key,
        status: StudyChunkState.created,
        sourceReference: entry.value,
        aiSummary: null,
      );
    }).toList();

    return {
      'chunks': chunks,
      'title': indexResult['title'] as String?,
      'description': indexResult['description'] as String?,
    };
  }
}
