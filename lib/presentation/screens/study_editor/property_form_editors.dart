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
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/presentation/screens/study_editor/property_form_controls.dart';
import 'package:quizdy/presentation/widgets/quizdy_text_field.dart';

/// Holds the controllers for one row of a comparison table.
class PropertyTableRow {
  final TextEditingController label;
  final List<TextEditingController> values;

  PropertyTableRow({required this.label, required this.values});
}

/// Editor for a list of plain strings (keyConcepts, pros, cons).
class PropertyStringListEditor extends StatelessWidget {
  final String label;
  final String itemLabel;
  final List<TextEditingController> controllers;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const PropertyStringListEditor({
    super.key,
    required this.label,
    required this.itemLabel,
    required this.controllers,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuizdyFieldLabel(label: label),
        const SizedBox(height: 8),
        for (int i = 0; i < controllers.length; i++) ...[
          Row(
            children: [
              Expanded(
                child: QuizdyTextField(
                  controller: controllers[i],
                  hint: '$itemLabel ${i + 1}',
                ),
              ),
              const SizedBox(width: 6),
              PropertyRemoveButton(onTap: () => onRemove(i)),
            ],
          ),
          const SizedBox(height: 8),
        ],
        PropertyAddButton(label: label, onTap: onAdd),
      ],
    );
  }
}

/// Editor for a list of maps (numberedList, timeline, iconCards).
class PropertyObjectListEditor extends StatelessWidget {
  final String label;
  final List<Map<String, TextEditingController>> rows;
  final Map<String, String> fieldLabels;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const PropertyObjectListEditor({
    super.key,
    required this.label,
    required this.rows,
    required this.fieldLabels,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppTheme.zinc800 : AppTheme.zinc200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuizdyFieldLabel(label: label),
        const SizedBox(height: 8),
        for (int i = 0; i < rows.length; i++) ...[
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.zinc500,
                      ),
                    ),
                    PropertyRemoveButton(onTap: () => onRemove(i)),
                  ],
                ),
                const SizedBox(height: 8),
                for (final entry in fieldLabels.entries) ...[
                  QuizdyFieldLabel(label: entry.value),
                  const SizedBox(height: 4),
                  QuizdyTextField(
                    controller: rows[i][entry.key]!,
                    hint: entry.value,
                    minLines: entry.key == 'description' ? 2 : 1,
                    maxLines: entry.key == 'description' ? null : 1,
                    keyboardType: entry.key == 'description'
                        ? TextInputType.multiline
                        : TextInputType.text,
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        PropertyAddButton(label: label, onTap: onAdd),
      ],
    );
  }
}

/// Editor for a comparison table (columns + labelled rows with per-column values).
class PropertyComparisonTableEditor extends StatelessWidget {
  final List<TextEditingController> columnControllers;
  final List<PropertyTableRow> tableRows;
  final VoidCallback onAddColumn;
  final ValueChanged<int> onRemoveColumn;
  final VoidCallback onAddRow;
  final ValueChanged<int> onRemoveRow;
  final String columnLabel;
  final String rowLabel;
  final String labelLabel;

  const PropertyComparisonTableEditor({
    super.key,
    required this.columnControllers,
    required this.tableRows,
    required this.onAddColumn,
    required this.onRemoveColumn,
    required this.onAddRow,
    required this.onRemoveRow,
    required this.columnLabel,
    required this.rowLabel,
    required this.labelLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppTheme.zinc800 : AppTheme.zinc200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Columns ──────────────────────────────────────────────────────────
        QuizdyFieldLabel(label: l.componentFieldColumns),
        const SizedBox(height: 8),
        for (int i = 0; i < columnControllers.length; i++) ...[
          Row(
            children: [
              Expanded(
                child: QuizdyTextField(
                  controller: columnControllers[i],
                  hint: '$columnLabel ${i + 1}',
                ),
              ),
              const SizedBox(width: 6),
              PropertyRemoveButton(onTap: () => onRemoveColumn(i)),
            ],
          ),
          const SizedBox(height: 8),
        ],
        PropertyAddButton(label: l.componentFieldColumns, onTap: onAddColumn),
        const SizedBox(height: 16),
        QuizdyFieldLabel(label: l.componentFieldRows),
        const SizedBox(height: 8),
        for (int i = 0; i < tableRows.length; i++) ...[
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$rowLabel ${i + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.zinc500,
                      ),
                    ),
                    PropertyRemoveButton(onTap: () => onRemoveRow(i)),
                  ],
                ),
                const SizedBox(height: 8),
                QuizdyFieldLabel(label: labelLabel),
                const SizedBox(height: 4),
                QuizdyTextField(
                  controller: tableRows[i].label,
                  hint: labelLabel,
                ),
                for (int j = 0; j < tableRows[i].values.length; j++) ...[
                  const SizedBox(height: 8),
                  QuizdyFieldLabel(
                    label: j < columnControllers.length
                        ? columnControllers[j].text.isNotEmpty
                              ? columnControllers[j].text
                              : '$columnLabel ${j + 1}'
                        : '$columnLabel ${j + 1}',
                  ),
                  const SizedBox(height: 4),
                  QuizdyTextField(
                    controller: tableRows[i].values[j],
                    hint: '$columnLabel ${j + 1}',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        PropertyAddButton(label: l.componentFieldRows, onTap: onAddRow),
      ],
    );
  }
}
