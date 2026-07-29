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
import 'package:quizdy/domain/models/ai/ai_difficulty_level.dart';
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';
import 'package:quizdy/domain/models/ai/ai_study_generation_config.dart';
import 'package:quizdy/domain/models/quiz/study_component.dart';
import 'package:quizdy/genui_registry.g.dart';

/// Assembles the prompt used to generate [StudyComponent] arrays for a
/// single study page.
///
/// The produced string is ready to be sent directly to
/// [AiRepository.sendMessages] or [AiRepository.sendMessagesWithFile].
abstract final class BuildStudyPageComponentsPromptUseCase {
  /// Builds the prompt from an [AiStudyGenerationConfig].
  static String build(
    AiStudyGenerationConfig config,
    AppLocalizations localizations,
  ) {
    final targetLanguage = config.language;

    String difficultyInstruction = '';
    if (!config.isAutoDifficulty && config.difficultyLevel != null) {
      final levelName = config.difficultyLevel!.localizedName(localizations);
      difficultyInstruction =
          '\nIMPORTANT: The content MUST be adapted to a $levelName difficulty level.';
    } else if (config.isAutoDifficulty) {
      difficultyInstruction =
          '\nIMPORTANT: Adapt the content difficulty to match the provided material.';
    }

    final allowedTypes = config.allowedComponentTypes;
    final typeConstraint = allowedTypes != null
        ? '\nIMPORTANT: You MUST ONLY use the following component types: '
              '${allowedTypes.map((t) => t.name).join(', ')}. Do not use any other types.'
        : '';

    final String contentHeader;
    if (config.hasChunks) {
      final buffer = StringBuffer('Source document sections:\n');
      for (var i = 0; i < config.selectedChunks!.length; i++) {
        final chunk = config.selectedChunks![i];
        final title = chunk.sourceReference.blockType.isNotEmpty
            ? chunk.sourceReference.blockType
            : 'Section ${i + 1}';
        buffer.writeln('Section ${i + 1}: $title');
        if (chunk.aiSummary != null && chunk.aiSummary!.isNotEmpty) {
          buffer.writeln('Summary: ${chunk.aiSummary}');
        }
      }
      contentHeader = buffer.toString().trim();
    } else if (config.generationMode == AiGenerationMode.topic) {
      contentHeader = 'Topic to cover: ${config.content}';
    } else {
      contentHeader = 'Source text:\n${config.content}';
    }

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
You are an expert educational content generator. Generate study components based on the provided content.

IMPORTANT GLOBAL RULE:
ALL generated content MUST be written strictly in the following language: $targetLanguage.
$difficultyInstruction$typeConstraint

Return ONLY a valid JSON array of component objects. Do not include any other text, markdown formatting (like ```json), or explanations.

Each element in the array MUST have a "type" field (exactly named "type", NOT "component" or "component_type") matching one of the allowed components below, with its specific schema:

$schemasDescription
For list/array properties, here are their expected item structures:
- "numbered_list" ("items" array): Each item must be a JSON object containing:
  - "title": string (the step title)
  - "description": string (the step details)
- "comparison_table":
  - "columns" (array of strings): column headers
  - "rows" (array of objects): each object must contain:
    - "label": string (row header)
    - "values" (array of strings): values corresponding to each column
- "timeline" ("items" array): Each item must be a JSON object containing:
  - "date": string
  - "title": string
  - "description": string (optional details)
- "pros_cons":
  - "pros" (array of strings): list of advantages
  - "cons" (array of strings): list of limitations
- "key_concepts" ("items" array): Array of strings representing main concepts
- "icon_cards" ("items" array): Each item must be a JSON object containing:
  - "title": string
  - "description": string

$contentHeader
''';
  }
}
