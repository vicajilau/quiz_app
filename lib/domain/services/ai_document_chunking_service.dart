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
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';
import 'package:quizdy/domain/models/quiz/question.dart';
import 'package:quizdy/domain/models/quiz/source_reference.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/repositories/ai_repository.dart';

/// Service interface to define logic for segmenting document text into study chunks.
abstract class AiDocumentChunkingService {
  /// Splits local document text into standard sequential offsets.
  Future<List<SourceReference>> chunkDocument(
    String documentText,
    String documentId,
    AppLocalizations localizations,
  );

  /// Generates the document index using an active AI session and uploaded file references.
  Future<Map<String, dynamic>> generateIndexWithAi({
    required AiRepository aiRepository,
    required String fileUri,
    required String fileMimeType,
    required String documentId,
    required AppLocalizations localizations,
    String? extraContext,
    required String language,
  });

  /// Generates the document index from plain text content or questions via AI.
  Future<Map<String, dynamic>> generateIndexFromTextWithAi({
    required AiRepository aiRepository,
    required String content,
    required AiGenerationMode generationMode,
    required String documentId,
    required AppLocalizations localizations,
    required String language,
    List<Question>? selectedQuestions,
    List<StudyChunk>? selectedChunks,
  });
}
