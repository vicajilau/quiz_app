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
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
