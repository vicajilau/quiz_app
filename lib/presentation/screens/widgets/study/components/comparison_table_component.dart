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

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title.isNotEmpty) ...[
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
          ],
          if (columns.isNotEmpty && rows.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.resolveWith(
                      (states) =>
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    columns: [
                      const DataColumn(label: Text('')), // Empty corner
                      ...columns.map(
                        (col) => DataColumn(
                          label: Expanded(
                            child: Text(
                              col,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
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
                            Text(
                              label,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
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
