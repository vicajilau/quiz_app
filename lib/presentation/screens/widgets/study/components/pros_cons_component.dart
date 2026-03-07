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
      padding: const EdgeInsets.only(bottom: 24.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // If narrow, stack them vertically. If wide enough, side-by-side.
          if (constraints.maxWidth < 600) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildList(context, 'Advantages', pros, true),
                const SizedBox(height: 16),
                _buildList(context, 'Limitations', cons, false),
              ],
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildList(context, 'Advantages', pros, true)),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildList(context, 'Limitations', cons, false),
                ),
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

    final backgroundColor = isDark
        ? (isPros ? const Color(0xFF064E3B) : const Color(0xFF7F1D1D))
              .withValues(alpha: 0.3)
        : (isPros ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2));
    final borderColor = isDark
        ? (isPros ? const Color(0xFF065F46) : const Color(0xFF991B1B))
        : (isPros ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA));
    final iconColor = isDark
        ? (isPros ? const Color(0xFF34D399) : const Color(0xFFF87171))
        : (isPros ? const Color(0xFF059669) : const Color(0xFFDC2626));
    final icon = isPros ? LucideIcons.checkCircle2 : LucideIcons.xCircle;

    return Container(
      padding: const EdgeInsets.all(20.0),
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
          const SizedBox(height: 16),
          if (items.isEmpty)
            Text(
              'No items',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFA1A1AA)
                    : const Color(0xFF71717A),
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
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
