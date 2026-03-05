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

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mime/mime.dart';
import 'package:quizdy/data/services/ai/ai_service.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/core/theme/extensions/confirm_dialog_colors_extension.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';
import 'package:quizdy/domain/models/ai/ai_generation_config.dart';
import 'package:quizdy/domain/models/ai/ai_study_generation_config.dart';
import 'package:quizdy/domain/models/ai/ai_question_type.dart';
import 'package:quizdy/domain/models/ai/ai_generation_category.dart';
import 'package:quizdy/domain/models/ai/ai_difficulty_level.dart';
import 'package:quizdy/presentation/widgets/dialog_drop_zone.dart';

class AiGenerateStep2Widget extends StatefulWidget {
  final bool isStudyMode;
  final TextEditingController textController;
  final TextEditingController? questionCountController;
  final int? questionCount;
  final AiFileAttachment? fileAttachment;
  final Set<AiQuestionType>? selectedQuestionTypes;
  final String selectedLanguage;
  final AIService? selectedService;
  final String? selectedModel;
  final VoidCallback onPickFile;
  final VoidCallback onRemoveFile;
  final VoidCallback onPasteFromClipboard;
  final ValueChanged<AiFileAttachment> onFileDropped;
  final VoidCallback onBack;
  final ValueChanged<int>? onQuestionCountChanged;
  final String Function() getWordCountText;
  final int Function() getWordCount;
  final int Function() getTopicCount;
  final ValueChanged<dynamic> onGenerate;

  const AiGenerateStep2Widget({
    super.key,
    this.isStudyMode = false,
    required this.textController,
    this.questionCountController,
    this.questionCount,
    required this.fileAttachment,
    this.selectedQuestionTypes,
    required this.selectedLanguage,
    required this.selectedService,
    required this.selectedModel,
    required this.onPickFile,
    required this.onRemoveFile,
    required this.onPasteFromClipboard,
    required this.onFileDropped,
    required this.onBack,
    this.onQuestionCountChanged,
    required this.getWordCountText,
    required this.getWordCount,
    required this.getTopicCount,
    required this.onGenerate,
  });

  @override
  State<AiGenerateStep2Widget> createState() => _AiGenerateStep2WidgetState();
}

class _AiGenerateStep2WidgetState extends State<AiGenerateStep2Widget> {
  late final FocusNode _questionCountFocusNode;
  AiGenerationCategory _selectedCategory = AiGenerationCategory.both;
  bool _isDragging = false;
  late bool _isAutoDifficulty;
  AiDifficultyLevel _selectedDifficulty = AiDifficultyLevel.university;

