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
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quizdy/core/theme/extensions/home_theme.dart';

class HomeActionCard extends StatelessWidget {
  final String title;
  final String description;
  final String badgeText;
  final Color backgroundColor;
  final IconData icon;
  final bool isPrimary;
  final Color? accentColor;
  final VoidCallback onTap;

  const HomeActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.badgeText,
    required this.backgroundColor,
    required this.icon,
    required this.isPrimary,
    this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final homeTheme = context.homeTheme;

    final titleColor = isPrimary ? Colors.white : homeTheme.textPrimaryColor;
    final bodyColor = isPrimary
        ? Colors.white.withValues(alpha: 0.75)
        : homeTheme.textSecondaryColor;
    final badgeBgColor = isPrimary
        ? Colors.white.withValues(alpha: 0.15)
        : homeTheme.borderColor;
    final badgeTextColor = isPrimary
        ? Colors.white
        : (accentColor ?? homeTheme.textSecondaryColor);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 154,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary
              ? null
              : Border.all(color: homeTheme.borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? Colors.white.withValues(alpha: 0.2)
                        : badgeBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isPrimary
                        ? Colors.white
                        : (accentColor ?? homeTheme.textSecondaryColor),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              description,
              style: TextStyle(color: bodyColor, fontSize: 13, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: badgeTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  LucideIcons.arrowRight,
                  color: isPrimary
                      ? Colors.white
                      : homeTheme.textSecondaryColor,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
