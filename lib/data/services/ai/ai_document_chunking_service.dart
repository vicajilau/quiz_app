// Copyright (C) 2026 Víctor Carreras
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

import 'package:quizdy/core/l10n/app_localizations.dart';
import 'dart:convert';
import 'package:quizdy/data/services/ai/ai_service.dart';
import 'package:quizdy/domain/models/quiz/source_reference.dart';

class _TextBatch {
  final String text;
  final int baseOffset;

  const _TextBatch({required this.text, required this.baseOffset});
}

/// Service responsible for parsing documents into semantic chunks locally.
class AiDocumentChunkingService {
  AiDocumentChunkingService();

  /// Identifies structural chunks within a document locally.
  ///
  /// Splits the text iteratively in ~3000 character bursts suitable for
  /// later Just-In-Time semantic processing while avoiding UI locks.
  ///
  /// - [documentText]: The full text extracted from the document.
  /// - [documentId]: A unique identifier for the document.
  /// - [localizations]: Localization bundle for default names.
  /// - Returns: A mapped global list of `SourceReference` indicating the text slices.
  Future<List<SourceReference>> chunkDocument(
    String documentText,
    String documentId,
    AppLocalizations localizations,
  ) async {
    const maxCharsPerBatch = 3000;
    List<SourceReference> allReferences = [];
    int currentGlobalOffset = 0;
    final int textLength = documentText.length;

    int currentIteration = 0;

    while (currentGlobalOffset < textLength) {
      currentIteration++;

      final batch = _getNextBatch(
        documentText,
        currentGlobalOffset,
        maxCharsPerBatch,
      );

      final reference = SourceReference(
        documentId: documentId,
        startOffset: batch.baseOffset,
        endOffset: batch.baseOffset + batch.text.length,
        startPage:
            1, // Will be mapped later if PDF layout is supported natively
        endPage: 1,
        blockType: 'Section $currentIteration', // Generic initial state
      );

      allReferences.add(reference);

      // Safety advance minimum 1 character to avoid infinite loops if breakIndex matches start
      currentGlobalOffset =
          batch.baseOffset + (batch.text.isNotEmpty ? batch.text.length : 1);
    }

    return allReferences;
  }

  /// Generates logical chunks using AI analysis of the document.
  ///
  /// Returns a map with:
  /// - `references`: list of [SourceReference] of identified chunks
  /// - `title`: AI-generated document title
  /// - `description`: AI-generated document description
  Future<Map<String, dynamic>> generateIndexWithAi({
    required AIService aiService,
    required String fileUri,
    required String fileMimeType,
    required String documentId,
    required AppLocalizations localizations,
    String? extraContext,
  }) async {
    try {
      final jsonResponse = await aiService.generateStudyIndex(
        localizations,
        fileUri: fileUri,
        fileMimeType: fileMimeType,
        extraContext: extraContext,
      );

      // Clean the response if it contains markdown code blocks
      String cleanedJson = jsonResponse.trim();
      if (cleanedJson.startsWith('```json')) {
        cleanedJson = cleanedJson.substring(7, cleanedJson.length - 3).trim();
      } else if (cleanedJson.startsWith('```')) {
        cleanedJson = cleanedJson.substring(3, cleanedJson.length - 3).trim();
      }

      final decoded = jsonDecode(cleanedJson);

      // Support both new format (object with title/description/chapters)
      // and legacy format (plain array)
      final String? title;
      final String? description;
      final List<dynamic> chapters;

      if (decoded is Map<String, dynamic>) {
        title = decoded['title'] as String?;
        description = decoded['description'] as String?;
        chapters = decoded['chapters'] as List<dynamic>? ?? [];
      } else if (decoded is List) {
        title = null;
        description = null;
        chapters = decoded;
      } else {
        throw const FormatException('Unexpected JSON format');
      }

      final references = chapters.map((item) {
        return SourceReference(
          documentId: documentId,
          startPage: item['startPage'] ?? 1,
          endPage: item['endPage'] ?? 1,
          startOffset: 0,
          endOffset: 0,
          blockType: item['title'] ?? 'Generic Section',
        );
      }).toList();

      return {
        'references': references,
        'title': title,
        'description': description,
      };
    } catch (e) {
      rethrow;
      /* Testing purposes
      return {
        'references': List.generate(
          4,
          (_) => SourceReference(
            documentId: documentId,
            startPage: 1,
            endPage: 1,
            startOffset: 0,
            endOffset: 0,
            blockType: 'Full Document',
          ),
        ),
        'title': null,
        'description': null,
      };
      */
    }
  }

  /// Generates logical chunks from text content using AI.
  Future<Map<String, dynamic>> generateIndexFromTextWithAi({
    required AIService aiService,
    required String content,
    required bool isTopicMode,
    required String documentId,
    required AppLocalizations localizations,
  }) async {
    try {
      final jsonResponse = await aiService.generateStudyIndexFromText(
        localizations,
        content: content,
        isTopicMode: isTopicMode,
      );

      // Clean the response if it contains markdown code blocks
      String cleanedJson = jsonResponse.trim();
      if (cleanedJson.startsWith('```json')) {
        cleanedJson = cleanedJson.substring(7, cleanedJson.length - 3).trim();
      } else if (cleanedJson.startsWith('```')) {
        cleanedJson = cleanedJson.substring(3, cleanedJson.length - 3).trim();
      }

      final decoded = jsonDecode(cleanedJson);

      final String? title;
      final String? description;
      final List<dynamic> chapters;

      if (decoded is Map<String, dynamic>) {
        title = decoded['title'] as String?;
        description = decoded['description'] as String?;
        chapters = decoded['chapters'] as List<dynamic>? ?? [];
      } else if (decoded is List) {
        title = null;
        description = null;
        chapters = decoded;
      } else {
        throw const FormatException('Unexpected JSON format');
      }

      final references = chapters.map((item) {
        return SourceReference(
          documentId: documentId,
          startPage: 1,
          endPage: 1,
          startOffset: 0,
          endOffset: 0,
          blockType: item['title'] ?? 'Generic Section',
        );
      }).toList();

      return {
        'references': references,
        'title': title,
        'description': description,
      };
    } catch (e) {
      rethrow;
    }
  }

  _TextBatch _getNextBatch(String text, int startOffset, int maxChars) {
    final textLength = text.length;

    if (textLength - startOffset <= maxChars) {
      return _TextBatch(
        text: text.substring(startOffset),
        baseOffset: startOffset,
      );
    }

    int end = startOffset + maxChars;

    // Ensure we do not slice words or paragraphs aggressively if feasible
    int breakIndex = text.lastIndexOf('\n\n', end);
    if (breakIndex <= startOffset) breakIndex = text.lastIndexOf('\n', end);
    if (breakIndex <= startOffset) breakIndex = text.lastIndexOf('. ', end);
    if (breakIndex <= startOffset) breakIndex = text.lastIndexOf(' ', end);
    if (breakIndex <= startOffset) {
      breakIndex = end; // Last resort hard-cut limit
    }

    // In the case of paragraphs/sentences dot, we want to include the separator itself
    if (breakIndex != end &&
        text[breakIndex] == '.' &&
        text.length > breakIndex + 1 &&
        text[breakIndex + 1] == ' ') {
      breakIndex += 1; // Include the period
    } else if (breakIndex != end && text[breakIndex] == '\n') {
      breakIndex += 1; // Include newline
    }

    // Do NOT trim here. Trimming the front alters the relative offset index!
    return _TextBatch(
      text: text.substring(startOffset, breakIndex),
      baseOffset: startOffset,
    );
  }
}
