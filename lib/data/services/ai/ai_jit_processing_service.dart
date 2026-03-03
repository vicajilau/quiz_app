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
import 'package:quizdy/data/services/ai/gemini_service.dart';
import 'package:quizdy/domain/models/quiz/slide.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';

/// Service responsible for Just-In-Time (JIT) processing of study chunks.
class AiJitProcessingService {
  static AiJitProcessingService? _instance;

  /// Singleton instance
  static AiJitProcessingService get instance =>
      _instance ??= AiJitProcessingService._();

  AiJitProcessingService._();

  /// Processes a [StudyChunk] on-demand to generate its AI summary and UI slides.
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
    required String fileUri,
    required String fileMimeType,
    required AppLocalizations localizations,
  }) async {
    // We only process chunks that have not been successfully processed yet.
    if (chunk.status == StudyChunkState.completed) {
      return chunk;
    }

    // Safety layer to protect against AI hallucinations extending offsets beyond the document length
    final startPage = chunk.sourceReference.startPage;
    final endPage = chunk.sourceReference.endPage;

    final prompt = _buildSystemPrompt(startPage, endPage, localizations);

    try {
      final responseBody = await GeminiService.instance
          .getChatResponseWithFileUri(
            prompt,
            localizations,
            fileUri: fileUri,
            fileMimeType: fileMimeType,
            responseMimeType: 'application/json',
          );

      final cleanJsonString = _extractJsonFromResponse(responseBody);
      final parsedData = _parseJsonResponse(cleanJsonString);

      return chunk.copyWith(
        status: StudyChunkState.completed,
        aiSummary: parsedData['aiSummary'] as String?,
        slides: parsedData['slides'] as List<Slide>?,
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
    AppLocalizations localizations,
  ) {
    return '''
You are an expert educational content generator. Your task is to analyze the provided pages of the document and generate study material for them.

IMPORTANT: Focus ONLY on the content found between pages $startPage and $endPage (inclusive).
IMPORTANT: All generated content (ai_summary, slide texts, titles, paragraphs) MUST be written in the following language: ${localizations.localeName}. Do NOT use English unless the target language is English.

Important Output Instructions:
- If the provided text contains a Table of Contents (TOC), completely ignore it and do not generate study elements for the TOC itself.
- If the provided text consists mostly of exercises, questions, or problems, you MUST generate the prerequisite theoretical content, explanations, and concepts necessary to understand and solve those exercises, rather than simply listing or summarizing the exercises themselves.

You must return the result ONLY as a valid JSON object. Do not include any other text, markdown formatting (like ```json), or explanations.

The output MUST be a JSON object with two fields:
1. "ai_summary": A string containing a concise and clear summary of the provided text.
2. "slides": A JSON array of "Slide" objects designed for an interactive learning UI.

Each Slide object in the "slides" array must have the following schema:
{
  "ui_elements": [
    {
      "component_type": <string, the type of UI component, e.g., "Title", "Paragraph", "Highlight">,
      "props": {
        // Key-value pairs of properties for this element, e.g.,
        "text": <string, the content to display>
      }
    }
  ]
}

Ensure the structure of the JSON is exactly as specified so it can be parsed programmatically.

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

  /// Parses the raw JSON object string into the summary and slides mapping.
  Map<String, dynamic> _parseJsonResponse(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object.');
      }

      final summary = decoded['ai_summary'] as String?;
      List<Slide>? slides;

      if (decoded['slides'] != null && decoded['slides'] is List) {
        final slidesList = decoded['slides'] as List<dynamic>;
        slides = slidesList
            .map((s) => Slide.fromJson(s as Map<String, dynamic>))
            .toList();
      }

      return {'aiSummary': summary, 'slides': slides};
    } catch (e) {
      throw FormatException(
        'Failed to parse AI JSON response: $e\nResponse String: $jsonString',
      );
    }
  }
}
