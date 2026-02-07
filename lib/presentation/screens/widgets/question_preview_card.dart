import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/presentation/widgets/latex_text.dart';

class QuestionPreviewCard extends StatefulWidget {
  final Question question;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final VoidCallback? onAiAssistant;
  final bool isSelectionMode;
  final bool isSelected;
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
    this.onSelectionToggle,
  });

  @override
  State<QuestionPreviewCard> createState() => _QuestionPreviewCardState();
}

class _QuestionPreviewCardState extends State<QuestionPreviewCard> {
  bool _isExpanded = false; // Collapsed by default as per user request

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

    return GestureDetector(
      onTap: widget.isSelectionMode
          ? widget.onSelectionToggle
          : _toggleExpanded,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF27272A), // Zinc 800 - Design specific
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.isSelected
                ? const Color(0xFF8B5CF6) // Violet 500 when selected
                : Colors.white.withValues(alpha: 0.05),
            width: widget.isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Question Index Badge and Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left Group: Selection + Badge + Type
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.isSelectionMode) ...[
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: widget.isSelected
                                        ? const Color(0xFF8B5CF6)
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: widget.isSelected
                                          ? const Color(0xFF8B5CF6)
                                          : const Color(0xFFA1A1AA),
                                    ),
                                  ),
                                  child: widget.isSelected
                                      ? const Icon(
                                          LucideIcons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                              ],

                              // Question Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3F3F46), // Zinc 700
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  (widget.index + 1).toString().padLeft(2, '0'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Question Type Badge (Always Full)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildQuestionTypeIcon(context),
                                    if (constraints.maxWidth > 340) ...[
                                      const SizedBox(width: 6),
                                      _buildQuestionTypeText(context),
                                    ],
                                  ],
                                ),
                              ),

                              // Minimum gap before actions
                              const SizedBox(width: 16),
                            ],
                          ),

                          // Right Group: Actions (Pinned to right if space allows)
                          if (widget.isSelectionMode)
                            ReorderableDragStartListener(
                              index: widget.index,
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.drag_indicator,
                                  color: Color(0xFFA1A1AA),
                                ),
                              ),
                            )
                          else
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.onAiAssistant != null && !isDisabled)
                                  _buildIconButton(
                                    icon: LucideIcons.sparkles,
                                    color: const Color(
                                      0xFF8B5CF6,
                                    ), // Violet 500
                                    onPressed: widget.onAiAssistant!,
                                    tooltip: AppLocalizations.of(
                                      context,
                                    )!.aiButtonTooltip,
                                  ),
                                const SizedBox(width: 8),
                                _buildIconButton(
                                  icon: LucideIcons.pencil,
                                  color: const Color(0xFF3B82F6), // Blue 500
                                  onPressed: widget.onEdit,
                                  tooltip: AppLocalizations.of(context)!.edit,
                                ),
                                const SizedBox(width: 8),
                                _buildIconButton(
                                  icon: LucideIcons.trash2,
                                  color: const Color(0xFFEF4444), // Red 500
                                  onPressed: widget.onDelete,
                                  tooltip: AppLocalizations.of(
                                    context,
                                  )!.deleteButton,
                                ),
                                const SizedBox(width: 8),
                                _buildIconButton(
                                  icon: _isExpanded
                                      ? LucideIcons.chevronUp
                                      : LucideIcons.chevronDown,
                                  color: const Color(0xFFA1A1AA), // Zinc 400
                                  onPressed: _toggleExpanded,
                                  tooltip: _isExpanded ? 'Collapse' : 'Expand',
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Question Text Preview (Always visible)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ).copyWith(bottom: 20),
              child: LaTeXText(
                widget.question.text,
                maxLines: _isExpanded ? 100 : 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Plus Jakarta Sans',
                  decoration: isDisabled ? TextDecoration.lineThrough : null,
                ),
              ),
            ),

            if (_isExpanded)
              const Divider(height: 1, color: Color(0xFF3F3F46)), // Separator
            // Question Content
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image if present
                          if (widget.question.image != null) ...[
                            const SizedBox(height: 20),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(
                                _getImageBytes(widget.question.image)!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      height: 150,
                                      width: double.infinity,
                                      color: const Color(0xFF18181B),
                                      child: const Icon(
                                        LucideIcons.imageOff,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Options List
                          _buildOptionsList(context, isDisabled),

                          // Explanation
                          if (widget.question.explanation.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF18181B), // Zinc 900
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF3F3F46), // Zinc 700
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        LucideIcons.lightbulb,
                                        size: 16,
                                        color: Color(0xFFFBBF24), // Amber 400
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.explanationTitle,
                                        style: const TextStyle(
                                          color: Color(0xFFFBBF24), // Amber 400
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  LaTeXText(
                                    widget.question.explanation,
                                    style: const TextStyle(
                                      color: Color(0xFFA1A1AA), // Zinc 400
                                      fontSize: 14,
                                      fontFamily: 'Inter',
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
    );
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

  Widget _buildOptionsList(BuildContext context, bool isDisabled) {
    return Column(
      children: widget.question.options.asMap().entries.map((entry) {
        final idx = entry.key;
        final option = entry.value;
        final isCorrect = widget.question.correctAnswers.contains(idx);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCorrect
                ? const Color(0xFF10B981).withValues(
                    alpha: 0.1,
                  ) // Emerald 500 with opacity
                : const Color(0xFF18181B), // Zinc 900
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCorrect
                  ? const Color(0xFF10B981) // Emerald 500
                  : const Color(0xFF3F3F46), // Zinc 700
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Option Letter Circle
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isCorrect
                      ? const Color(0xFF10B981)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCorrect
                        ? const Color(0xFF10B981)
                        : const Color(0xFF52525B), // Zinc 600
                  ),
                ),
                child: isCorrect
                    ? const Icon(
                        LucideIcons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : Text(
                        String.fromCharCode(65 + idx),
                        style: const TextStyle(
                          color: Color(0xFFA1A1AA), // Zinc 400
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              // Option Text
              Expanded(
                child: LaTeXText(
                  option,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    decoration: isDisabled ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuestionTypeIcon(BuildContext context) {
    IconData icon;
    switch (widget.question.type.value) {
      case 'multiple_choice':
        icon = LucideIcons.listChecks;
        break;
      case 'true_false':
        icon = LucideIcons.circleDot;
        break;
      case 'single_choice':
        icon = LucideIcons.circle;
        break;
      case 'essay':
        icon = LucideIcons.fileText;
        break;
      default:
        icon = LucideIcons.helpCircle;
    }

    return Icon(icon, size: 12, color: Colors.white);
  }

  Widget _buildQuestionTypeText(BuildContext context) {
    String text;
    switch (widget.question.type.value) {
      case 'multiple_choice':
        text = AppLocalizations.of(context)!.questionTypeMultipleChoice;
        break;
      case 'true_false':
        text = AppLocalizations.of(context)!.questionTypeTrueFalse;
        break;
      case 'single_choice':
        text = AppLocalizations.of(context)!.questionTypeSingleChoice;
        break;
      case 'essay':
        text = AppLocalizations.of(context)!.questionTypeEssay;
        break;
      default:
        text = AppLocalizations.of(context)!.questionTypeUnknown;
    }

    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      ),
    );
  }
}
