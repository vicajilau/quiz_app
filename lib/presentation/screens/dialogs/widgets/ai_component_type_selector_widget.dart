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
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/core/theme/extensions/confirm_dialog_colors_extension.dart';
import 'package:quizdy/domain/models/quiz/study_component.dart';
import 'package:quizdy/presentation/widgets/quizdy_switch.dart';

class AiComponentTypeSelectorWidget extends StatelessWidget {
  final bool enabled;
  final Set<StudyComponentType> selectedTypes;
  final ValueChanged<bool> onToggle;
  final ValueChanged<StudyComponentType> onTypeToggled;

  const AiComponentTypeSelectorWidget({
    super.key,
    required this.enabled,
    required this.selectedTypes,
    required this.onToggle,
    required this.onTypeToggled,
  });

  String _typeName(AppLocalizations l, StudyComponentType type) =>
      switch (type) {
        StudyComponentType.sectionTitle => l.componentTypeSectionTitle,
        StudyComponentType.paragraph => l.componentTypeParagraph,
        StudyComponentType.keyDefinition => l.componentTypeKeyDefinition,
        StudyComponentType.numberedList => l.componentTypeNumberedList,
        StudyComponentType.comparisonTable => l.componentTypeComparisonTable,
        StudyComponentType.quote => l.componentTypeQuote,
        StudyComponentType.warning => l.componentTypeWarning,
        StudyComponentType.formula => l.componentTypeFormula,
        StudyComponentType.timeline => l.componentTypeTimeline,
        StudyComponentType.prosCons => l.componentTypeProsCons,
        StudyComponentType.keyConcepts => l.componentTypeKeyConcepts,
        StudyComponentType.reminder => l.componentTypeReminder,
        StudyComponentType.iconCards => l.componentTypeIconCards,
      };

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colors = context.appColors;
    final types = StudyComponentType.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localizations.aiSelectComponentTypesTitle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.title,
              ),
            ),
            QuizdySwitch(value: enabled, onChanged: onToggle),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          localizations.aiSelectComponentTypesSubtitle,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: colors.subtitle,
          ),
        ),
        if (enabled) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                for (int i = 0; i < types.length; i += 2)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i + 2 < types.length ? 6 : 0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TypeItem(
                            name: _typeName(localizations, types[i]),
                            isSelected: selectedTypes.contains(types[i]),
                            onTap: () => onTypeToggled(types[i]),
                          ),
                        ),
                        if (i + 1 < types.length) ...[
                          const SizedBox(width: 6),
                          Expanded(
                            child: _TypeItem(
                              name: _typeName(localizations, types[i + 1]),
                              isSelected: selectedTypes.contains(types[i + 1]),
                              onTap: () => onTypeToggled(types[i + 1]),
                            ),
                          ),
                        ] else
                          const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TypeItem extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeItem({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? AppTheme.primaryColor.withValues(alpha: 0.15)
                    : AppTheme.primaryColor.withValues(alpha: 0.08))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppTheme.primaryColor, width: 2),
              ),
              child: isSelected
                  ? const Icon(LucideIcons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  color: isSelected ? colors.title : colors.subtitle,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
