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
import 'package:quizdy/domain/models/quiz/study_component.dart';

extension StudyExtension on StudyComponentType {
  /// Provides a user-friendly display name for each `ComponentType`.
  String displayName(AppLocalizations localizations) {
    switch (this) {
      case StudyComponentType.sectionTitle:
        return localizations.componentTypeSectionTitle;
      case StudyComponentType.paragraph:
        return localizations.componentTypeParagraph;
      case StudyComponentType.keyDefinition:
        return localizations.componentTypeKeyDefinition;
      case StudyComponentType.numberedList:
        return localizations.componentTypeNumberedList;
      case StudyComponentType.comparisonTable:
        return localizations.componentTypeComparisonTable;
      case StudyComponentType.quote:
        return localizations.componentTypeQuote;
      case StudyComponentType.warning:
        return localizations.componentTypeWarning;
      case StudyComponentType.formula:
        return localizations.componentTypeFormula;
      case StudyComponentType.timeline:
        return localizations.componentTypeTimeline;
      case StudyComponentType.prosCons:
        return localizations.componentTypeProsCons;
      case StudyComponentType.keyConcepts:
        return localizations.componentTypeKeyConcepts;
      case StudyComponentType.reminder:
        return localizations.componentTypeReminder;
      case StudyComponentType.iconCards:
        return localizations.componentTypeIconCards;
    }
  }
}
