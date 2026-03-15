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
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';
import 'package:quizdy/domain/models/ai/ai_difficulty_level.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/question.dart';
import 'package:quizdy/presentation/screens/dialogs/widgets/ai_chunk_selector_widget.dart';
import 'package:quizdy/presentation/screens/dialogs/widgets/ai_questions_selector_widget.dart';
import 'package:quizdy/presentation/widgets/dialog_drop_zone.dart';
import 'package:quizdy/presentation/widgets/components/ai_content_input_zone.dart';
import 'package:quizdy/presentation/widgets/components/ai_file_upload_zone.dart';
import 'package:quizdy/presentation/widgets/components/ai_generation_config_section.dart';
import 'package:quizdy/presentation/widgets/components/collapsible_generation_config.dart';

class AiGenerateStep2Widget extends StatefulWidget {
  final bool isStudyMode;
  final List<StudyChunk>? chunks;
  final List<Question>? questions;
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
  final bool isAutoDifficulty;
  final AiDifficultyLevel selectedDifficulty;
  final ValueChanged<bool> onAutoDifficultyChanged;
  final ValueChanged<AiDifficultyLevel> onDifficultyChanged;
  final AiGenerationCategory selectedCategory;
  final ValueChanged<AiGenerationCategory> onCategoryChanged;
  final ValueChanged<dynamic> onGenerate;

  const AiGenerateStep2Widget({
    super.key,
    this.isStudyMode = false,
    this.chunks,
    this.questions,
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
    required this.isAutoDifficulty,
    required this.selectedDifficulty,
    required this.onAutoDifficultyChanged,
    required this.onDifficultyChanged,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onGenerate,
  });

  @override
  State<AiGenerateStep2Widget> createState() => _AiGenerateStep2WidgetState();
}

class _AiGenerateStep2WidgetState extends State<AiGenerateStep2Widget> {
  late final FocusNode _questionCountFocusNode;
  late final ScrollController _scrollController;
  final GlobalKey _configKey = GlobalKey();
  bool _isDragging = false;
  bool _chunkSelectorEnabled = false;
  bool _questionSelectorEnabled = false;
  late Set<int> _selectedChunkIndices;
  late Set<int> _selectedQuestionIndices;

  @override
  void initState() {
    super.initState();
    widget.textController.addListener(_onTextChanged);
    _questionCountFocusNode = FocusNode();
    _questionCountFocusNode.addListener(_onFocusChange);
    _scrollController = ScrollController();
    final chunks = widget.chunks;
    if (chunks != null && chunks.isNotEmpty) {
      _selectedChunkIndices = chunks.map((c) => c.chunkIndex).toSet();
    } else {
      _selectedChunkIndices = {};
    }

    final questions = widget.questions;
    if (questions != null && questions.isNotEmpty) {
      _selectedQuestionIndices = Set<int>.from(
        List.generate(questions.length, (index) => index),
      );
    } else {
      _selectedQuestionIndices = {};
    }
  }

  @override
  void dispose() {
    widget.textController.removeListener(_onTextChanged);
    _questionCountFocusNode.removeListener(_onFocusChange);
    _questionCountFocusNode.dispose();
    _scrollController.dispose();
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
    widget.onAutoDifficultyChanged(true);
  }

