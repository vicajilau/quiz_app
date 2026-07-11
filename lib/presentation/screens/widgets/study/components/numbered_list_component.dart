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
import 'package:genui/genui.dart';
import 'package:genui_annotations/genui_annotations.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:quizdy/presentation/widgets/quizdy_markdown.dart';
import 'package:quizdy/core/theme/extensions/study_theme_extension.dart';

part 'numbered_list_component.genui.g.dart';

@GenerativeUI(name: 'numbered_list')
class NumberedListComponent extends StatelessWidget {
  final String? title;
  final List<dynamic> items;

  const NumberedListComponent({super.key, this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    final itemsList = items;
    final studyTheme = context.studyTheme;

    // Parse items into a structured format
    final parsedItems = itemsList.map((item) {
      if (item is Map<String, dynamic>) {
        return {
          'title': item['title']?.toString() ?? '',
          'description': item['description']?.toString() ?? '',
        };
      }
      return {'title': item.toString(), 'description': ''};
    }).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: studyTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: studyTheme.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  LucideIcons.list_ordered,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: studyTheme.cardTitle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: studyTheme.cardDivider),
            const SizedBox(height: 16),
          ],
          ...parsedItems.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final item = entry.value;
            final itemTitle = item['title'] as String;
            final itemDesc = item['description'] as String;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (itemTitle.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              itemTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: studyTheme.cardTitle,
                              ),
                            ),
                          ),
                        if (itemDesc.isNotEmpty) ...[
                          if (itemTitle.isNotEmpty) const SizedBox(height: 4),
                          QuizdyMarkdown(data: itemDesc),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
