import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark
        ? (isSelected ? AppTheme.selectedCardDark : AppTheme.zinc800)
        : (isSelected ? AppTheme.selectedCardLight : Colors.white);
    final borderColor = isSelected
        ? AppTheme.primaryColor
        : (isDark ? AppTheme.zinc700 : AppTheme.zinc200);
    final borderWidth = isSelected ? 2.0 : 1.0;

    final pencilColor = AppTheme.violet400;
    final chevronColor = AppTheme.zinc400;
    final disabledColor = isDark ? AppTheme.zinc800 : AppTheme.zinc300;

    return GestureDetector(
      onTap: onEdit,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ComponentTypeChip(
                  type: element.componentType,
                  isSelected: true,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit (pencil)
                    IconButton(
                      onPressed: onEdit,
                      icon: Icon(LucideIcons.pencil, size: 18, color: pencilColor),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                    const SizedBox(width: 4),
                    // Duplicate
                    IconButton(
                      onPressed: onDuplicate,
                      icon: Icon(LucideIcons.copy, size: 18, color: chevronColor),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
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
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                    const SizedBox(width: 4),
                    // Move down
                    IconButton(
                      onPressed: index < totalCount - 1 ? onMoveDown : null,
                      icon: Icon(
                        LucideIcons.chevronDown,
                        size: 18,
                        color: index < totalCount - 1 ? chevronColor : disabledColor,
                      ),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                    const SizedBox(width: 4),
                    // Delete
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(LucideIcons.trash2, size: 18, color: AppTheme.errorColor),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
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

  const _ComponentTypeChip({required this.type, required this.isSelected});

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
