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

import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';
import 'package:quizdy/domain/models/quiz/question.dart';

/// Assembles the prompt text used for AI-powered study-index generation.
///
/// This use case produces a ready-to-send string that callers pass directly
/// to [AiRepository.sendMessagesWithFileUri] or [AiRepository.sendMessages],
/// keeping all prompt knowledge in the domain layer.
abstract final class BuildStudyIndexPromptUseCase {
  /// Builds the prompt for generating a study index from an already-uploaded
  /// file referenced by its remote URI.
  ///
  /// - [language]: Target language for all JSON output fields.
  /// - [extraContext]: Optional free-text instructions from the user.
  static String buildFromFile({
    required String language,
    String? extraContext,
  }) {
    final commentsSection =
        extraContext != null && extraContext.trim().isNotEmpty
        ? '\nADDITIONAL INSTRUCTIONS/CONTEXT FROM THE USER:\n$extraContext\n'
        : '';

    return '''
Act as an expert academic educator. Analyze the provided document $commentsSection and generate a structured study guide with a Table of Contents for a personalized study plan.

IMPORTANT GLOBAL RULE:
ALL fields in the JSON output (title, description, chapter titles, summaries) MUST be written strictly in the following language: $language.

Rules:
1. Generate a concise title that summarizes the subject matter of the syllabus. Do NOT reference the document itself (e.g. avoid "Document about...", "This PDF covers..."). Just state the topic directly.
2. Generate a brief description (2-3 sentences) explaining the syllabus content and its key learning objectives. Write it as if describing the subject, not the document.
3. Divide the content into logical "Themes" or "Chapters" (chunks).
4. Each theme should be granular enough to be studied in a single session.
5. If a section is very long, break it down into sub-themes.
6. For each theme, identify the start and end page (if the document has pages/is a PDF). If not, use estimated percentages or indices.
7. High Priority: Chunks should feel like an index of a book.
8. Themes should be logically treated as the main units of study.
9. Output ONLY a valid JSON object with this structure:
{
  "title": "Subject Title",
  "description": "Brief 2-3 sentence description of the syllabus and learning objectives.",
  "chapters": [
    {
      "title": "Theme Title",
      "startPage": 1,
      "endPage": 3,
      "summary": "Brief 1-sentence description of the topic covered. Do not reference the document."
    }
  ]
}
''';
  }

  /// Builds the prompt for generating a study index from plain text or topics
  /// (no file involved).
  ///
  /// - [content]: The raw text or comma-separated topics.
  /// - [generationMode]: Whether [content] is a topic list or free text.
  /// - [language]: Target language for all JSON output fields.
  /// - [selectedQuestions]: Optional questions used as generation context.
  static String buildFromText({
    required String content,
    required AiGenerationMode generationMode,
    required String language,
    List<Question>? selectedQuestions,
  }) {
    final header = selectedQuestions != null && selectedQuestions.isNotEmpty
        ? '''
IMPORTANT: JUST ANSWER THE JSON MENTIONED IN THE RULES
The user wants a personalized study plan based on the following selected quiz questions:

${_buildSelectedQuestionsContent(selectedQuestions)}

Use these questions to infer the concepts, topics, skills, and knowledge areas that should be covered in the study plan.
'''
        : generationMode == AiGenerationMode.topic
        ? 'The user wants a personalized study plan about the following topic/s: $content'
        : 'The user has provided the following text for creating a study plan:\n\n$content';

    return '''
IMPORTANT: JUST ANSWER THE JSON MENTIONED IN THE RULES
Act as an expert academic educator. $header

Analyze the content and generate a structured study guide with a Table of Contents for a personalized study plan.

IMPORTANT GLOBAL RULE:
ALL fields in the JSON output (title, description, chapter titles, summaries) MUST be written strictly in the following language: $language.

Rules:
1. Generate a concise title that summarizes the subject matter.
2. Generate a brief description (2-3 sentences) explaining the syllabus content and its key learning objectives.
3. Divide the content into logical "Themes" or "Chapters" (chunks).
4. Each theme should be granular enough to be studied in a single session.
5. Themes should be logically treated as the main units of study.
6. Output ONLY a valid JSON object with this structure:
{
  "title": "Subject Title",
  "description": "Brief 2-3 sentence description of the syllabus and learning objectives.",
  "chapters": [
    {
      "title": "Theme Title",
      "summary": "Brief 1-sentence description of the topic covered."
    }
  ]
}
''';
  }

  static String _buildSelectedQuestionsContent(List<Question> questions) {
    final buffer = StringBuffer();
    for (var i = 0; i < questions.length; i++) {
      final question = questions[i];
      buffer.writeln('Question ${i + 1}: ${question.text}');
      if (question.options.isNotEmpty) {
        buffer.writeln('Options:');
        for (final option in question.options) {
          buffer.writeln('- $option');
        }
      }
      if (question.explanation.isNotEmpty) {
        buffer.writeln('Explanation: ${question.explanation}');
      }
      buffer.writeln();
    }
    return buffer.toString().trim();
  }
}
