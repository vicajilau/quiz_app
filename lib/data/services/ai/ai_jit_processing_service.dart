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

import 'package:quizdy/core/debug_print.dart';
import 'package:quizdy/core/extensions/string_extension.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/domain/repositories/ai_repository_factory.dart';
import 'package:quizdy/domain/models/ai/ai_difficulty_level.dart';
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/domain/models/quiz/study_page.dart';
import 'package:quizdy/genui_registry.g.dart';

/// Service responsible for Just-In-Time (JIT) processing of study chunks.
class AiJitProcessingService {
  AiJitProcessingService();

  AiRepositoryFactory get _factory =>
      ServiceLocator.getIt<AiRepositoryFactory>();

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
    if (chunk.status == StudyChunkState.completed ||
        chunk.status == StudyChunkState.downloaded) {
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
      final repository = await _factory.createDefault();
      final String responseBody;
      if (fileUri != null && fileMimeType != null) {
        responseBody = await repository.sendMessagesWithFileUri(
          prompt,
          localizations,
          fileUri: fileUri,
          fileMimeType: fileMimeType,
          responseMimeType: 'application/json',
        );
      } else if (originalText != null) {
        final textPrompt = '$prompt\n\nSource text:\n$originalText';
        responseBody = await repository.sendMessages(
          textPrompt,
          localizations,
          responseMimeType: 'application/json',
        );
      } else {
        // Fallback: Generate content using only metadata
        responseBody = await repository.sendMessages(
          '$prompt\n\nNo source text available. Generate based on metadata.',
          localizations,
          responseMimeType: 'application/json',
        );
      }

      final cleanJsonString = _extractJsonFromResponse(responseBody);
      printInDebug('DEBUG JIT AI RESPONSE: $cleanJsonString');
      final parsedData = _parseJsonResponse(cleanJsonString);

      return chunk.copyWith(
        status: StudyChunkState.downloaded,
        aiSummary: parsedData['aiSummary'] as String?,
        pages: parsedData['pages'] as List<StudyPage>?,
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
      final levelName = difficultyLevel.localizedName(localizations);
      difficultyInstruction =
          '\nIMPORTANT: The generated content and study materials MUST be adapted to a $levelName difficulty level. Explain concepts, use vocabulary, and provide examples appropriate for this academic level.';
    } else if (isAutoDifficulty) {
      difficultyInstruction =
          '\nIMPORTANT: The generated content and study materials MUST be adapted to the SAME academic difficulty level, vocabulary, and depth as the provided document.';
    }

    final targetLanguage = language ?? localizations.localeName;

    final studyComponentNames = {
      'section_title',
      'paragraph',
      'key_definition',
      'numbered_list',
      'comparison_table',
      'quote',
      'warning',
      'formula',
      'timeline',
      'pros_cons',
      'key_concepts',
      'reminder',
      'icon_cards',
    };

    final buffer = StringBuffer();
    globalGenUISchemas.forEach((name, schema) {
      if (studyComponentNames.contains(name)) {
        buffer.writeln('- Component Type: "$name"');
        buffer.writeln('  Schema: ${jsonEncode(schema)}');
      }
    });
    final schemasDescription = buffer.toString();

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
    // Array of component objects. Each object MUST have a "type" field (exactly named "type", NOT "component" or "component_type") matching one of the allowed components below, with its specific schema:
$schemasDescription
    // For list/array properties, here are their expected item structures:
    // - "numbered_list" ("items" array): Each item must be a JSON object containing:
    //   - "title": string (the step title)
    //   - "description": string (the step details)
    // - "comparison_table":
    //   - "columns" (array of strings): column headers
    //   - "rows" (array of objects): each object must contain:
    //     - "label": string (row header)
    //     - "values" (array of strings): values corresponding to each column
    // - "timeline" ("items" array): Each item must be a JSON object containing:
    //   - "date": string
    //   - "title": string
    //   - "description": string (optional details)
    // - "pros_cons":
    //   - "pros" (array of strings): list of advantages
    //   - "cons" (array of strings): list of limitations
    // - "key_concepts" ("items" array): Array of strings representing main concepts
    // - "icon_cards" ("items" array): Each item must be a JSON object containing:
    //   - "title": string
    //   - "description": string
  ]
}

Ensure the structure of the JSON is exactly as specified so it can be parsed programmatically. You must only use the allowed component types listed above. Do not invent new types.

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
    dynamic decoded;
    try {
      decoded = jsonDecode(jsonString);
    } on FormatException {
      try {
        final repairedJson = jsonString.repairJsonBrackets();
        decoded = jsonDecode(repairedJson);
        printInDebug('Successfully repaired truncated JIT JSON response!');
      } catch (repairError) {
        rethrow;
      }
    }

    try {
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object.');
      }

      final summary = decoded['ai_summary'] as String?;
      List<StudyPage>? pages;

      // Check both pages (issue #221) and slides (legacy)
      final pagesList =
          (decoded['pages'] ?? decoded['slides']) as List<dynamic>?;
      if (pagesList != null) {
        pages = pagesList
            .map((s) => StudyPage.fromJson(s as Map<String, dynamic>))
            .toList();
      }

      return {'aiSummary': summary, 'pages': pages};
    } catch (e) {
      throw FormatException(
        'Failed to parse AI JSON response: $e\nResponse String: $jsonString',
      );
    }
  }
}
