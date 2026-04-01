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
import 'package:quizdy/core/extensions/study_extension.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/domain/models/quiz/study_component.dart';
import 'package:quizdy/presentation/screens/widgets/study/components/study_component_builder.dart';

class ComponentCard extends StatelessWidget {
  final StudyComponent element;
  final int index;
  final int totalCount;
  final bool isSelected;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  /// Whether the list is in multi-selection mode.
  final bool isInSelectionMode;

  /// Whether this card is checked in multi-selection mode.
  final bool isChecked;

  /// Called when the card is tapped in multi-selection mode.
  final VoidCallback? onToggleSelect;

  const ComponentCard({
    super.key,
    required this.element,
    required this.index,
    required this.totalCount,
    required this.isSelected,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
    required this.onMoveUp,
    required this.onMoveDown,
    this.isInSelectionMode = false,
    this.isChecked = false,
    this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final effectiveSelected = isInSelectionMode ? isChecked : isSelected;
    final cardBg = isDark
        ? (effectiveSelected ? AppTheme.selectedCardDark : AppTheme.zinc800)
        : (effectiveSelected ? AppTheme.selectedCardLight : Colors.white);
    final borderColor = effectiveSelected
        ? AppTheme.primaryColor
        : (isDark ? AppTheme.zinc700 : AppTheme.zinc200);
    final borderWidth = effectiveSelected ? 2.0 : 1.0;

    final chevronColor = AppTheme.zinc400;
    final disabledColor = isDark ? AppTheme.zinc800 : AppTheme.zinc300;

    return GestureDetector(
      onTap: isInSelectionMode ? onToggleSelect : onEdit,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ───────────────────────────────────────────────────
            Row(
              children: [
                if (isInSelectionMode) ...[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isChecked
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isChecked ? AppTheme.primaryColor : chevronColor,
                      ),
                    ),
                    child: isChecked
                        ? const Icon(
                            LucideIcons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                ],
                _ComponentTypeChip(
                  type: element.componentType,
                  isSelected: true,
                  showLabel: !context.isMobile,
                ),
                const Spacer(),
                if (isInSelectionMode)
                  ReorderableDragStartListener(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.drag_indicator,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit (pencil)
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            LucideIcons.pencil,
                            size: 16,
                            color: AppTheme.secondaryColor,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: onEdit,
                          tooltip: AppLocalizations.of(context)!.edit,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Duplicate
                      IconButton(
                        onPressed: onDuplicate,
                        icon: Icon(
                          LucideIcons.copy,
                          size: 18,
                          color: chevronColor,
                        ),
                        tooltip: AppLocalizations.of(context)!.duplicate,
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Move up
                      IconButton(
                        onPressed: index > 0 ? onMoveUp : null,
                        icon: Icon(
                          LucideIcons.chevronUp,
                          size: 18,
                          color: index > 0 ? chevronColor : disabledColor,
                        ),
                        tooltip: index > 0
                            ? AppLocalizations.of(context)!.moveUp
                            : null,
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Move down
                      IconButton(
                        onPressed: index < totalCount - 1 ? onMoveDown : null,
                        icon: Icon(
                          LucideIcons.chevronDown,
                          size: 18,
                          color: index < totalCount - 1
                              ? chevronColor
                              : disabledColor,
                        ),
                        tooltip: index < totalCount - 1
                            ? AppLocalizations.of(context)!.moveDown
                            : null,
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Delete
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(
                          LucideIcons.trash2,
                          size: 18,
                          color: AppTheme.errorColor,
                        ),
                        tooltip: AppLocalizations.of(context)!.deleteButton,
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),
            StudyComponentBuilder(element: element),
          ],
        ),
      ),
    );
  }
}

class _ComponentTypeChip extends StatelessWidget {
  final StudyComponentType type;
  final bool isSelected;
  final bool showLabel;

  const _ComponentTypeChip({
    required this.type,
    required this.isSelected,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;

    final (Color bg, Color fg, IconData icon) = _chipStyle(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: fg),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              type.displayName(l),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ],
      ),
    );
  }

  (Color, Color, IconData) _chipStyle(bool isDark) {
    if (isSelected) {
      return (
        AppTheme.primaryColor.withValues(alpha: 0.12),
        AppTheme.violet400,
        _iconForType(),
      );
    }

    return switch (type) {
      StudyComponentType.warning => (
        AppTheme.amber400.withValues(alpha: 0.12),
        AppTheme.amber400,
        LucideIcons.alertTriangle,
      ),
      StudyComponentType.reminder => (
        AppTheme.blue400.withValues(alpha: 0.12),
        AppTheme.blue400,
        LucideIcons.bell,
      ),
      _ => (
        isDark ? AppTheme.zinc700 : AppTheme.zinc200,
        isDark ? AppTheme.zinc500 : AppTheme.zinc600,
        _iconForType(),
      ),
    };
  }

  IconData _iconForType() => switch (type) {
    StudyComponentType.sectionTitle => LucideIcons.type,
    StudyComponentType.paragraph => LucideIcons.fileText,
    StudyComponentType.keyDefinition => LucideIcons.bookOpen,
    StudyComponentType.numberedList => LucideIcons.listOrdered,
    StudyComponentType.comparisonTable => LucideIcons.table2,
    StudyComponentType.quote => LucideIcons.quote,
    StudyComponentType.warning => LucideIcons.alertTriangle,
    StudyComponentType.formula => LucideIcons.sigma,
    StudyComponentType.timeline => LucideIcons.gitCommit,
    StudyComponentType.prosCons => LucideIcons.scale,
    StudyComponentType.keyConcepts => LucideIcons.lightbulb,
    StudyComponentType.reminder => LucideIcons.bell,
    StudyComponentType.iconCards => LucideIcons.layoutGrid,
  };
}
