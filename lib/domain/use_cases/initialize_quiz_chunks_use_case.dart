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
import 'package:quizdy/data/services/ai/ai_document_chunking_service.dart';
import 'package:quizdy/data/services/ai/gemini_service.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/domain/models/quiz/study.dart';
import 'package:quizdy/domain/models/quiz/study_content.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/data/services/ai/ai_service.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/domain/models/quiz/source_reference.dart';
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';

/// Use case that configures the `.quiz` file with chunk boundaries identified by AI.
class InitializeQuizChunksUseCase {
  final AiDocumentChunkingService _chunkingService;
  final AIService _aiService;

  InitializeQuizChunksUseCase({
    AiDocumentChunkingService? chunkingService,
    AIService? aiService,
  }) : _chunkingService =
           chunkingService ?? ServiceLocator.getIt<AiDocumentChunkingService>(),
       _aiService = aiService ?? ServiceLocator.getIt<GeminiService>();

  /// Executes the AI chunking and returns a new [QuizFile] updated with the `study` mapping.
  Future<QuizFile> execute(
    QuizFile quizFile,
    AiFileAttachment file,
    String documentId,
    AppLocalizations localizations,
  ) async {
    final result = await generateChunksOnly(
      file: file,
      documentId: documentId,
      localizations: localizations,
      extraContext: quizFile
          .metadata
          .description, // Use description as context if available
    );
    final chunks = result['chunks'] as List<StudyChunk>;

    final studyContent = StudyContent(
      progressPercentage: 0.0,
      totalChunks: chunks.length,
      processedChunks: 0,
      cache: chunks,
    );

    final study = Study(content: studyContent);

    // Ensure the quizFile also stores the fileAttachment or at least its metadata
    // The UI should ideally pass the fileUri to the Bloc for JIT chunk generation.
    return quizFile.copyWith(
      study: study,
      fileAttachment: file,
      fileContentHash: file.contentHash,
    );
  }

  /// Helper to generate chunks directly from a file without requiring a QuizFile.
  Future<Map<String, dynamic>> generateChunksOnly({
    required AiFileAttachment file,
    required String documentId,
    required AppLocalizations localizations,
    String? extraContext,
  }) async {
    // 1. Upload the file to the AI service to get a URI (Gemini File API)
    final fileUri = await _aiService.uploadFile(file, localizations);

    // 2. Generate logical chunks using AI analysis of the uploaded file
    final indexResult = await _chunkingService.generateIndexWithAi(
      aiService: _aiService,
      fileUri: fileUri,
      fileMimeType: file.mimeType,
      documentId: documentId,
      localizations: localizations,
      extraContext: extraContext,
    );

    final references = indexResult['references'] as List<SourceReference>;
    final chunks = references.asMap().entries.map((entry) {
      return StudyChunk(
        chunkIndex: entry.key,
        status: StudyChunkState.created,
        sourceReference: entry.value,
        aiSummary: null,
        slides: null,
      );
    }).toList();

    return {
      'chunks': chunks,
      'fileUri': fileUri,
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
  }) async {
    final indexResult = await _chunkingService.generateIndexFromTextWithAi(
      aiService: _aiService,
      content: content,
      generationMode: generationMode,
      documentId: documentId,
      localizations: localizations,
    );

    final references = indexResult['references'] as List<SourceReference>;
    final chunks = references.asMap().entries.map((entry) {
      return StudyChunk(
        chunkIndex: entry.key,
        status: StudyChunkState.created,
        sourceReference: entry.value,
        aiSummary: null,
        slides: null,
      );
    }).toList();

    return {
      'chunks': chunks,
      'title': indexResult['title'] as String?,
      'description': indexResult['description'] as String?,
    };
  }
}
