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
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';

class StudyIndexChunkCard extends StatelessWidget {
  final StudyChunk chunk;
  final int index;
  final int total;
  final AppLocalizations localizations;
  final VoidCallback onTap;

  const StudyIndexChunkCard({
    super.key,
    required this.chunk,
    required this.index,
    required this.total,
    required this.localizations,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCompleted = chunk.status == StudyChunkState.completed;

    final cardBg = isDark ? AppTheme.cardColorDark : Colors.white;
    final pendingBadgeBg = isDark ? AppTheme.zinc700 : AppTheme.zinc100;
    final pendingBadgeText = isDark ? AppTheme.zinc400 : AppTheme.zinc500;
    final titleColor = isDark ? AppTheme.zinc300 : AppTheme.zinc700;
    final subtitleColor = isDark ? AppTheme.zinc600 : AppTheme.zinc400;
    final arrowColor = isDark ? AppTheme.zinc600 : AppTheme.zinc400;
    final summaryColor = isDark ? AppTheme.zinc400 : AppTheme.zinc500;
    final pendingBorder = isDark
        ? null
        : Border.all(color: AppTheme.borderColor, width: 1);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: isCompleted
              ? Border(
                  left: BorderSide(
                    color: AppTheme.primaryColor.withValues(alpha: 0.25),
                    width: 3,
                  ),
                )
              : pendingBorder,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Number badge (rounded rect, cornerRadius 14)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: isCompleted ? AppTheme.primaryColor : pendingBadgeBg,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? Colors.white : pendingBadgeText,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chunk.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isCompleted
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isCompleted ? null : titleColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        localizations.studyScreenSectionIndicator(
                          index + 1,
                          total,
                        ),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status icon
                if (isCompleted)
                  const Icon(
                    Icons.check_circle,
                    size: 20,
                    color: AppTheme.primaryColor,
                  )
                else
                  Icon(Icons.chevron_right, size: 18, color: arrowColor),
              ],
            ),
            // AI Summary for completed chunks
            if (isCompleted &&
                chunk.aiSummary != null &&
                chunk.aiSummary!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                chunk.aiSummary!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: summaryColor,
                  height: 1.45,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
