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

import 'package:quizdy/domain/models/ai/ai_difficulty_level.dart';
import 'package:quizdy/domain/models/ai/ai_generation_category.dart';

/// DTO representing the saved settings for AI question generation.
class AiGenerationStoredSettings {
  /// The name of the selected model for generation.
  final String? modelName;

  /// The language code selected for generation.
  final String? language;

  /// The number of questions to generate.
  final int? questionCount;

  /// The list of selected question types.
  final List<String>? questionTypes;

  /// The drafted text content.
  final String? draftText;

  /// The attached file path.
  final String? draftFilePath;

  /// Whether automatic difficulty is enabled.
  final bool? isAutoDifficulty;

  /// The selected manual difficulty level.
  final AiDifficultyLevel? difficultyLevel;

  /// The saved content mode (category).
  final AiGenerationCategory? category;

  /// Creates a new instance of [AiGenerationStoredSettings].
  const AiGenerationStoredSettings({
    this.modelName,
    this.language,
    this.questionCount,
    this.questionTypes,
    this.draftText,
    this.draftFilePath,
    this.isAutoDifficulty,
    this.difficultyLevel,
    this.category,
  });
}
