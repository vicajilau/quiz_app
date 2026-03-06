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

import 'package:quizdy/domain/models/quiz/study_content.dart';
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';
import 'package:quizdy/domain/models/ai/ai_difficulty_level.dart';

/// Wraps the overall study section mapped to the JSON schema.
class Study {
  /// The interactive study sequence content associated with the Quiz file.
  final StudyContent content;

  /// The AI generation mode used to create this study.
  final AiGenerationMode? generationMode;

  /// The original text content drafted to generate this study.
  final String? originalText;

  /// The target language for the study material.
  final String? language;

  /// Whether the difficulty should automatically adapt to the provided content.
  final bool isAutoDifficulty;

  /// The academic difficulty level for this study.
  final AiDifficultyLevel? difficultyLevel;

  /// Constructor for a `Study`.
  const Study({
    required this.content,
    this.generationMode,
    this.originalText,
    this.language,
    this.isAutoDifficulty = true,
    this.difficultyLevel,
  });

  /// Creates a `Study` instance from a JSON map.
  ///
  /// - [json]: The JSON map containing the study block data.
  /// - Returns: A populated `Study` instance.
  factory Study.fromJson(Map<String, dynamic> json) {
    final generationModeStr = json['generationMode'] as String?;
    final generationMode = generationModeStr != null
        ? AiGenerationMode.values.firstWhere(
            (e) => e.name == generationModeStr,
            orElse: () => AiGenerationMode.text,
          )
        : null;

    final difficultyLevelStr = json['difficultyLevel'] as String?;
    final difficultyLevel = difficultyLevelStr != null
        ? AiDifficultyLevel.values.firstWhere(
            (e) => e.name == difficultyLevelStr,
            orElse: () => AiDifficultyLevel.university,
          )
        : null;

    return Study(
      content: StudyContent.fromJson(
        json['content'] as Map<String, dynamic>? ?? {},
      ),
      generationMode: generationMode,
      originalText: json['originalText'] as String?,
      language: json['language'] as String?,
      isAutoDifficulty: json['isAutoDifficulty'] as bool? ?? true,
      difficultyLevel: difficultyLevel,
    );
  }

  /// Converts the `Study` instance to a JSON map.
  ///
  /// - Returns: A JSON map representation.
  Map<String, dynamic> toJson() {
    return {
      'content': content.toJson(),
      if (generationMode != null) 'generationMode': generationMode!.name,
      if (originalText != null) 'originalText': originalText,
      if (language != null) 'language': language,
      'isAutoDifficulty': isAutoDifficulty,
      if (difficultyLevel != null) 'difficultyLevel': difficultyLevel!.name,
    };
  }

  /// Creates a copy of the `Study` with optional parameter modifications.
  Study copyWith({
    StudyContent? content,
    AiGenerationMode? generationMode,
    String? originalText,
    String? language,
    bool? isAutoDifficulty,
    AiDifficultyLevel? difficultyLevel,
  }) {
    return Study(
      content: content ?? this.content.copyWith(),
      generationMode: generationMode ?? this.generationMode,
      originalText: originalText ?? this.originalText,
      language: language ?? this.language,
      isAutoDifficulty: isAutoDifficulty ?? this.isAutoDifficulty,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Study &&
        other.content == content &&
        other.generationMode == generationMode &&
        other.originalText == originalText &&
        other.language == language &&
        other.isAutoDifficulty == isAutoDifficulty &&
        other.difficultyLevel == difficultyLevel;
  }

  @override
  int get hashCode =>
      content.hashCode ^
      generationMode.hashCode ^
      originalText.hashCode ^
      language.hashCode ^
      isAutoDifficulty.hashCode ^
      difficultyLevel.hashCode;

  @override
  String toString() =>
      'Study(content: $content, generationMode: $generationMode, originalText: $originalText, language: $language, isAutoDifficulty: $isAutoDifficulty, difficultyLevel: $difficultyLevel)';
}
