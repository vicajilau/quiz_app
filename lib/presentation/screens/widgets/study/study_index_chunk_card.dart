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

class StudyIndexChunkCard extends StatefulWidget {
  final StudyChunk chunk;
  final int index;
  final int total;
  final AppLocalizations localizations;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isSelectionMode;
  final bool supportsReordering;

  const StudyIndexChunkCard({
    super.key,
    required this.chunk,
    required this.index,
    required this.total,
    required this.localizations,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.supportsReordering = false,
  });

  @override
  State<StudyIndexChunkCard> createState() => _StudyIndexChunkCardState();
}

class _StudyIndexChunkCardState extends State<StudyIndexChunkCard> {
  bool _expanded = false;
  bool _exceedsMaxLines = false;

  @override
  Widget build(BuildContext context) {
    final chunk = widget.chunk;
    final index = widget.index;
    final total = widget.total;
    final localizations = widget.localizations;
    final onTap = widget.onTap;
    final onLongPress = widget.onLongPress;
    final isSelected = widget.isSelected;
    final isSelectionMode = widget.isSelectionMode;

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

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: AppTheme.primaryColor, width: 2)
              : (isCompleted
                  ? Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.25),
                      width: 1.5,
                    )
                  : (isDark
                      ? Border.all(color: Colors.transparent, width: 1)
                      : Border.all(color: AppTheme.borderColor, width: 1))),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      isSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: isSelected ? AppTheme.primaryColor : arrowColor,
                      size: 22,
                    ),
                  )
                else
                  // Number badge (rounded rect, cornerRadius 14)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color:
                          isCompleted ? AppTheme.primaryColor : pendingBadgeBg,
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
                // Status icon or drag handle
                if (isSelectionMode && widget.supportsReordering)
                  ReorderableDragStartListener(
                    index: index,
                    child: Icon(Icons.drag_handle, color: arrowColor, size: 20),
                  )
                else if (isSelectionMode)
                  // Show handle but not draggable if not supported by current view
                  Icon(Icons.drag_handle,
                      color: arrowColor.withValues(alpha: 0.3), size: 20)
                else if (isCompleted)
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
              LayoutBuilder(
                builder: (context, constraints) {
                  final textSpan = TextSpan(
                    text: chunk.aiSummary!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: summaryColor,
                      height: 1.45,
                    ),
                  );
                  final tp = TextPainter(
                    text: textSpan,
                    maxLines: 3,
                    textDirection: TextDirection.ltr,
                  )..layout(maxWidth: constraints.maxWidth);
                  final exceedsMaxLines = tp.didExceedMaxLines;

                  if (exceedsMaxLines != _exceedsMaxLines) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() => _exceedsMaxLines = exceedsMaxLines);
                      }
                    });
                  }

                  return Text(
                    chunk.aiSummary!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: summaryColor,
                      height: 1.45,
                    ),
                    maxLines: _expanded ? null : 3,
                    overflow: _expanded ? null : TextOverflow.ellipsis,
                  );
                },
              ),
              if (_exceedsMaxLines) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    _expanded
                        ? localizations.showLessLabel
                        : localizations.showMoreLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
