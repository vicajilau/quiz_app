import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quiz_app/data/services/ai/ai_question_generation_service.dart';
import 'package:quiz_app/data/services/ai/ai_service.dart';
import 'package:quiz_app/domain/models/ai/ai_file_attachment.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';

class AiGenerateStep2Widget extends StatelessWidget {
  final TextEditingController textController;
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

  const AiGenerateStep2Widget({
    super.key,
    required this.textController,
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
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF27272A) : Colors.white;
    final borderColor = isDark ? Colors.transparent : const Color(0xFFE4E4E7);
    final titleColor = isDark ? Colors.white : const Color(0xFF18181B);
    final closeBtnColor = isDark
        ? const Color(0xFF3F3F46)
        : const Color(0xFFF4F4F5);
    final closeIconColor = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF71717A);
    final inputBg = isDark ? const Color(0xFF3F3F46) : const Color(0xFFF4F4F5);
    final placeholderColor = isDark
        ? const Color(0xFF71717A)
        : const Color(0xFFA1A1AA);
    final attachStroke = isDark
        ? const Color(0xFF52525B)
        : const Color(0xFFD4D4D8);
    final labelColor = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF71717A);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 800),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: SingleChildScrollView(
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
                        color: titleColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: closeBtnColor,
                      fixedSize: const Size(40, 40),
                      padding: EdgeInsets.zero,
                      shape: const CircleBorder(),
                    ),
                    icon: Icon(LucideIcons.x, color: closeIconColor, size: 20),
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
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 24),

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
                        controller: textController,
                        maxLines: null,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: titleColor,
                        ),
                        decoration: InputDecoration.collapsed(
                          hintText: localizations.aiContentFieldHint,
                          hintStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: placeholderColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.centerRight,
                      child: Text(
                        getWordCountText(),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: getWordCount() > 10
                              ? const Color(0xFF8B5CF6)
                              : labelColor,
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
                onTap: onPickFile,
                child: Container(
                  height: 64,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: attachStroke, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsGeometry.only(left: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.paperclip,
                          color: labelColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        fileAttachment != null
                            ? Expanded(
                                child: Text(
                                  fileAttachment!.name,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: labelColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            : Text(
                                localizations.aiAttachFileHint,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: labelColor,
                                ),
                              ),
                        if (fileAttachment != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: GestureDetector(
                              onTap: onRemoveFile,
                              child: Icon(
                                LucideIcons.x,
                                color: labelColor,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
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
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Minus
                  GestureDetector(
                    onTap: () {
                      if (questionCount > 1) {
                        onQuestionCountChanged(questionCount - 1);
                      }
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: closeBtnColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        LucideIcons.minus,
                        color: titleColor,
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
                        color: closeBtnColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$questionCount',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Plus
                  GestureDetector(
                    onTap: () {
                      if (questionCount < 50) {
                        onQuestionCountChanged(questionCount + 1);
                      }
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6),
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

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: onBack,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: closeBtnColor,
                          foregroundColor: titleColor,
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.arrowLeft, size: 16),
                            const SizedBox(width: 8),
                            Text(localizations.backButton),
                          ],
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
                            (textController.text.isNotEmpty ||
                                fileAttachment != null)
                            ? () {
                                final config = AiQuestionGenerationConfig(
                                  questionCount: questionCount,
                                  questionTypes: selectedQuestionTypes.toList(),
                                  language: selectedLanguage,
                                  content: textController.text.trim(),
                                  preferredService: selectedService,
                                  preferredModel: selectedModel,
                                  file: fileAttachment,
                                );
                                context.pop(config);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.sparkles, size: 16),
                            const SizedBox(width: 8),
                            Text(localizations.generateButton),
                          ],
                        ),
                      ),
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
