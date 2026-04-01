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
import 'package:quizdy/core/theme/extensions/confirm_dialog_colors_extension.dart';

class QuizdySelectableCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback? onTap;
  final Widget? bottomContent;

  const QuizdySelectableCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    this.isLocked = false,
    this.onTap,
    this.bottomContent,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final inputBg = isDark ? const Color(0xFF1E1E22) : const Color(0xFFFAFAFA);
    final attachStroke = isDark
        ? const Color(0xFF3F3F46)
        : const Color(0xFFE4E4E7);

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected && !isLocked
              ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
              : inputBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected && !isLocked
                ? Theme.of(context).primaryColor
                : attachStroke,
            width: isSelected && !isLocked ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isSelected && !isLocked
                      ? Theme.of(context).primaryColor
                      : colors.subtitle,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isSelected && !isLocked
                              ? Theme.of(context).primaryColor
                              : colors.title,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: colors.subtitle,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLocked)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      LucideIcons.lock,
                      color: colors.subtitle.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  )
                else if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      LucideIcons.checkCircle2,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),
              ],
            ),
            if (isSelected && bottomContent != null) ...[
              const SizedBox(height: 16),
              bottomContent!,
            ],
          ],
        ),
      ),
    );
  }
}
