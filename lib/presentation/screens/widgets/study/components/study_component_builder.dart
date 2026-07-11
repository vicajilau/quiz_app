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
        return SectionTitleComponent(
          title: element.props['title']?.toString() ?? '',
          subtitle: element.props['subtitle']?.toString(),
        );
      case StudyComponentType.paragraph:
        return ParagraphComponent(
          title: element.props['title']?.toString(),
          body: element.props['body']?.toString() ?? '',
        );
      case StudyComponentType.keyDefinition:
        return KeyDefinitionComponent(
          term: element.props['term']?.toString() ?? '',
          body: element.props['body']?.toString() ?? '',
        );
      case StudyComponentType.numberedList:
        return NumberedListComponent(
          title: element.props['title']?.toString(),
          items: element.props['items'] as List<dynamic>? ?? const [],
        );
      case StudyComponentType.comparisonTable:
        return ComparisonTableComponent(
          title: element.props['title']?.toString(),
          columns: element.props['columns'] as List<dynamic>? ?? const [],
          rows: element.props['rows'] as List<dynamic>? ?? const [],
          labelHeader: element.props['labelHeader']?.toString(),
        );
      case StudyComponentType.quote:
        return QuoteComponent(
          body: element.props['body']?.toString() ?? '',
          author: element.props['author']?.toString(),
        );
      case StudyComponentType.warning:
        return WarningComponent(body: element.props['body']?.toString() ?? '');
      case StudyComponentType.formula:
        return FormulaComponent(
          title: element.props['title']?.toString(),
          equation: element.props['equation']?.toString() ?? '',
          equationLabel:
              element.props['equationLabel']?.toString() ??
              element.props['equation_label']?.toString(),
          body: element.props['body']?.toString(),
        );
      case StudyComponentType.timeline:
        return TimelineComponent(
          title: element.props['title']?.toString(),
          items: element.props['items'] as List<dynamic>? ?? const [],
        );
      case StudyComponentType.prosCons:
        final itemsMap = element.props['items'];
        final pros =
            (element.props['pros'] as List<dynamic>?) ??
            (itemsMap is Map ? itemsMap['pros'] as List<dynamic>? : null) ??
            const [];
        final cons =
            (element.props['cons'] as List<dynamic>?) ??
            (itemsMap is Map ? itemsMap['cons'] as List<dynamic>? : null) ??
            const [];
        return ProsConsComponent(pros: pros, cons: cons);
      case StudyComponentType.keyConcepts:
        return KeyConceptsComponent(
          title: element.props['title']?.toString(),
          items: element.props['items'] as List<dynamic>? ?? const [],
        );
      case StudyComponentType.reminder:
        return ReminderComponent(body: element.props['body']?.toString() ?? '');
      case StudyComponentType.iconCards:
        return IconCardsComponent(
          title: element.props['title']?.toString(),
          items: element.props['items'] as List<dynamic>? ?? const [],
        );
    }
  }
}
