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
import 'package:quizdy/presentation/widgets/quizdy_button.dart';

/// Small 28×28 icon button to remove an item from a list.
class PropertyRemoveButton extends StatelessWidget {
  final VoidCallback onTap;

  const PropertyRemoveButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.zinc800 : AppTheme.zinc100,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Icon(
          LucideIcons.trash2,
          size: 14,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}

/// Full-width tertiary button to add a new item to a list.
class PropertyAddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const PropertyAddButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return QuizdyButton(
      type: QuizdyButtonType.tertiary,
      icon: LucideIcons.plus,
      title: l.componentFieldAdd(label.toLowerCase()),
      expanded: true,
      onPressed: onTap,
    );
  }
}
