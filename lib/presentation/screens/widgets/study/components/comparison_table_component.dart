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
import 'package:quizdy/domain/models/quiz/study_component.dart';
import 'package:quizdy/presentation/widgets/latex_text.dart';
import 'package:quizdy/presentation/screens/widgets/common/markdown_widget.dart';
import 'package:quizdy/core/theme/extensions/study_theme_extension.dart';

class ComparisonTableComponent extends StatelessWidget {
  final StudyComponent element;

  const ComparisonTableComponent({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final title = element.props['title']?.toString();
    final rawRows = (element.props['rows'] as List<dynamic>? ?? []);
    final rawColumns = (element.props['columns'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    // Determine if the first column header should be used for the label column.
    // This happens if number of columns equals (values in row + 1 for the label).
    bool useFirstColumnAsLabel = false;
    if (rawRows.isNotEmpty && rawColumns.isNotEmpty) {
      final firstRow = rawRows.first;
      if (firstRow is Map<String, dynamic>) {
        final values = firstRow['values'] as List<dynamic>? ?? [];
        if (rawColumns.length == values.length + 1) {
          useFirstColumnAsLabel = true;
        }
      }
    }

    final columns = rawColumns;
    final studyTheme = context.studyTheme;

    // Parse rows correctly
    final rows = rawRows.map((row) {
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
          if (columns.isNotEmpty && rows.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: studyTheme.cardBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.resolveWith(
                      (states) => studyTheme.tableHeaderBackground,
                    ),
                    dataRowColor: WidgetStateProperty.resolveWith((states) {
                      return Colors.transparent;
                    }),
                    dividerThickness: 1,
                    columns: [
                      if (!useFirstColumnAsLabel)
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
                                color: studyTheme.cardTitle,
                              ),
                            ),
                          ),
                          ...values.map(
                            (val) => DataCell(MarkdownWidget(data: val)),
                          ),
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
