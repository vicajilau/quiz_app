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

/// Represents the academic difficulty level for AI question generation.
enum AiDifficultyLevel {
  elementary,
  highSchool,
  bachelors,
  university,
  masters,
  doctorate,
}

extension AiDifficultyLevelLocalization on AiDifficultyLevel {
  /// Returns the localized display name for this difficulty level.
  String localizedName(AppLocalizations localizations) => switch (this) {
    AiDifficultyLevel.elementary => localizations.aiDifficultyElementary,
    AiDifficultyLevel.highSchool => localizations.aiDifficultyHighSchool,
    AiDifficultyLevel.bachelors => localizations.aiDifficultyBachelors,
    AiDifficultyLevel.university => localizations.aiDifficultyUniversity,
    AiDifficultyLevel.masters => localizations.aiDifficultyMasters,
    AiDifficultyLevel.doctorate => localizations.aiDifficultyDoctorate,
  };
}
