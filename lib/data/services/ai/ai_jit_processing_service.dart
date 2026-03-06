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
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/data/services/ai/gemini_service.dart';
import 'package:quizdy/domain/models/quiz/page.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/domain/models/ai/ai_difficulty_level.dart';
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';

/// Service responsible for Just-In-Time (JIT) processing of study chunks.
class AiJitProcessingService {
  AiJitProcessingService();

  /// Processes a [StudyChunk] on-demand to generate its AI summary and UI pages.
  ///
  /// It returns a new immutable [StudyChunk] with the resulting state.
  ///
  /// - [chunk]: The raw chunk entity containing the source references.
  /// - [fileUri]: The URI of the uploaded file in Gemini.
  /// - [fileMimeType]: The MIME type of the uploaded file.
  /// - [localizations]: Localization bundle for error messages.
  /// - Returns: A future resolving to a populated or failed `StudyChunk`.
  Future<StudyChunk> processChunk({
    required StudyChunk chunk,
    String? fileUri,
    String? fileMimeType,
    String? originalText,
    required AppLocalizations localizations,
    String? docTitle,
    String? docSummary,
    bool isAutoDifficulty = true,
    AiDifficultyLevel? difficultyLevel,
    required String language,
    AiGenerationMode? generationMode,
  }) async {
    // We only process chunks that have not been successfully processed yet.
    if (chunk.status == StudyChunkState.completed) {
      return chunk;
    }

    // Safety layer to protect against AI hallucinations extending offsets beyond the document length
    final startPage = chunk.sourceReference.startPage;
    final endPage = chunk.sourceReference.endPage;

    final prompt = _buildSystemPrompt(
      startPage,
      endPage,
      localizations,
      docTitle: docTitle,
      docSummary: docSummary,
      chunkTitle: chunk.title,
      isAutoDifficulty: isAutoDifficulty,
      difficultyLevel: difficultyLevel,
      language: language,
      generationMode: generationMode,
    );

    try {
      final geminiService = ServiceLocator.getIt<GeminiService>();
      final String responseBody;
      if (fileUri != null && fileMimeType != null) {
        responseBody = await geminiService.getChatResponseWithFileUri(
          prompt,
          localizations,
          fileUri: fileUri,
          fileMimeType: fileMimeType,
          responseMimeType: 'application/json',
        );
      } else if (originalText != null) {
        final textPrompt = '$prompt\n\nSource text:\n$originalText';
        responseBody = await geminiService.getChatResponse(
          textPrompt,
          localizations,
          responseMimeType: 'application/json',
        );
      } else {
        // Fallback: Generate content using only metadata
        responseBody = await geminiService.getChatResponse(
          '$prompt\n\nNo source text available. Generate based on metadata.',
          localizations,
          responseMimeType: 'application/json',
        );
      }

      final cleanJsonString = _extractJsonFromResponse(responseBody);
      final parsedData = _parseJsonResponse(cleanJsonString);

      return chunk.copyWith(
        status: StudyChunkState.completed,
        aiSummary: parsedData['aiSummary'] as String?,
        pages: parsedData['pages'] as List<Page>?,
      );
    } catch (e) {
      if (e is FormatException) {
        // En el caso de JSON truncado por Límite de Output Tokens en JIT.
        throw Exception(
          '${localizations.aiErrorResponse}: JSON Truncated by AI limits. ($e)',
        );
      }

      return chunk.copyWith(
        status: StudyChunkState.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Builds the instruction set for specific page ranges.
  String _buildSystemPrompt(
    int startPage,
    int endPage,
    AppLocalizations localizations, {
    String? docTitle,
    String? docSummary,
    String? chunkTitle,
    bool isAutoDifficulty = true,
    AiDifficultyLevel? difficultyLevel,
    String? language,
    AiGenerationMode? generationMode,
  }) {
    final metadataContext =
        (docTitle != null ? '\nDocument Title: $docTitle' : '') +
        (docSummary != null ? '\nDocument Summary: $docSummary' : '') +
        (chunkTitle != null ? '\nTarget Section Title: $chunkTitle' : '') +
        (generationMode != null
            ? '\nGeneration Source: ${generationMode.name}'
            : '');
    String difficultyInstruction = '';
    if (!isAutoDifficulty && difficultyLevel != null) {
      final levelName = _getDifficultyName(difficultyLevel, localizations);
      difficultyInstruction =
          '\nIMPORTANT: The generated content and study materials MUST be adapted to a $levelName difficulty level. Explain concepts, use vocabulary, and provide examples appropriate for this academic level.';
    } else if (isAutoDifficulty) {
      difficultyInstruction =
          '\nIMPORTANT: The generated content and study materials MUST be adapted to the SAME academic difficulty level, vocabulary, and depth as the provided document.';
    }

    final targetLanguage = language ?? localizations.localeName;

    return '''
You are an expert educational content generator. Your task is to analyze the provided pages of the document and generate study material for them.

IMPORTANT GLOBAL RULE:
ALL generated content (ai_summary, page texts, titles, paragraphs, components) MUST be written strictly in the following language: $targetLanguage.

IMPORTANT: Metadata Context for this study material:$metadataContext

IMPORTANT: Focus ONLY on the content found between pages $startPage and $endPage (inclusive).$difficultyInstruction

Important Output Instructions:
- If the provided text contains a Table of Contents (TOC), completely ignore it and do not generate study elements for the TOC itself.
- If the provided text consists mostly of exercises, questions, or problems, you MUST generate the prerequisite theoretical content, explanations, and concepts necessary to understand and solve those exercises, rather than simply listing or summarizing the exercises themselves.

You must return the result ONLY as a valid JSON object. Do not include any other text, markdown formatting (like ```json), or explanations.

The output MUST be a JSON object with two fields:
1. "ai_summary": A string containing a concise and clear summary of the provided text.
2. "pages": A JSON array of "Page" objects designed for an interactive learning UI.

Each Page object in the "pages" array must have the following schema:
{
  "components": [
    // Array of component objects. Each object MUST have a "type" field and its specific required fields.
    // Allowed values for "type" and their required structures are:
    // 1. { "type": "section_title", "title": "Main topic", "subtitle": "Optional context" }
    // 2. { "type": "paragraph", "title": "Optional heading", "body": "Main text block" }
    // 3. { "type": "key_definition", "term": "Vocabulary word/concept", "body": "Clear definition" }
    // 4. { "type": "numbered_list", "title": "Optional heading", "items": [{"title": "Step 1", "description": "Details for step 1"}] }
    // 5. { "type": "comparison_table", "title": "Optional", "columns": ["Feature", "A", "B"], "rows": [{"label": "Row 1", "values": ["A's val", "B's val"]}] }
    // 6. { "type": "quote", "body": "The quote text", "author": "Optional source" }
    // 7. { "type": "warning", "body": "Important caveat or common misconception" }
    // 8. { "type": "formula", "title": "Optional", "equation": "E = mc^2", "equation_label": "Optional name", "body": "Explanation" }
    // 9. { "type": "timeline", "title": "Optional", "items": [{"date": "1990", "title": "Event", "description": "Optional details"}] }
    // 10. { "type": "pros_cons", "items": {"pros": ["Advantage 1"], "cons": ["Disadvantage 1"]} }
    // 11. { "type": "key_concepts", "title": "Optional", "items": ["Concept 1", "Concept 2"] }
    // 12. { "type": "reminder", "body": "A quick tip or study reminder" }
    // 13. { "type": "icon_cards", "title": "Optional", "items": [{"title": "Card title", "description": "Card details"}] }
  ]
}

Ensure the structure of the JSON is exactly as specified so it can be parsed programmatically. You must only use the 13 component types listed above. Do not invent new types.

Text Portion to Analyze:
"""
Analyzing document range: Pages $startPage to $endPage.
"""
''';
  }

  /// Extracts the JSON string from the LLM response, stripping markdown if present.
  String _extractJsonFromResponse(String response) {
    // Try to find content between ```json and ```
    final regExp = RegExp(r'```json\s*([\s\S]*?)\s*```', multiLine: true);
    final match = regExp.firstMatch(response);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!.trim();
    }

    // Fallback to searching for the first { and last }
    final firstBrace = response.indexOf('{');
    final lastBrace = response.lastIndexOf('}');
    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      return response.substring(firstBrace, lastBrace + 1).trim();
    }

    return response.trim();
  }

  /// Parses the raw JSON object string into the summary and pages mapping.
  Map<String, dynamic> _parseJsonResponse(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object.');
      }

      final summary = decoded['ai_summary'] as String?;
      List<Page>? pages;

      // Check both pages (issue #221) and slides (legacy)
      final pagesList =
          (decoded['pages'] ?? decoded['slides']) as List<dynamic>?;
      if (pagesList != null) {
        pages = pagesList
            .map((s) => Page.fromJson(s as Map<String, dynamic>))
            .toList();
      }

      return {'aiSummary': summary, 'pages': pages};
    } catch (e) {
      throw FormatException(
        'Failed to parse AI JSON response: $e\nResponse String: $jsonString',
      );
    }
  }

  String _getDifficultyName(
    AiDifficultyLevel difficulty,
    AppLocalizations localizations,
  ) {
    switch (difficulty) {
      case AiDifficultyLevel.elementary:
        return localizations.aiDifficultyElementary;
      case AiDifficultyLevel.highSchool:
        return localizations.aiDifficultyHighSchool;
      case AiDifficultyLevel.bachelors:
        return localizations.aiDifficultyBachelors;
      case AiDifficultyLevel.university:
        return localizations.aiDifficultyUniversity;
      case AiDifficultyLevel.masters:
        return localizations.aiDifficultyMasters;
      case AiDifficultyLevel.doctorate:
        return localizations.aiDifficultyDoctorate;
    }
  }
}
