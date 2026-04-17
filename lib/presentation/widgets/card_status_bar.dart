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
import 'package:quizdy/core/theme/extensions/custom_colors.dart';

class CardStatusBar extends StatelessWidget {
  final bool isNew;
  final bool isModified;
  final bool isDuplicated;

  const CardStatusBar({
    super.key,
    this.isNew = false,
    this.isModified = false,
    this.isDuplicated = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isNew && !isModified && !isDuplicated) return const SizedBox.shrink();

    final customColors = Theme.of(context).extension<CustomColors>()!;
    final color = isDuplicated
        ? customColors.onWarningContainer!
        : (isModified ? customColors.aiIconColor! : AppTheme.secondaryColor);
    final icon = isDuplicated
        ? LucideIcons.copy
        : (isModified ? LucideIcons.refreshCw : LucideIcons.plusCircle);
    final label = (isDuplicated
            ? AppLocalizations.of(context)!.duplicatedTag
            : (isNew
                ? AppLocalizations.of(context)!.newTag
                : AppLocalizations.of(context)!.modifiedTag))
        .toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1)),
      child: Row(
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
