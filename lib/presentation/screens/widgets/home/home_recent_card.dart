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
import 'package:quizdy/core/l10n/app_localizations.dart';

class HomeRecentCard extends StatelessWidget {
  final String title;
  final double progress;
  final String lastOpenedText;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const HomeRecentCard({
    super.key,
    required this.title,
    required this.progress,
    required this.lastOpenedText,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final homeTheme = context.homeTheme;

    final progressColor = progress >= 0.8
        ? homeTheme.progressGreenColor
        : (progress >= 0.4
              ? homeTheme.progressOrangeColor
              : homeTheme.progressBlueColor);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: homeTheme.cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: homeTheme.borderColor, width: 1),
        ),
        child: Row(
          children: [
            // Circular progress indicator badge
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: progressColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    color: progressColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Card content column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: homeTheme.textPrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2.5),
                    child: Container(
                      height: 5,
                      width: double.infinity,
                      color: homeTheme.borderColor,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(color: progressColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lastOpenedText,
                    style: TextStyle(
                      color: homeTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Trash delete button
            IconButton(
              icon: Icon(
                LucideIcons.trash2,
                color: homeTheme.textSecondaryColor.withValues(alpha: 0.6),
                size: 16,
              ),
              tooltip: AppLocalizations.of(context)!.deleteButton,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
