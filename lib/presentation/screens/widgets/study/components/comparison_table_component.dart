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

class ComparisonTableComponent extends StatelessWidget {
  final UiElement element;

  const ComparisonTableComponent({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final title = element.props['title']?.toString();
    final columnsList = element.props['columns'] as List<dynamic>? ?? [];
    final rowsList = element.props['rows'] as List<dynamic>? ?? [];

    final columns = columnsList.map((e) => e.toString()).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Parse rows correctly
    final rows = rowsList.map((row) {
      if (row is Map<String, dynamic>) {
        final label = row['label']?.toString() ?? '';
        final values = (row['values'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();
        return {'label': label, 'values': values};
      }
      return {'label': '', 'values': <String>[]};
    }).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
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
                  LucideIcons.gitCompare,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? const Color(0xFFF4F4F5)
                          : const Color(0xFF18181B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(
              color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
            ),
            const SizedBox(height: 16),
          ],
          if (columns.isNotEmpty && rows.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF3F3F46)
                      : const Color(0xFFE4E4E7),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.resolveWith(
                      (states) => isDark
                          ? const Color(0xFF18181B)
                          : const Color(0xFFFFFFFF),
                    ),
                    dataRowColor: WidgetStateProperty.resolveWith((states) {
                      return Colors.transparent;
                    }),
                    dividerThickness: 1,
                    columns: [
                      const DataColumn(label: Text('')), // Empty corner
                      ...columns.map(
                        (col) => DataColumn(
                          label: Expanded(
                            child: LaTeXText(
                              col,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    rows: rows.map((row) {
                      final label = row['label'] as String;
                      final values = row['values'] as List<String>;
                      return DataRow(
                        cells: [
                          DataCell(
                            LaTeXText(
                              label,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFFF4F4F5)
                                    : const Color(0xFF18181B),
                              ),
                            ),
                          ),
                          ...columns.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final val = idx < values.length ? values[idx] : '';
                            return DataCell(MarkdownWidget(data: val));
                          }),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
