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
import 'package:quizdy/presentation/screens/widgets/common/markdown_widget.dart';

class ProsConsComponent extends StatelessWidget {
  final UiElement element;

  const ProsConsComponent({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final itemsMap = element.props['items'] as Map<String, dynamic>? ?? {};
    final prosList = itemsMap['pros'] as List<dynamic>? ?? [];
    final consList = itemsMap['cons'] as List<dynamic>? ?? [];

    final pros = prosList.map((e) => e.toString()).toList();
    final cons = consList.map((e) => e.toString()).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // If narrow, stack them vertically. If wide enough, side-by-side.
          if (constraints.maxWidth < 400) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildList(context, 'Pros', pros, true),
                const SizedBox(height: 16),
                _buildList(context, 'Cons', cons, false),
              ],
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildList(context, 'Pros', pros, true)),
                const SizedBox(width: 16),
                Expanded(child: _buildList(context, 'Cons', cons, false)),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    String title,
    List<String> items,
    bool isPros,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final color = isPros ? Colors.green : Colors.red;
    final backgroundColor = isDark
        ? color[900]?.withValues(alpha: 0.1)
        : color[50];
    final borderColor = isDark ? color[800]! : color[200]!;
    final iconColor = isDark ? color[400] : color[600];
    final icon = isPros ? LucideIcons.checkCircle2 : LucideIcons.xCircle;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text(
              'No items',
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: iconColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: MarkdownWidget(data: item)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
