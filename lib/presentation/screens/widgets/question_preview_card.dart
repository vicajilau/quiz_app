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

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/domain/models/quiz/question.dart';
import 'package:quizdy/presentation/widgets/quizdy_latex_text.dart';
import 'package:quizdy/core/theme/extensions/custom_colors.dart';
import 'package:quizdy/presentation/screens/widgets/question_preview/question_options_list.dart';
import 'package:quizdy/presentation/screens/widgets/question_preview/question_type_indicator.dart';
import 'package:quizdy/presentation/widgets/card_status_bar.dart';

class QuestionPreviewCard extends StatefulWidget {
  final Question question;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final VoidCallback? onAiAssistant;
  final bool isSelectionMode;
  final bool isSelected;
  final bool isNew;
  final bool isModified;
  final bool isDuplicated;
  final VoidCallback? onSelectionToggle;

  const QuestionPreviewCard({
    super.key,
    required this.question,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
    this.onAiAssistant,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.isNew = false,
    this.isModified = false,
    this.isDuplicated = false,
    this.onSelectionToggle,
  });

  @override
  State<QuestionPreviewCard> createState() => _QuestionPreviewCardState();
}

class _QuestionPreviewCardState extends State<QuestionPreviewCard> {
  bool _isExpanded = false; // Collapsed by default as per user request
  bool _isActionsExpanded = false; // Used only on mobile to reveal actions
  bool _isHovered =
      false; // Used only for desktop to reveal actions smoothly on hover

  Uint8List? _getImageBytes(String? imageData) {
    if (imageData == null) return null;
    try {
      final base64Data = imageData.split(',').last;
      return base64Decode(base64Data);
    } catch (e) {
      return null;
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = !widget.question.isEnabled;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final isMobile = context.isMobile;

    Widget cardContent = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.isSelected
                ? customColors.aiIconColor!
                : Theme.of(context).dividerColor,
            width: widget.isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header and Question Text wrapped together for combined tap area
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.isSelectionMode
                    ? widget.onSelectionToggle
                    : _toggleExpanded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Bar (for New, Modified, Duplicated)
                    CardStatusBar(
                      isNew: widget.isNew,
                      isModified: widget.isModified,
                      isDuplicated: widget.isDuplicated,
                    ),

                    // Header with Question Index Badge and Actions
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Row(
                        children: [
                          // Left Group: Selection + Badge + Type
                          Expanded(
                            child: Row(
                              children: [
                                if (widget.isSelectionMode) ...[
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: widget.isSelected
                                          ? customColors.aiIconColor
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: widget.isSelected
                                            ? customColors.aiIconColor!
                                            : Theme.of(context).hintColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: widget.isSelected
                                        ? const Icon(
                                            LucideIcons.check,
                                            size: 14,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                ],

                                // Question Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).dividerColor.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    (widget.index + 1).toString().padLeft(
                                      2,
                                      '0',
                                    ),
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Question Type Badge
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: QuestionTypeIndicator(
                                      questionType: widget.question.type,
                                      showText: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Right Group: Actions
                          if (widget.isSelectionMode)
                            ReorderableDragStartListener(
                              index: widget.index,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  LucideIcons.gripVertical,
                                  color: Theme.of(context).hintColor,
                                  size: 20,
                                ),
                              ),
                            )
                          else
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOutCubic,
                                  child:
                                      ((!isMobile && _isHovered) ||
                                          (isMobile && _isActionsExpanded))
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (widget.onAiAssistant != null &&
                                                !isDisabled)
                                              _buildIconButton(
                                                icon: LucideIcons.sparkles,
                                                color:
                                                    customColors.aiIconColor!,
                                                onPressed:
                                                    widget.onAiAssistant!,
                                                tooltip: AppLocalizations.of(
                                                  context,
                                                )!.aiButtonTooltip,
                                              ),
                                            const SizedBox(width: 4),
                                            _buildIconButton(
                                              icon: LucideIcons.pencil,
                                              color: AppTheme.secondaryColor,
                                              onPressed: widget.onEdit,
                                              tooltip: AppLocalizations.of(
                                                context,
                                              )!.edit,
                                            ),
                                            const SizedBox(width: 4),
                                            _buildIconButton(
                                              icon: LucideIcons.trash2,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.error,
                                              onPressed: widget.onDelete,
                                              tooltip: AppLocalizations.of(
                                                context,
                                              )!.deleteButton,
                                            ),
                                            const SizedBox(width: 4),
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                ),
                                if (isMobile)
                                  _buildIconButton(
                                    icon: _isActionsExpanded
                                        ? LucideIcons.chevronRight
                                        : LucideIcons.chevronLeft,
                                    color: Theme.of(context).hintColor,
                                    onPressed: () {
                                      setState(() {
                                        _isActionsExpanded =
                                            !_isActionsExpanded;
                                      });
                                    },
                                    tooltip: _isActionsExpanded
                                        ? 'Hide'
                                        : 'Show',
                                  )
                                else
                                  _buildIconButton(
                                    icon: _isExpanded
                                        ? LucideIcons.chevronUp
                                        : LucideIcons.chevronDown,
                                    color: Theme.of(context).hintColor,
                                    onPressed: _toggleExpanded,
                                    tooltip: _isExpanded
                                        ? 'Collapse'
                                        : 'Expand',
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    if (widget.question.explanation.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.alertTriangle,
                              size: 14,
                              color: customColors.warning,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.missingExplanationTooltip,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: customColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Question Text Preview (Always visible)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ).copyWith(bottom: 20),
                      child: QuizdyLatexText(
                        widget.question.text,
                        maxLines: _isExpanded ? 100 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          decoration: isDisabled
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_isExpanded)
                Divider(height: 1, color: Theme.of(context).dividerColor),
              // Question Content
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isExpanded
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image if present
                            if (widget.question.image != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.memory(
                                  _getImageBytes(widget.question.image)!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        height: 150,
                                        width: double.infinity,
                                        color: Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
                                        child: Icon(
                                          LucideIcons.imageOff,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Options List
                            QuestionOptionsList(
                              question: widget.question,
                              isDisabled: isDisabled,
                            ),

                            // Explanation
                            if (widget.question.explanation.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surface.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          LucideIcons.lightbulb,
                                          size: 16,
                                          color: customColors.warning,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.explanationTitle,
                                          style: TextStyle(
                                            color: customColors.warning,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    QuizdyLatexText(
                                      widget.question.explanation,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                        fontSize: 14,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );

    return cardContent;
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
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
