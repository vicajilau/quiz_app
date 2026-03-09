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
import 'package:quizdy/core/theme/extensions/study_theme_extension.dart';

class KeyConceptsComponent extends StatelessWidget {
  final UiElement element;

  const KeyConceptsComponent({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final title = element.props['title']?.toString();
    final itemsList = element.props['items'] as List<dynamic>? ?? [];

    final items = itemsList.map((e) => e.toString()).toList();
    final studyTheme = context.studyTheme;

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
                  LucideIcons.tags,
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
          if (items.isNotEmpty)
            Wrap(
              spacing: 8.0,
              runSpacing: 12.0,
              children: items.map((concept) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: LaTeXText(
                    concept,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
