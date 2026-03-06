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

import 'package:quizdy/data/services/ai/ai_service.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/domain/models/ai/ai_difficulty_level.dart';

import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';

/// Configuration settings for AI-powered interactive Study Mode generation.
class AiStudyGenerationConfig {
  /// The target language for the generated study material.
  final String language;

  /// The source text or topic description to generate study chunks from.
  final String content;

  /// The preferred AI service provider (e.g., OpenAI, Gemini).
  final AIService? preferredService;

  /// The specific model version to use for the selected AI service.
  final String? preferredModel;

  /// Optional file attachment containing source material.
  final AiFileAttachment? file;

  /// The modality of AI generation.
  final AiGenerationMode generationMode;

  /// Whether the difficulty should automatically adapt to the provided content.
  final bool isAutoDifficulty;

  /// The specific academic difficulty level when manual mode is selected.
  final AiDifficultyLevel? difficultyLevel;

  /// Returns true if a file is attached to this configuration.
  bool get hasFile => file != null;

  const AiStudyGenerationConfig({
    required this.language,
    required this.content,
    this.preferredService,
    this.preferredModel,
    this.file,
    this.generationMode = AiGenerationMode.text,
    this.isAutoDifficulty = true,
    this.difficultyLevel,
  });
}
