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
import 'package:quizdy/domain/models/quiz/ui_element.dart';

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
  final UiElement element;

  const StudyComponentBuilder({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    switch (element.componentType) {
      case 'section_title':
      case 'Title': // Legacy support
        return SectionTitleComponent(element: element);
      case 'paragraph':
        return ParagraphComponent(element: element);
      case 'key_definition':
        return KeyDefinitionComponent(element: element);
      case 'numbered_list':
        return NumberedListComponent(element: element);
      case 'comparison_table':
        return ComparisonTableComponent(element: element);
      case 'quote':
        return QuoteComponent(element: element);
      case 'warning':
        return WarningComponent(element: element);
      case 'formula':
        return FormulaComponent(element: element);
      case 'timeline':
        return TimelineComponent(element: element);
      case 'pros_cons':
        return ProsConsComponent(element: element);
      case 'key_concepts':
        return KeyConceptsComponent(element: element);
      case 'reminder':
        return ReminderComponent(element: element);
      case 'icon_cards':
        return IconCardsComponent(element: element);
      default:
        // Fallback for unknown component types that might have 'text' or 'body'
        final text =
            element.props['text']?.toString() ??
            element.props['body']?.toString();
        if (text != null && text.isNotEmpty) {
          return ParagraphComponent(
            element: element.copyWith(
              componentType: 'paragraph',
              props: {'body': text},
            ),
          );
        }
        return const SizedBox.shrink();
    }
  }
}
