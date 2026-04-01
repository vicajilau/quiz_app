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
import 'package:quizdy/core/extensions/study_extension.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/domain/models/quiz/study_component.dart';

/// Grid picker that lets the user choose a [StudyComponentType] to add.
///
/// On mobile it fills the screen (set [isFullScreen] = true).
/// On desktop it renders as an inline panel in the sidebar slot.
class AddComponentSheet extends StatelessWidget {
  final bool isFullScreen;
  final VoidCallback onClose;
  final ValueChanged<StudyComponentType> onSelect;

  const AddComponentSheet({
    super.key,
    required this.isFullScreen,
    required this.onClose,
    required this.onSelect,
  });

  // ── Default props for each type ────────────────────────────────────────────

  static Map<String, dynamic> defaultProps(StudyComponentType type) =>
      switch (type) {
        StudyComponentType.sectionTitle => {'title': '', 'subtitle': ''},
        StudyComponentType.paragraph => {'title': '', 'body': ''},
        StudyComponentType.keyDefinition => {'term': '', 'body': ''},
        StudyComponentType.quote => {'body': '', 'author': ''},
        StudyComponentType.warning => {'body': ''},
        StudyComponentType.reminder => {'body': ''},
        StudyComponentType.formula => {
          'title': '',
          'equation': '',
          'equation_label': '',
          'body': '',
        },
        StudyComponentType.keyConcepts => {'title': '', 'items': []},
        StudyComponentType.numberedList => {'title': '', 'items': []},
        StudyComponentType.timeline => {'title': '', 'items': []},
        StudyComponentType.iconCards => {'title': '', 'items': []},
        StudyComponentType.prosCons => {
          'items': {'pros': [], 'cons': []},
        },
        StudyComponentType.comparisonTable => {
          'title': '',
          'columns': [],
          'rows': [],
        },
      };

  // ── Icon + accent color per type ───────────────────────────────────────────

  static (IconData, Color) _typeStyle(
    StudyComponentType type,
  ) => switch (type) {
    StudyComponentType.paragraph => (
      LucideIcons.fileText,
      AppTheme.primaryColor,
    ),
    StudyComponentType.sectionTitle => (
      LucideIcons.type,
      AppTheme.primaryColor,
    ),
    StudyComponentType.quote => (LucideIcons.quote, AppTheme.teal300),
    StudyComponentType.formula => (LucideIcons.sigma, AppTheme.sky400),
    StudyComponentType.numberedList => (
      LucideIcons.listOrdered,
      AppTheme.amber400,
    ),
    StudyComponentType.keyConcepts => (
      LucideIcons.lightbulb,
      AppTheme.purple400,
    ),
    StudyComponentType.comparisonTable => (
      LucideIcons.table2,
      AppTheme.violet400,
    ),
    StudyComponentType.timeline => (LucideIcons.gitCommit, AppTheme.teal300),
    StudyComponentType.warning => (
      LucideIcons.alertTriangle,
      AppTheme.amber400,
    ),
    StudyComponentType.keyDefinition => (LucideIcons.bookOpen, AppTheme.sky400),
    StudyComponentType.prosCons => (LucideIcons.scale, AppTheme.emerald400),
    StudyComponentType.reminder => (LucideIcons.bell, AppTheme.purple400),
    StudyComponentType.iconCards => (
      LucideIcons.layoutGrid,
      AppTheme.violet400,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dividerColor = isDark ? AppTheme.zinc700 : AppTheme.zinc200;
    final types = StudyComponentType.values;

    final grid = GridView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 125,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final (icon, color) = _typeStyle(type);
        return _ComponentTypeCard(
          isDark: isDark,
          icon: icon,
          color: color,
          label: type.displayName(l),
          onTap: () => onSelect(type),
        );
      },
    );

    if (!isFullScreen) {
      // Desktop inline panel
      return SizedBox(
        width: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: dividerColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l.addComponentTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onClose,
                    child: Icon(
                      LucideIcons.x,
                      size: 18,
                      color: isDark ? AppTheme.zinc400 : AppTheme.zinc500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: grid),
          ],
        ),
      );
    }

    // Mobile full-screen
    return SafeArea(
      child: Column(
        children: [
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                InkWell(
                  onTap: onClose,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      LucideIcons.chevronLeft,
                      size: 22,
                      color: isDark ? AppTheme.zinc400 : AppTheme.zinc500,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  l.addComponentTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: dividerColor, height: 1, thickness: 1),
          Expanded(child: grid),
        ],
      ),
    );
  }
}

class _ComponentTypeCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ComponentTypeCard({
    required this.isDark,
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppTheme.zinc800 : Colors.white;
    final labelColor = isDark ? AppTheme.zinc200 : AppTheme.zinc800;
    final iconBg = color.withValues(alpha: 0.12);

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: labelColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
