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
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/core/theme/extensions/custom_colors.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/domain/use_cases/check_file_changes_use_case.dart';

class StudySectionsSidebar extends StatelessWidget {
  final List<StudyChunk> chunks;
  final int currentChunkIndex;
  final AppLocalizations localizations;
  final ValueChanged<int> onChunkSelected;
  final ValueChanged<int> onChunkDownload;
  final ValueChanged<int> onChunkEdit;
  final VoidCallback onClose;
  final bool isFullScreen;

  const StudySectionsSidebar({
    super.key,
    required this.chunks,
    required this.currentChunkIndex,
    required this.localizations,
    required this.onChunkSelected,
    required this.onChunkDownload,
    required this.onChunkEdit,
    required this.onClose,
    this.isFullScreen = false,
  });

  bool _isNew(int index, StudyChunk chunk) {
    final checker = ServiceLocator.getIt<CheckFileChangesUseCase>();
    return checker.isStudyChunkNew(index, chunk);
  }

  bool _isModified(int index, StudyChunk chunk) {
    final checker = ServiceLocator.getIt<CheckFileChangesUseCase>();
    return checker.isStudyChunkModified(index, chunk);
  }

  Map<String, int> _buildChunkDuplicateCounts() {
    final counts = <String, int>{};
    for (final chunk in chunks) {
      counts[chunk.duplicationKey] = (counts[chunk.duplicationKey] ?? 0) + 1;
    }
    return counts;
  }

