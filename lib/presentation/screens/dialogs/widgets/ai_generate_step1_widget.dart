import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/data/services/ai/ai_question_generation_service.dart';
import 'package:quiz_app/data/services/ai/ai_service.dart';
import 'package:quiz_app/presentation/screens/dialogs/widgets/ai_question_type_chip.dart';

class AiGenerateStep1Widget extends StatelessWidget {
  final bool isLoadingServices;
  final List<AIService> availableServices;
  final AIService? selectedService;
  final String? selectedModel;
  final String selectedLanguage;
  final Set<AiQuestionType> selectedQuestionTypes;
  final List<String> supportedLanguages;
  final ValueChanged<AIService> onServiceChanged;
  final ValueChanged<String?> onModelChanged;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<AiQuestionType> onQuestionTypeToggled;
  final VoidCallback onNext;
  final String Function(String code, AppLocalizations localizations)
  getLanguageName;

  const AiGenerateStep1Widget({
    super.key,
    required this.isLoadingServices,
    required this.availableServices,
    required this.selectedService,
    required this.selectedModel,
    required this.selectedLanguage,
    required this.selectedQuestionTypes,
    required this.supportedLanguages,
    required this.onServiceChanged,
    required this.onModelChanged,
    required this.onLanguageChanged,
    required this.onQuestionTypeToggled,
    required this.onNext,
    required this.getLanguageName,
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
    final labelColor = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF71717A);

    final isGeminiSelected =
        selectedService?.serviceName.toLowerCase().contains('gemini') ?? false;
    final isOpenAiSelected =
        selectedService?.serviceName.toLowerCase().contains('openai') ?? false;

    final isGeminiAvailable = availableServices.any(
      (s) => s.serviceName.toLowerCase().contains('gemini'),
    );
    final isOpenAiAvailable = availableServices.any(
      (s) => s.serviceName.toLowerCase().contains('openai'),
    );

    final geminiBgColor = isGeminiSelected
        ? const Color(0xFF8B5CF6)
        : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFF4F4F5));
    final geminiContentColor = isGeminiSelected
        ? Colors.white
        : (isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A));

    final openAiBgColor = isOpenAiSelected
        ? (isDark ? Colors.white : Colors.black)
        : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFF4F4F5));
    final openAiContentColor = isOpenAiSelected
        ? (isDark ? Colors.black : Colors.white)
        : (isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A));

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 560,
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
                      AppLocalizations.of(context)!.generateQuestionsWithAI,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
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
              const SizedBox(height: 24),

              // AI Service Label
              Text(
                localizations.aiServiceLabel.replaceAll(':', ''),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 12),

              // Service Options
              if (isLoadingServices)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    // Gemini Button
                    Expanded(
                      child: GestureDetector(
                        onTap: isGeminiAvailable
                            ? () {
                                final service = availableServices.firstWhere(
                                  (s) => s.serviceName.toLowerCase().contains(
                                    'gemini',
                                  ),
                                );
                                onServiceChanged(service);
                              }
                            : null,
                        child: Opacity(
                          opacity: isGeminiAvailable ? 1.0 : 0.5,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: geminiBgColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                // Calculate if text fits: Icon (18) + Gap (8) + Text (~50-60) + Padding (~16)
                                // A safe minimum width for text is around 100px.
                                // If less, show only icon.
                                final showText = constraints.maxWidth > 90;

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.sparkles,
                                      color: geminiContentColor,
                                      size: 18,
                                    ),
                                    if (showText) ...[
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          'Gemini',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: geminiContentColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // OpenAI Button
                    Expanded(
                      child: GestureDetector(
                        onTap: isOpenAiAvailable
                            ? () {
                                final service = availableServices.firstWhere(
                                  (s) => s.serviceName.toLowerCase().contains(
                                    'openai',
                                  ),
                                );
                                onServiceChanged(service);
                              }
                            : null,
                        child: Opacity(
                          opacity: isOpenAiAvailable ? 1.0 : 0.5,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: openAiBgColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                // Calculate if text fits: Icon (18) + Gap (8) + Text (~50-60) + Padding (~16)
                                // A safe minimum width for text is around 100px.
                                // If less, show only icon.
                                final showText = constraints.maxWidth > 90;

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.bot,
                                      color: openAiContentColor,
                                      size: 18,
                                    ),
                                    if (showText) ...[
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          'OpenAI',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: openAiContentColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // Model Selection
              Text(
                AppLocalizations.of(context)!.aiModelLabel.replaceAll(':', ''),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF3F3F46)
                      : const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedModel,
                    isExpanded: true,
                    icon: Icon(
                      LucideIcons.chevronDown,
                      color: closeIconColor,
                      size: 18,
                    ),
                    dropdownColor: isDark
                        ? const Color(0xFF3F3F46)
                        : const Color(0xFFF4F4F5),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                    items:
                        selectedService?.availableModels
                            .map(
                              (model) => DropdownMenuItem(
                                value: model,
                                child: Text(model),
                              ),
                            )
                            .toList() ??
                        [],
                    onChanged: onModelChanged,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Question Types
              Text(
                AppLocalizations.of(context)!.questionType,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AiQuestionType.values
                    .where((type) => type != AiQuestionType.random)
                    .map((type) {
                      return AiQuestionTypeChip(
                        type: type,
                        isSelected: selectedQuestionTypes.contains(type),
                        onTap: () => onQuestionTypeToggled(type),
                        isDark: isDark,
                      );
                    })
                    .toList(),
              ),

              const SizedBox(height: 24),

              // Language
              Text(
                AppLocalizations.of(context)!.aiLanguageLabel,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF3F3F46)
                      : const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedLanguage,
                    isExpanded: true,
                    icon: Icon(
                      LucideIcons.chevronDown,
                      color: closeIconColor,
                      size: 18,
                    ),
                    dropdownColor: isDark
                        ? const Color(0xFF3F3F46)
                        : const Color(0xFFF4F4F5),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                    items: supportedLanguages
                        .map(
                          (lang) => DropdownMenuItem(
                            value: lang,
                            child: Text(getLanguageName(lang, localizations)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        onLanguageChanged(value);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Next Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: selectedService != null ? onNext : null,
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
                      Text(AppLocalizations.of(context)!.next),
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.arrowRight, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
