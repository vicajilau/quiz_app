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

class AiStudyGenerationStoredSettings {
  final String? modelName;
  final String? language;
  final String? draftText;
  final bool? isAutoDifficulty;
  final AiDifficultyLevel? difficultyLevel;

  const AiStudyGenerationStoredSettings({
    this.modelName,
    this.language,
    this.draftText,
    this.isAutoDifficulty,
    this.difficultyLevel,
  });
}