  bool _isDuplicated(StudyChunk chunk, Map<String, int> duplicateCounts) {
    return (duplicateCounts[chunk.duplicationKey] ?? 0) > 1;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final duplicateChunkCounts = _buildChunkDuplicateCounts();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.zinc800 : AppTheme.backgroundColor,
        border: isFullScreen
            ? null
            : Border(
                right: BorderSide(
                  color: isDark ? AppTheme.zinc700 : AppTheme.borderColor,
                ),
              ),
      ),
      child: SafeArea(
        right: false,
        left: isFullScreen,
        bottom: true,
        top: isFullScreen,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                isFullScreen ? 10 : MediaQuery.of(context).padding.top + 10,
                8,
                12,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.list,
                    size: 18,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      localizations.studyScreenSections,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppTheme.backgroundColor
                            : AppTheme.zinc900,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(
                        alpha: isDark ? 0.125 : 0.063,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${chunks.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppTheme.zinc300
                            : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _SidebarToggleButton(isDark: isDark, onTap: onClose),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                itemCount: chunks.length,
                itemBuilder: (context, index) {
                  final chunk = chunks[index];
                  final isSelected = index == currentChunkIndex;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _SidebarChunkItem(
                      chunk: chunk,
                      index: index,
                      total: chunks.length,
                      isSelected: isSelected,
                      isNew: _isNew(index, chunk),
                      isModified: _isModified(index, chunk),
                      isDuplicated: _isDuplicated(chunk, duplicateChunkCounts),
                      localizations: localizations,
                      onTap: () => onChunkSelected(index),
                      onDownload: () => onChunkDownload(index),
                      onEdit: () => onChunkEdit(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarToggleButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _SidebarToggleButton({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.zinc700 : AppTheme.zinc100,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Icon(
          LucideIcons.panelRightOpen,
          size: 18,
          color: isDark ? AppTheme.zinc400 : AppTheme.zinc500,
        ),
      ),
    );
  }
}

class _SidebarChunkItem extends StatelessWidget {
  final StudyChunk chunk;
  final int index;
  final int total;
  final bool isSelected;
  final bool isNew;
  final bool isModified;
  final bool isDuplicated;
  final AppLocalizations localizations;
  final VoidCallback onTap;
  final VoidCallback onDownload;
  final VoidCallback onEdit;

  const _SidebarChunkItem({
    required this.chunk,
    required this.index,
    required this.total,
    required this.isSelected,
    required this.isNew,
    required this.isModified,
    required this.isDuplicated,
    required this.localizations,
    required this.onTap,
    required this.onDownload,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = chunk.status == StudyChunkState.completed;
    final isDownloaded = chunk.status == StudyChunkState.downloaded;
    final isProcessing = chunk.status == StudyChunkState.processing;
    final isError = chunk.status == StudyChunkState.error;
    final hasContent = isCompleted || isDownloaded;
    final needsDownload = !hasContent && !isProcessing;

    final Color bgColor;
    if (isSelected) {
      bgColor = isDark ? AppTheme.zinc700 : AppTheme.zinc100;
    } else if (isCompleted || isModified) {
      bgColor = AppTheme.primaryColor.withValues(alpha: isDark ? 0.125 : 0.063);
    } else {
      bgColor = AppTheme.transparent;
    }

    return GestureDetector(
      onTap: hasContent ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? const Border(
                  left: BorderSide(color: AppTheme.primaryColor, width: 3),
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted || isSelected
                        ? AppTheme.primaryColor.withValues(alpha: 0.25)
                        : (isDark ? AppTheme.zinc700 : AppTheme.zinc100),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isCompleted || isSelected
                          ? (isDark ? AppTheme.zinc300 : AppTheme.primaryColor)
                          : (isDark ? AppTheme.zinc500 : AppTheme.zinc400),
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
                          Expanded(
                            child: Text(
                              chunk.title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isCompleted || isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isCompleted || isSelected
                                    ? (isDark
                                          ? AppTheme.backgroundColor
                                          : AppTheme.zinc900)
                                    : (isDark
                                          ? AppTheme.zinc400
                                          : AppTheme.zinc500),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isDuplicated || isNew || isModified) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (isDuplicated
                                            ? (Theme.of(context)
                                                      .extension<CustomColors>()
                                                      ?.warning ??
                                                  AppTheme.secondaryColor)
                                            : AppTheme.secondaryColor)
                                        .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isDuplicated
                                    ? localizations.duplicatedTag
                                    : (isNew
                                          ? localizations.newTag
                                          : localizations.modifiedTag),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: isDuplicated
                                      ? (Theme.of(context)
                                                .extension<CustomColors>()
                                                ?.warning ??
                                            AppTheme.secondaryColor)
                                      : AppTheme.secondaryColor,
                                ),
                              ),
                            ),
                          ],
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
                          color: isSelected
                              ? AppTheme.primaryColor
                              : (isDark ? AppTheme.zinc600 : AppTheme.zinc400),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                if (isCompleted)
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppTheme.primaryColor,
                  )
                else if (isSelected)
                  const Icon(
                    Icons.play_arrow,
                    size: 16,
                    color: AppTheme.primaryColor,
                  )
                else if (isDownloaded)
                  Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: isDark ? AppTheme.zinc600 : AppTheme.zinc400,
                  ),
              ],
            ),
            if (needsDownload) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (chunk.status == StudyChunkState.created)
                    Expanded(
                      child: GestureDetector(
                        onTap: onDownload,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isError
                                ? (isDark ? AppTheme.zinc800 : AppTheme.zinc100)
                                : AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isError ? Icons.refresh : LucideIcons.sparkles,
                                size: 13,
                                color: isError
                                    ? AppTheme.zinc500
                                    : AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isError
                                    ? localizations.studyScreenRetry
                                    : localizations.studyScreenDownloadChunk,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isError
                                      ? AppTheme.zinc500
                                      : AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (chunk.status == StudyChunkState.created)
                    const SizedBox(width: 8),
                  if (chunk.status == StudyChunkState.created)
                    Expanded(
                      child: GestureDetector(
                        onTap: onEdit,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor.withValues(
                              alpha: isDark ? 0.15 : 0.1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 13,
                                color: AppTheme.secondaryColor,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Edit',
                                style: TextStyle(
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
                  if (chunk.status != StudyChunkState.created)
                    Expanded(
                      child: GestureDetector(
                        onTap: onDownload,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isError
                                ? (isDark ? AppTheme.zinc800 : AppTheme.zinc100)
                                : AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isError ? Icons.refresh : LucideIcons.sparkles,
                                size: 13,
                                color: isError
                                    ? AppTheme.zinc500
                                    : AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isError
                                    ? localizations.studyScreenRetry
                                    : localizations.studyScreenDownloadChunk,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isError
                                      ? AppTheme.zinc500
                                      : AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
            if (isProcessing) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: AppTheme.primaryColor.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    localizations.studyScreenGenerating,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppTheme.zinc500 : AppTheme.zinc400,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
