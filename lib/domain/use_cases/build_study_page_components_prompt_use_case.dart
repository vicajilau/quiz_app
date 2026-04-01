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
import 'package:quizdy/domain/models/ai/ai_difficulty_level.dart';
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';
import 'package:quizdy/domain/models/ai/ai_study_generation_config.dart';
import 'package:quizdy/domain/models/quiz/study_component.dart';

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

    final contentHeader = config.generationMode == AiGenerationMode.topic
        ? 'Topic to cover: ${config.content}'
        : 'Source text:\n${config.content}';

    return '''
You are an expert educational content generator. Generate study components based on the provided content.

IMPORTANT GLOBAL RULE:
ALL generated content MUST be written strictly in the following language: $targetLanguage.
$difficultyInstruction$typeConstraint

Return ONLY a valid JSON array of component objects. Do not include any other text, markdown formatting (like ```json), or explanations.

Each element in the array MUST have a "type" field and its specific required fields. Allowed component types:
1. { "type": "section_title", "title": "Main topic", "subtitle": "Optional context" }
2. { "type": "paragraph", "title": "Optional heading", "body": "Main text block" }
3. { "type": "key_definition", "term": "Vocabulary word/concept", "body": "Clear definition" }
4. { "type": "numbered_list", "title": "Optional heading", "items": [{"title": "Step 1", "description": "Details"}] }
5. { "type": "comparison_table", "title": "Optional", "columns": ["Feature", "A", "B"], "rows": [{"label": "Row 1", "values": ["A val", "B val"]}] }
6. { "type": "quote", "body": "The quote text", "author": "Optional source" }
7. { "type": "warning", "body": "Important caveat or common misconception" }
8. { "type": "formula", "title": "Optional", "equation": "E = mc^2", "equation_label": "Optional name", "body": "Explanation" }
9. { "type": "timeline", "title": "Optional", "items": [{"date": "1990", "title": "Event", "description": "Optional details"}] }
10. { "type": "pros_cons", "items": {"pros": ["Advantage 1"], "cons": ["Disadvantage 1"]} }
11. { "type": "key_concepts", "title": "Optional", "items": ["Concept 1", "Concept 2"] }
12. { "type": "reminder", "body": "A quick tip or study reminder" }
13. { "type": "icon_cards", "title": "Optional", "items": [{"title": "Card title", "description": "Card details"}] }

$contentHeader
''';
  }
}
