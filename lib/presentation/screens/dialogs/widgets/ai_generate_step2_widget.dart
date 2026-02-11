import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quiz_app/data/services/ai/ai_question_generation_service.dart';
import 'package:quiz_app/data/services/ai/ai_service.dart';
import 'package:quiz_app/domain/models/ai/ai_file_attachment.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/core/theme/app_theme.dart';
import 'package:quiz_app/core/theme/extensions/confirm_dialog_colors_extension.dart';

class AiGenerateStep2Widget extends StatefulWidget {
  final TextEditingController textController;
  final TextEditingController questionCountController;
  final int questionCount;
  final AiFileAttachment? fileAttachment;
  final Set<AiQuestionType> selectedQuestionTypes;
  final String selectedLanguage;
  final AIService? selectedService;
  final String? selectedModel;
  final VoidCallback onPickFile;
  final VoidCallback onRemoveFile;
  final VoidCallback onBack;
  final ValueChanged<int> onQuestionCountChanged;
  final String Function() getWordCountText;
  final int Function() getWordCount;
  final int Function() getTopicCount;

  const AiGenerateStep2Widget({
    super.key,
    required this.textController,
    required this.questionCountController,
    required this.questionCount,
    required this.fileAttachment,
    required this.selectedQuestionTypes,
    required this.selectedLanguage,
    required this.selectedService,
    required this.selectedModel,
    required this.onPickFile,
    required this.onRemoveFile,
    required this.onBack,
    required this.onQuestionCountChanged,
    required this.getWordCountText,
    required this.getWordCount,
    required this.getTopicCount,
  });

  @override
  State<AiGenerateStep2Widget> createState() => _AiGenerateStep2WidgetState();
}

class _AiGenerateStep2WidgetState extends State<AiGenerateStep2Widget> {
  late final FocusNode _questionCountFocusNode;

  @override
  void initState() {
    super.initState();
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
      final text = widget.questionCountController.text;
      final count = int.tryParse(text);
      if (count == null || count < 1 || count > 50) {
        // Reset to current valid count
        widget.questionCountController.text = widget.questionCount.toString();
      }
    }
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.appColors;
    final borderColor = isDark ? Colors.transparent : AppTheme.borderColor;
    final inputBg = isDark ? AppTheme.borderColorDark : AppTheme.cardColorLight;
    final attachStroke = isDark ? AppTheme.zinc600 : AppTheme.zinc300;

    return Dialog(
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
                                    ? AppTheme.primaryColor
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
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: attachStroke, width: 2),
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
                                  LucideIcons.paperclip,
                                  color: colors.subtitle,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                widget.fileAttachment != null
                                    ? Text(
                                        widget.fileAttachment!.name,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: colors.title,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : Text(
                                        localizations.aiAttachFileHint,
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: colors.subtitle,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                if (widget.fileAttachment != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 12.0,
                                      right: 16.0,
                                    ),
                                    child: GestureDetector(
                                      onTap: widget.onRemoveFile,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Minus
                        GestureDetector(
                          onTap: () {
                            if (widget.questionCount > 1) {
                              widget.onQuestionCountChanged(
                                widget.questionCount - 1,
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
                              controller: widget.questionCountController,
                              focusNode: _questionCountFocusNode,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
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
                                    widget.onQuestionCountChanged(50);
                                  } else if (count > 0) {
                                    widget.onQuestionCountChanged(count);
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
                            if (widget.questionCount < 50) {
                              widget.onQuestionCountChanged(
                                widget.questionCount + 1,
                              );
                            }
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Footer (Action Buttons)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: widget.onBack,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.surface,
                        foregroundColor: colors.title,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.arrowLeft, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              localizations.backButton,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          (widget.textController.text.isNotEmpty ||
                              widget.fileAttachment != null)
                          ? () {
                              final config = AiQuestionGenerationConfig(
                                questionCount: widget.questionCount,
                                questionTypes: widget.selectedQuestionTypes
                                    .toList(),
                                language: widget.selectedLanguage,
                                content: widget.textController.text.trim(),
                                preferredService: widget.selectedService,
                                preferredModel: widget.selectedModel,
                                file: widget.fileAttachment,
                                isTopicMode:
                                    widget.fileAttachment == null &&
                                    widget.getTopicCount() <= 10,
                              );
                              context.pop(config);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.sparkles, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              localizations.generateButton,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
