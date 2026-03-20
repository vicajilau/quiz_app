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

import 'package:flutter/material.dart';
import 'package:quizdy/domain/models/quiz/study_component.dart';

import 'package:quizdy/presentation/screens/widgets/study/components/section_title_component.dart';
import 'package:quizdy/presentation/screens/widgets/study/components/paragraph_component.dart';
import 'package:quizdy/presentation/screens/widgets/study/components/key_definition_component.dart';
import 'package:quizdy/presentation/screens/widgets/study/components/numbered_list_component.dart';
import 'package:quizdy/presentation/screens/widgets/study/components/comparison_table_component.dart';
import 'package:quizdy/presentation/screens/widgets/study/components/quote_component.dart';
import 'package:quizdy/presentation/screens/widgets/study/components/warning_component.dart';
import 'package:quizdy/presentation/screens/widgets/study/components/formula_component.dart';
import 'package:quizdy/presentation/screens/widgets/study/components/timeline_component.dart';
import 'package:quizdy/presentation/screens/widgets/study/components/pros_cons_component.dart';
import 'package:quizdy/presentation/screens/widgets/study/components/key_concepts_component.dart';
import 'package:quizdy/presentation/screens/widgets/study/components/reminder_component.dart';
import 'package:quizdy/presentation/screens/widgets/study/components/icon_cards_component.dart';

class StudyComponentBuilder extends StatelessWidget {
  final StudyComponent element;

  const StudyComponentBuilder({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    switch (element.componentType) {
      case StudyComponentType.sectionTitle:
        return SectionTitleComponent(element: element);
      case StudyComponentType.paragraph:
        return ParagraphComponent(element: element);
      case StudyComponentType.keyDefinition:
        return KeyDefinitionComponent(element: element);
      case StudyComponentType.numberedList:
        return NumberedListComponent(element: element);
      case StudyComponentType.comparisonTable:
        return ComparisonTableComponent(element: element);
      case StudyComponentType.quote:
        return QuoteComponent(element: element);
      case StudyComponentType.warning:
        return WarningComponent(element: element);
      case StudyComponentType.formula:
        return FormulaComponent(element: element);
      case StudyComponentType.timeline:
        return TimelineComponent(element: element);
      case StudyComponentType.prosCons:
        return ProsConsComponent(element: element);
      case StudyComponentType.keyConcepts:
        return KeyConceptsComponent(element: element);
      case StudyComponentType.reminder:
        return ReminderComponent(element: element);
      case StudyComponentType.iconCards:
        return IconCardsComponent(element: element);
    }
  }
}
