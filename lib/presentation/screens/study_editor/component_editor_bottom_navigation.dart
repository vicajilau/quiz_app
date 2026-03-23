import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';

class ComponentEditorBottomNavigation extends StatelessWidget {
  final bool isDark;
  final AppLocalizations localizations;
  final VoidCallback onAddComponent;
  final VoidCallback onSave;
  final VoidCallback onAI;

  /// When non-null, a delete button is shown before "Add Component".
  final int? deleteCount;
  final VoidCallback? onDelete;

  const ComponentEditorBottomNavigation({
    super.key,
    required this.isDark,
    required this.localizations,
    required this.onAddComponent,
    required this.onSave,
    required this.onAI,
    this.deleteCount,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (deleteCount != null) ...[
                  QuizdyButton(
                    type: QuizdyButtonType.warning,
                    icon: LucideIcons.trash2,
                    title: '${localizations.deleteButton} ($deleteCount)',
                    onPressed: onDelete,
                  ),
                  const SizedBox(width: 12),
                ],
                QuizdyButton(
                  type: QuizdyButtonType.secondary,
                  icon: LucideIcons.plus,
                  title: localizations.addComponentTitle,
                  onPressed: onAddComponent,
                ),
                const SizedBox(width: 12),
                QuizdyButton(
                  backgroundColor: AppTheme.secondaryColor,
                  title: localizations.addComponentsWithAI,
                  icon: LucideIcons.sparkles,
                  onPressed: onAI,
                ),
              ],
            ),
            const SizedBox(height: 10),
            QuizdyButton(
              type: QuizdyButtonType.primary,
              title: localizations.studyEditorSaveChanges,
              expanded: true,
              onPressed: onSave,
            ),
          ],
        ),
      ),
    );
  }
}
