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
import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_index_chunk_download_button.dart';
import 'package:quizdy/presentation/widgets/card_status_bar.dart';

class StudyIndexChunkCard extends StatefulWidget {
  final StudyChunk chunk;
  final int index;
  final int total;
  final AppLocalizations localizations;
  final VoidCallback onTap;
  final VoidCallback? onDownload;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isSelectionMode;
  final bool supportsReordering;
  final bool isNew;
  final bool isModified;
  final bool isDuplicated;

  const StudyIndexChunkCard({
    super.key,
    required this.chunk,
    required this.index,
    required this.total,
    required this.localizations,
    required this.onTap,
    this.onDownload,
    this.onEdit,
    this.onDelete,
    this.onLongPress,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.supportsReordering = false,
    this.isNew = false,
    this.isModified = false,
    this.isDuplicated = false,
  });

  @override
  State<StudyIndexChunkCard> createState() => _StudyIndexChunkCardState();
}

class _StudyIndexChunkCardState extends State<StudyIndexChunkCard> {
  bool _expanded = false;
  bool _exceedsMaxLines = false;
  bool _isActionsExpanded = false;
  bool _isHovered = false;

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

    final isMobile = context.isMobile;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCompleted = chunk.status == StudyChunkState.completed;
    final isDownloaded = chunk.status == StudyChunkState.downloaded;
    final isProcessing = chunk.status == StudyChunkState.processing;
    final isError = chunk.status == StudyChunkState.error;
    final hasContent = isCompleted || isDownloaded;
    final needsDownload = !hasContent && !isProcessing;

    final cardBg = isDark ? AppTheme.cardColorDark : Colors.white;
    final pendingBadgeBg = isDark ? AppTheme.zinc700 : AppTheme.zinc100;
    final pendingBadgeText = isDark ? AppTheme.zinc400 : AppTheme.zinc500;
    final subtitleColor = isDark ? AppTheme.zinc600 : AppTheme.zinc400;
    final arrowColor = isDark ? AppTheme.zinc600 : AppTheme.zinc400;
    final summaryColor = isDark ? AppTheme.zinc400 : AppTheme.zinc500;

    final hasStatus = widget.isNew || widget.isModified || widget.isDuplicated;

    Widget cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: hasStatus
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              )
            : BorderRadius.circular(14),
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

      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (isSelectionMode)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : arrowColor,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    LucideIcons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        )
                      else
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: isCompleted
                                ? AppTheme.primaryColor
                                : pendingBadgeBg,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isCompleted
                                  ? Colors.white
                                  : pendingBadgeText,
                            ),
                          ),
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    chunk.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isCompleted
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isDark
                                          ? AppTheme.backgroundColor
                                          : AppTheme.zinc900,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
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
                    ],
                  ),

                  // AI Summary for completed or downloaded chunks
                  if (hasContent &&
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
                              setState(
                                () => _exceedsMaxLines = exceedsMaxLines,
                              );
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
                  // Download button for created/error chunks
                  if (!isSelectionMode && needsDownload) ...[
                    const SizedBox(height: 12),
                    if ((chunk.status == StudyChunkState.created || isError) &&
                        widget.onEdit != null)
                      Row(
                        children: [
                          Expanded(
                            child: StudyIndexChunkDownloadButton(
                              isError: isError,
                              onDownload: widget.onDownload,
                              localizations: localizations,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: widget.onEdit,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryColor.withValues(
                                    alpha: isDark ? 0.15 : 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_outlined,
                                      size: 12,
                                      color: AppTheme.secondaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      localizations.create,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.secondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      StudyIndexChunkDownloadButton(
                        isError: isError,
                        onDownload: widget.onDownload,
                        localizations: localizations,
                      ),
                  ],
                  // Loading indicator while processing
                  if (!isSelectionMode && isProcessing) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryColor.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          localizations.studyScreenGenerating,
                          style: TextStyle(
                            fontSize: 12,
                            color: subtitleColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isSelectionMode && widget.supportsReordering)
            ReorderableDragStartListener(
              index: index,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(
                  Icons.drag_indicator,
                  color: Theme.of(context).hintColor,
                ),
              ),
            )
          else if (isSelectionMode)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(
                Icons.drag_indicator,
                color: Theme.of(context).hintColor.withValues(alpha: 0.3),
              ),
            )
          else if (isCompleted)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                Icons.check_circle,
                size: 22,
                color: AppTheme.primaryColor,
              ),
            ),
        ],
      ),
    );

    if (!isSelectionMode) {
      cardContent = Stack(
        children: [
          cardContent,
          Positioned(
            top: 10,
            right: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSize(
                  duration: Durations.medium2,
                  curve: Curves.easeInOutCubic,
                  child:
                      ((!isMobile && _isHovered) ||
                          (isMobile && _isActionsExpanded))
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.onEdit != null &&
                                hasContent &&
                                chunk.aiSummary != null &&
                                chunk.aiSummary!.isNotEmpty) ...[
                              _buildIconButton(
                                icon: LucideIcons.pencil,
                                color: AppTheme.secondaryColor,
                                onPressed: widget.onEdit!,
                                tooltip: localizations.edit,
                              ),
                              const SizedBox(width: 4),
                            ],
                            if (widget.onDelete != null) ...[
                              _buildIconButton(
                                icon: LucideIcons.trash2,
                                color: theme.colorScheme.error,
                                onPressed: widget.onDelete!,
                                tooltip: localizations.deleteButton,
                              ),
                              const SizedBox(width: 4),
                            ],
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                if (isMobile)
                  _buildIconButton(
                    icon: _isActionsExpanded
                        ? LucideIcons.chevronRight
                        : Icons.more_horiz,
                    color: Theme.of(context).hintColor,
                    onPressed: () => setState(
                      () => _isActionsExpanded = !_isActionsExpanded,
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    if (hasStatus) {
      cardContent = ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardStatusBar(
              isNew: widget.isNew,
              isModified: widget.isModified,
              isDuplicated: widget.isDuplicated,
            ),
            cardContent,
          ],
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: (hasContent || isSelectionMode) ? onTap : null,
        onLongPress: onLongPress,
        child: cardContent,
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        icon: Icon(icon, size: 16, color: color),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}
