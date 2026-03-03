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
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';

class StudySectionsSidebar extends StatefulWidget {
  final List<StudyChunk> chunks;
  final int currentChunkIndex;
  final AppLocalizations localizations;
  final ValueChanged<int> onChunkSelected;

  const StudySectionsSidebar({
    super.key,
    required this.chunks,
    required this.currentChunkIndex,
    required this.localizations,
    required this.onChunkSelected,
  });

  @override
  State<StudySectionsSidebar> createState() => _StudySectionsSidebarState();
}

class _StudySectionsSidebarState extends State<StudySectionsSidebar> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _expanded ? 280 : 48,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.zinc800 : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? AppTheme.zinc700 : AppTheme.borderColor,
          ),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: OverflowBox(
        maxWidth: 280,
        minWidth: 280,
        alignment: AlignmentDirectional.centerStart,
        child: SizedBox(
          width: 280,
          child: _expanded ? _buildExpanded(isDark) : _buildCollapsed(isDark),
        ),
      ),
    );
  }

  Widget _buildExpanded(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
          child: Row(
            children: [
              const Icon(Icons.list, size: 18, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.localizations.studyScreenSections,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppTheme.zinc900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(
                    alpha: isDark ? 0.125 : 0.063,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.chunks.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.zinc300 : AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _SidebarToggleButton(
                expanded: true,
                isDark: isDark,
                onTap: () => setState(() => _expanded = false),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            itemCount: widget.chunks.length,
            itemBuilder: (context, index) {
              final chunk = widget.chunks[index];
              final isSelected = index == widget.currentChunkIndex;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _SidebarChunkItem(
                  chunk: chunk,
                  index: index,
                  total: widget.chunks.length,
                  isSelected: isSelected,
                  localizations: widget.localizations,
                  onTap: () => widget.onChunkSelected(index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsed(bool isDark) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, left: 6),
        child: _SidebarToggleButton(
          expanded: false,
          isDark: isDark,
          onTap: () => setState(() => _expanded = true),
        ),
      ),
    );
  }
}

class _SidebarToggleButton extends StatelessWidget {
  final bool expanded;
  final bool isDark;
  final VoidCallback onTap;

  const _SidebarToggleButton({
    required this.expanded,
    required this.isDark,
    required this.onTap,
  });

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
          expanded ? LucideIcons.panelRightOpen : LucideIcons.panelRightClose,
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
  final AppLocalizations localizations;
  final VoidCallback onTap;

  const _SidebarChunkItem({
    required this.chunk,
    required this.index,
    required this.total,
    required this.isSelected,
    required this.localizations,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = chunk.status == StudyChunkState.completed;

    final Color bgColor;
    if (isSelected) {
      bgColor = isDark ? AppTheme.zinc700 : AppTheme.zinc100;
    } else if (isCompleted) {
      bgColor = AppTheme.primaryColor.withValues(alpha: isDark ? 0.125 : 0.063);
    } else {
      bgColor = Colors.transparent;
    }

    return GestureDetector(
      onTap: onTap,
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
        child: Row(
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
                  Text(
                    chunk.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isCompleted || isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isCompleted || isSelected
                          ? (isDark ? Colors.white : AppTheme.zinc900)
                          : (isDark ? AppTheme.zinc400 : AppTheme.zinc500),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    localizations.studyScreenSectionIndicator(index + 1, total),
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
              Icon(
                Icons.check_circle,
                size: 16,
                color: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor,
              )
            else if (isSelected)
              const Icon(
                Icons.play_arrow,
                size: 16,
                color: AppTheme.primaryColor,
              )
            else
              Icon(
                Icons.chevron_right,
                size: 14,
                color: isDark ? AppTheme.zinc600 : AppTheme.zinc400,
              ),
          ],
        ),
      ),
    );
  }
}