  bool _isGenerateEnabled() {
    if (_questionSelectorEnabled) {
      return _selectedQuestionIndices.isNotEmpty;
    }
    if (_chunkSelectorEnabled) {
      return _selectedChunkIndices.isNotEmpty;
    }
    return widget.textController.text.isNotEmpty ||
        widget.fileAttachment != null;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.appColors;
    final borderColor = isDark ? Colors.transparent : AppTheme.borderColor;

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
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: colors.subtitle,
                ),
              ),
              const SizedBox(height: 24),

              // Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.chunks != null &&
                          widget.chunks!.isNotEmpty) ...[
                        AiChunkSelectorWidget(
                          chunks: widget.chunks!,
                          enabled: _chunkSelectorEnabled,
                          selectedIndices: _selectedChunkIndices,
                          onToggle: (value) {
                            setState(() {
                              _chunkSelectorEnabled = value;
                              if (value) {
                                _questionSelectorEnabled = false;
                              }
                            });
                          },
                          onChunkToggled: (index) {
                            setState(() {
                              if (_selectedChunkIndices.contains(index)) {
                                _selectedChunkIndices.remove(index);
                              } else {
                                _selectedChunkIndices.add(index);
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (widget.isStudyMode &&
                          widget.questions != null &&
                          widget.questions!.isNotEmpty) ...[
                        AiQuestionsSelectorWidget(
                          questions: widget.questions!,
                          enabled: _questionSelectorEnabled,
                          selectedIndices: _selectedQuestionIndices,
                          onToggle: (value) {
                            setState(() {
                              _questionSelectorEnabled = value;
                              if (value) {
                                _chunkSelectorEnabled = false;
                              }
                            });
                          },
                          onQuestionToggled: (index) {
                            setState(() {
                              if (_selectedQuestionIndices.contains(index)) {
                                _selectedQuestionIndices.remove(index);
                              } else {
                                _selectedQuestionIndices.add(index);
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (!_chunkSelectorEnabled &&
                          !_questionSelectorEnabled) ...[
                        // Input Area
                        AiContentInputZone(
                          controller: widget.textController,
                          wordCountText: widget.getWordCountText(),
                          generationMode: widget.fileAttachment != null
                              ? AiGenerationMode.context
                              : (widget.getTopicCount() > 10
                                    ? AiGenerationMode.topic
                                    : AiGenerationMode.text),
                        ),
                        const SizedBox(height: 12),

                        // Attach File
                        AiFileUploadZone(
                          onPickFile: widget.onPickFile,
                          onRemoveFile: widget.onRemoveFile,
                          onAutoDifficultyChanged:
                              widget.onAutoDifficultyChanged,
                          fileAttachment: widget.fileAttachment,
                          isDragging: _isDragging,
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
                        const SizedBox(height: 24),
                      ],
                      CollapsibleGenerationConfig(
                        key: _configKey,
                        onExpand: () {
                          // Expansion is now immediate, so we scroll after the next frame
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted && _configKey.currentContext != null) {
                              Scrollable.ensureVisible(
                                _configKey.currentContext!,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                                alignment: 1.0,
                              );
                            }
                          });
                        },
                        child: AiGenerationConfigSection(
                          isStudyMode: widget.isStudyMode,
                          selectedCategory: widget.selectedCategory,
                          onCategoryChanged: widget.onCategoryChanged,
                          questionCount: widget.questionCount,
                          questionCountController:
                              widget.questionCountController,
                          questionCountFocusNode: _questionCountFocusNode,
                          onQuestionCountChanged: (count) =>
                              widget.onQuestionCountChanged?.call(count),
                          isAutoDifficulty: widget.isAutoDifficulty,
                          hasFile: widget.fileAttachment != null,
                          onAutoDifficultyChanged:
                              widget.onAutoDifficultyChanged,
                          selectedDifficulty: widget.selectedDifficulty,
                          onDifficultyChanged: widget.onDifficultyChanged,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

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
                      onPressed: _isGenerateEnabled()
                          ? () {
                              if (_chunkSelectorEnabled &&
                                  widget.chunks != null) {
                                final selectedChunks = widget.chunks!
                                    .where(
                                      (c) => _selectedChunkIndices.contains(
                                        c.chunkIndex,
                                      ),
                                    )
                                    .toList();
                                final config = widget.isStudyMode
                                    ? AiStudyGenerationConfig(
                                        language: widget.selectedLanguage,
                                        content: '',
                                        preferredService:
                                            widget.selectedService,
                                        preferredModel: widget.selectedModel,
                                        file: null,
                                        generationMode: AiGenerationMode.text,
                                        isAutoDifficulty:
                                            widget.isAutoDifficulty,
                                        difficultyLevel: widget.isAutoDifficulty
                                            ? null
                                            : widget.selectedDifficulty,
                                      )
                                    : AiQuestionGenerationConfig(
                                        questionCount:
                                            widget.questionCount ?? 5,
                                        questionTypes:
                                            widget.selectedQuestionTypes
                                                ?.toList() ??
                                            [],
                                        language: widget.selectedLanguage,
                                        content: '',
                                        preferredService:
                                            widget.selectedService,
                                        preferredModel: widget.selectedModel,
                                        file: null,
                                        generationMode: AiGenerationMode.text,
                                        generationCategory:
                                            widget.selectedCategory,
                                        isAutoDifficulty:
                                            widget.isAutoDifficulty,
                                        difficultyLevel: widget.isAutoDifficulty
                                            ? null
                                            : widget.selectedDifficulty,
                                        selectedChunks: selectedChunks,
                                      );
                                widget.onGenerate(config);
                              } else if (_questionSelectorEnabled &&
                                  widget.questions != null) {
                                final selectedQuestions = widget.questions!
                                    .asMap()
                                    .entries
                                    .where(
                                      (entry) => _selectedQuestionIndices
                                          .contains(entry.key),
                                    )
                                    .map((entry) => entry.value)
                                    .toList();

                                final config = AiStudyGenerationConfig(
                                  language: widget.selectedLanguage,
                                  content: '',
                                  preferredService: widget.selectedService,
                                  preferredModel: widget.selectedModel,
                                  file: null,
                                  generationMode: AiGenerationMode.text,
                                  isAutoDifficulty: widget.isAutoDifficulty,
                                  difficultyLevel: widget.isAutoDifficulty
                                      ? null
                                      : widget.selectedDifficulty,
                                  selectedQuestions: selectedQuestions,
                                );
                                widget.onGenerate(config);
                              } else {
                                final mode = widget.fileAttachment != null
                                    ? AiGenerationMode.context
                                    : (widget.getTopicCount() <= 10
                                          ? AiGenerationMode.topic
                                          : AiGenerationMode.text);

                                final config = widget.isStudyMode
                                    ? AiStudyGenerationConfig(
                                        language: widget.selectedLanguage,
                                        content: widget.textController.text
                                            .trim(),
                                        preferredService:
                                            widget.selectedService,
                                        preferredModel: widget.selectedModel,
                                        file: widget.fileAttachment,
                                        generationMode: mode,
                                        isAutoDifficulty:
                                            widget.isAutoDifficulty,
                                        difficultyLevel: widget.isAutoDifficulty
                                            ? null
                                            : widget.selectedDifficulty,
                                      )
                                    : AiQuestionGenerationConfig(
                                        questionCount:
                                            widget.questionCount ?? 5,
                                        questionTypes:
                                            widget.selectedQuestionTypes
                                                ?.toList() ??
                                            [],
                                        language: widget.selectedLanguage,
                                        content: widget.textController.text
                                            .trim(),
                                        preferredService:
                                            widget.selectedService,
                                        preferredModel: widget.selectedModel,
                                        file: widget.fileAttachment,
                                        generationMode: mode,
                                        generationCategory:
                                            widget.selectedCategory,
                                        isAutoDifficulty:
                                            widget.isAutoDifficulty,
                                        difficultyLevel: widget.isAutoDifficulty
                                            ? null
                                            : widget.selectedDifficulty,
                                      );
                                widget.onGenerate(config);
                              }
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
