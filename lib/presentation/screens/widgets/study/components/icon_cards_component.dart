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
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/domain/models/quiz/ui_element.dart';
import 'package:quizdy/presentation/widgets/latex_text.dart';
import 'package:quizdy/presentation/screens/widgets/common/markdown_widget.dart';
import 'package:quizdy/core/theme/extensions/study_theme_extension.dart';

class IconCardsComponent extends StatelessWidget {
  final UiElement element;

  const IconCardsComponent({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final title = element.props['title']?.toString();
    final itemsList = element.props['items'] as List<dynamic>? ?? [];
    final studyTheme = context.studyTheme;

    final items = itemsList.map((item) {
      if (item is Map<String, dynamic>) {
        return {
          'title': item['title']?.toString() ?? '',
          'description': item['description']?.toString() ?? '',
        };
      }
      return {'title': item.toString(), 'description': ''};
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title.isNotEmpty) ...[
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: studyTheme.cardTitle,
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Using a Wrap to allow responsive grid-like layout
          Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: items.map((item) {
              final itemTitle = item['title'] as String;
              final itemDesc = item['description'] as String;

              return LayoutBuilder(
                builder: (context, constraints) {
                  // Make cards take about half width on larger screens, full width on small screens
                  double width = constraints.maxWidth;
                  if (!context.isMobile) {
                    width = (width / 2) - 8; // -8 for spacing
                  }

                  return Container(
                    width: width,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: studyTheme.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: studyTheme.cardBorder,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (itemTitle.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                LucideIcons.chevronRightSquare,
                                color: Theme.of(context).primaryColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: LaTeXText(
                                  itemTitle,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: studyTheme.cardTitle,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        if (itemTitle.isNotEmpty && itemDesc.isNotEmpty)
                          const SizedBox(height: 12),
                        if (itemDesc.isNotEmpty) MarkdownWidget(data: itemDesc),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
