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
import 'package:quizdy/domain/models/quiz/ui_element.dart';
import 'package:quizdy/presentation/widgets/latex_text.dart';
import 'package:quizdy/presentation/screens/widgets/common/markdown_widget.dart';
import 'package:quizdy/core/theme/extensions/study_theme_extension.dart';

class TimelineComponent extends StatelessWidget {
  final UiElement element;

  const TimelineComponent({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final title = element.props['title']?.toString();
    final itemsList = element.props['items'] as List<dynamic>? ?? [];
    final studyTheme = context.studyTheme;

    final items = itemsList.map((item) {
      if (item is Map<String, dynamic>) {
        return {
          'date': item['date']?.toString() ?? '',
          'title': item['title']?.toString() ?? '',
          'description': item['description']?.toString() ?? '',
        };
      }
      return {'date': '', 'title': item.toString(), 'description': ''};
    }).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
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
          if (title != null && title.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  LucideIcons.clock,
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
            Divider(
              color: studyTheme.cardDivider,
            ),
            const SizedBox(height: 16),
          ],
          ...items.asMap().entries.map((entry) {
            final isLast = entry.key == items.length - 1;
            final item = entry.value;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: studyTheme.timelineIndicator,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast) // Use full depth line if not last
                        Expanded(
                          child: Container(
                            width: 2,
                            color: studyTheme.timelineLine,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((item['date'] as String).isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: LaTeXText(
                                item['date'] as String,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                            ),
                          if ((item['title'] as String).isNotEmpty) ...[
                            const SizedBox(height: 8),
                            LaTeXText(
                              item['title'] as String,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: studyTheme.cardTitle,
                                  ),
                            ),
                          ],
                          if ((item['description'] as String).isNotEmpty) ...[
                            const SizedBox(height: 4),
                            MarkdownWidget(data: item['description'] as String),
                          ],
                        ],
                      ),
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