  @override
  void initState() {
    super.initState();
    _isAutoDifficulty = widget.fileAttachment != null;
    widget.textController.addListener(_onTextChanged);
    _questionCountFocusNode = FocusNode();
    _questionCountFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.textController.removeListener(_onTextChanged);
    _questionCountFocusNode.removeListener(_onFocusChange);
    _questionCountFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_questionCountFocusNode.hasFocus) {
      if (widget.questionCountController == null ||
          widget.questionCount == null) {
        return;
      }
      final text = widget.questionCountController!.text;
      final count = int.tryParse(text);
      if (count == null || count < 1 || count > 50) {
        // Reset to current valid count
        widget.questionCountController!.text = widget.questionCount.toString();
      }
    }
  }

  void _onTextChanged() {
    setState(() {});
  }

  Future<void> _handleDroppedFile(DropDoneDetails details) async {
    if (details.files.isEmpty) return;
    final file = details.files.first;
    final bytes = await file.readAsBytes();
    final mimeType =
        lookupMimeType(file.name, headerBytes: bytes) ??
        'application/octet-stream';
    widget.onFileDropped(
      AiFileAttachment(
        bytes: bytes,
        mimeType: mimeType,
        name: file.name,
        path: file.path,
      ),
    );
    setState(() {
      _isAutoDifficulty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.appColors;
    final borderColor = isDark ? Colors.transparent : AppTheme.borderColor;
    final inputBg = isDark ? AppTheme.borderColorDark : AppTheme.cardColorLight;
    final attachStroke = isDark ? AppTheme.zinc600 : AppTheme.zinc300;

    return DialogDropZone(
      onFilesDropped: _handleDroppedFile,
      onDragStateChanged: (isDragging) =>
          setState(() => _isDragging = isDragging),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: 600,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      localizations.aiEnterContentTitle,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: colors.title,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.surface,
                      fixedSize: const Size(40, 40),
                      padding: EdgeInsets.zero,
                      shape: const CircleBorder(),
                    ),
                    icon: Icon(LucideIcons.x, color: colors.subtitle, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                localizations.aiEnterContentDescription,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: colors.subtitle,
                ),
              ),
              const SizedBox(height: 24),

              // Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Input Area
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: widget.textController,
                                maxLines: null,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: colors.title,
                                ),
                                decoration: InputDecoration.collapsed(
                                  hintText: localizations.aiContentFieldHint,
                                  hintStyle: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    color: colors.surface,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              alignment: Alignment.centerRight,
                              child: Text(
                                widget.getWordCountText(),
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: widget.getTopicCount() > 10
                                      ? Theme.of(context).primaryColor
                                      : colors.subtitle,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Attach File
                      GestureDetector(
                        onTap: widget.onPickFile,
                        child: Container(
                          height: 64,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: _isDragging
                                ? Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.05)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isDragging
                                  ? Theme.of(context).primaryColor
                                  : attachStroke,
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isDragging
                                        ? LucideIcons.download
                                        : LucideIcons.paperclip,
                                    color: _isDragging
                                        ? Theme.of(context).primaryColor
                                        : colors.subtitle,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  if (_isDragging)
                                    Text(
                                      localizations.dropAttachmentHere,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  else if (widget.fileAttachment != null)
                                    Text(
                                      widget.fileAttachment!.name,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: colors.title,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  else
                                    Text(
                                      localizations.aiAttachFileHint,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: colors.subtitle,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  if (widget.fileAttachment != null &&
                                      !_isDragging)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12.0,
                                        right: 16.0,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          widget.onRemoveFile();
                                          setState(() {
                                            _isAutoDifficulty = false;
                                          });
                                        },
                                        child: Icon(
                                          LucideIcons.x,
                                          color: colors.title,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (widget.fileAttachment == null) ...[
                        const SizedBox(height: 8),
                        QuizdyButton(
                          type: QuizdyButtonType.secondary,
                          title: localizations.pasteFromClipboard,
                          icon: LucideIcons.clipboardPaste,
                          expanded: true,
                          onPressed: widget.onPasteFromClipboard,
                        ),
                      ],
                      if (!widget.isStudyMode) ...[
                        const SizedBox(height: 24),
                        _CollapsibleGenerationConfig(
                          isDark: isDark,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Content Mode (Category selection)
                              Text(
                                localizations.aiGenerationCategoryLabel,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: colors.subtitle,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: SegmentedButton<AiGenerationCategory>(
                                  segments: [
                                    ButtonSegment<AiGenerationCategory>(
                                      value: AiGenerationCategory.both,
                                      label: Text(
                                        localizations.aiGenerationCategoryBoth,
                                      ),
                                    ),
                                    ButtonSegment<AiGenerationCategory>(
                                      value: AiGenerationCategory.exercises,
                                      label: Text(
                                        localizations
                                            .aiGenerationCategoryExercises,
                                      ),
                                    ),
                                    ButtonSegment<AiGenerationCategory>(
                                      value: AiGenerationCategory.theory,
                                      label: Text(
                                        localizations
                                            .aiGenerationCategoryTheory,
                                      ),
                                    ),
                                  ],
                                  selected: <AiGenerationCategory>{
                                    _selectedCategory,
                                  },
                                  onSelectionChanged:
                                      (Set<AiGenerationCategory> newSelection) {
                                        setState(() {
                                          _selectedCategory =
                                              newSelection.first;
                                        });
                                      },
                                  showSelectedIcon: false,
                                  style: SegmentedButton.styleFrom(
                                    selectedBackgroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    selectedForegroundColor: Colors.white,
                                    backgroundColor: inputBg,
                                    side: BorderSide(color: attachStroke),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    textStyle: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Question Count
                              Text(
                                localizations.aiNumberQuestionsLabel,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: colors.subtitle,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Minus
                                  GestureDetector(
                                    onTap: () {
                                      if (widget.questionCount != null &&
                                          widget.questionCount! > 1) {
                                        widget.onQuestionCountChanged?.call(
                                          widget.questionCount! - 1,
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: colors.border,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        LucideIcons.minus,
                                        color: colors.title,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Display
                                  Expanded(
                                    child: Container(
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: colors.border,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: TextField(
                                        controller:
                                            widget.questionCountController,
                                        focusNode: _questionCountFocusNode,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(2),
                                        ],
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: colors.title,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                          isDense: true,
                                        ),
                                        onChanged: (value) {
                                          if (value.isEmpty) return;
                                          final count = int.tryParse(value);
                                          if (count != null) {
                                            if (count > 50) {
                                              widget.onQuestionCountChanged
                                                  ?.call(50);
                                            } else if (count > 0) {
                                              widget.onQuestionCountChanged
                                                  ?.call(count);
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Plus
                                  GestureDetector(
                                    onTap: () {
                                      if (widget.questionCount != null &&
                                          widget.questionCount! < 50) {
                                        widget.onQuestionCountChanged?.call(
                                          widget.questionCount! + 1,
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        LucideIcons.plus,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Difficulty Level
                              Text(
                                localizations.aiDifficultyTitle,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: colors.subtitle,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: inputBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: attachStroke),
                                ),
                                child: Column(
                                  children: [
                                    SwitchListTile(
                                      title: Text(
                                        _isAutoDifficulty
                                            ? localizations
                                                  .aiDifficultyAutoTurnedOn
                                            : localizations
                                                  .aiDifficultyAutoTurnedOff,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: colors.title,
                                        ),
                                      ),
                                      value: _isAutoDifficulty,
                                      onChanged: (value) {
                                        setState(() {
                                          _isAutoDifficulty = value;
                                        });
                                      },
                                      activeThumbColor: Theme.of(
                                        context,
                                      ).primaryColor,
                                    ),
                                    if (!_isAutoDifficulty) ...[
                                      Divider(height: 1, color: attachStroke),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<AiDifficultyLevel>(
                                            value: _selectedDifficulty,
                                            isExpanded: true,
                                            icon: Icon(
                                              LucideIcons.chevronDown,
                                              color: colors.subtitle,
                                              size: 16,
                                            ),
                                            dropdownColor: inputBg,
                                            items: [
                                              DropdownMenuItem(
                                                value: AiDifficultyLevel
                                                    .elementary,
                                                child: Text(
                                                  localizations
                                                      .aiDifficultyElementary,
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 14,
                                                    color: colors.title,
                                                  ),
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: AiDifficultyLevel
                                                    .highSchool,
                                                child: Text(
                                                  localizations
                                                      .aiDifficultyHighSchool,
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 14,
                                                    color: colors.title,
                                                  ),
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value:
                                                    AiDifficultyLevel.bachelors,
                                                child: Text(
                                                  localizations
                                                      .aiDifficultyBachelors,
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 14,
                                                    color: colors.title,
                                                  ),
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value: AiDifficultyLevel
                                                    .university,
                                                child: Text(
                                                  localizations
                                                      .aiDifficultyUniversity,
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 14,
                                                    color: colors.title,
                                                  ),
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value:
                                                    AiDifficultyLevel.masters,
                                                child: Text(
                                                  localizations
                                                      .aiDifficultyMasters,
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 14,
                                                    color: colors.title,
                                                  ),
                                                ),
                                              ),
                                              DropdownMenuItem(
                                                value:
                                                    AiDifficultyLevel.doctorate,
                                                child: Text(
                                                  localizations
                                                      .aiDifficultyDoctorate,
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 14,
                                                    color: colors.title,
                                                  ),
                                                ),
                                              ),
                                            ],
                                            onChanged:
                                                (AiDifficultyLevel? value) {
                                                  if (value != null) {
                                                    setState(() {
                                                      _selectedDifficulty =
                                                          value;
                                                    });
                                                  }
                                                },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Footer (Action Buttons)
              Row(
                children: [
                  Expanded(
                    child: QuizdyButton(
                      type: QuizdyButtonType.secondary,
                      title: localizations.backButton,
                      icon: LucideIcons.arrowLeft,
                      expanded: true,
                      onPressed: widget.onBack,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: QuizdyButton(
                      title: localizations.generateButton,
                      icon: LucideIcons.sparkles,
                      expanded: true,
                      onPressed:
                          (widget.textController.text.isNotEmpty ||
                              widget.fileAttachment != null)
                          ? () {
                              final config = widget.isStudyMode
                                  ? AiStudyGenerationConfig(
                                      language: widget.selectedLanguage,
                                      content: widget.textController.text
                                          .trim(),
                                      preferredService: widget.selectedService,
                                      preferredModel: widget.selectedModel,
                                      file: widget.fileAttachment,
                                      isTopicMode:
                                          widget.fileAttachment == null &&
                                          widget.getTopicCount() <= 10,
                                      isAutoDifficulty: _isAutoDifficulty,
                                      difficultyLevel: _isAutoDifficulty
                                          ? null
                                          : _selectedDifficulty,
                                    )
                                  : AiQuestionGenerationConfig(
                                      questionCount: widget.questionCount ?? 5,
                                      questionTypes:
                                          widget.selectedQuestionTypes
                                              ?.toList() ??
                                          [],
                                      language: widget.selectedLanguage,
                                      content: widget.textController.text
                                          .trim(),
                                      preferredService: widget.selectedService,
                                      preferredModel: widget.selectedModel,
                                      file: widget.fileAttachment,
                                      isTopicMode:
                                          widget.fileAttachment == null &&
                                          widget.getTopicCount() <= 10,
                                      generationCategory: _selectedCategory,
                                      isAutoDifficulty: _isAutoDifficulty,
                                      difficultyLevel: _isAutoDifficulty
                                          ? null
                                          : _selectedDifficulty,
                                    );
                              widget.onGenerate(config);
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollapsibleGenerationConfig extends StatefulWidget {
  final bool isDark;
  final Widget child;

  const _CollapsibleGenerationConfig({
    required this.isDark,
    required this.child,
  });

  @override
  State<_CollapsibleGenerationConfig> createState() =>
      _CollapsibleGenerationConfigState();
}

class _CollapsibleGenerationConfigState
    extends State<_CollapsibleGenerationConfig> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.isDark
        ? const Color(0xFF3F3F46)
        : const Color(0xFFE4E4E7);
    final headerBgColor = widget.isDark
        ? const Color(0xFF3F3F46)
        : const Color(0xFFF4F4F5);
    final bodyBgColor = widget.isDark
        ? const Color(0xFF1E1E22)
        : const Color(0xFFFAFAFA);
    final iconColor = widget.isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF71717A);
    final titleColor = widget.isDark ? Colors.white : const Color(0xFF18181B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: headerBgColor,
              borderRadius: _isExpanded
                  ? const BorderRadius.vertical(top: Radius.circular(12))
                  : BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.sparkles, size: 18, color: iconColor),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.generationConfigurationTitle,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                  ],
                ),
                Icon(
                  _isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                  size: 18,
                  color: iconColor,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.linear,
          child: _isExpanded
              ? Container(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  decoration: BoxDecoration(
                    color: bodyBgColor,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                    border: Border(
                      left: BorderSide(color: borderColor),
                      right: BorderSide(color: borderColor),
                      bottom: BorderSide(color: borderColor),
                    ),
                  ),
                  child: widget.child,
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
