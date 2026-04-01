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
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/extensions/app_localizations_extension.dart';
import 'package:quizdy/data/services/ai/ai_service.dart';
import 'package:quizdy/domain/models/ai/ai_question_type.dart';
import 'package:quizdy/presentation/screens/dialogs/widgets/ai_question_type_chip.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/core/theme/extensions/confirm_dialog_colors_extension.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';
import 'package:quizdy/presentation/widgets/ai_service_model_selector.dart';

class AiGenerateStep1Widget extends StatelessWidget {
  final bool isStudyMode;
  final bool isLoadingServices;
  final List<AIService> availableServices;
  final AIService? selectedService;
  final String? selectedModel;
  final String selectedLanguage;
  final Set<AiQuestionType>? selectedQuestionTypes;
  final List<String> supportedLanguages;
  final ValueChanged<AIService> onServiceChanged;
  final ValueChanged<String?> onModelChanged;
  final ValueChanged<String> onLanguageChanged;
  final ValueChanged<AiQuestionType>? onQuestionTypeToggled;
  final VoidCallback onNext;

  const AiGenerateStep1Widget({
    super.key,
    this.isStudyMode = false,
    required this.isLoadingServices,
    required this.availableServices,
    required this.selectedService,
    required this.selectedModel,
    required this.selectedLanguage,
    this.selectedQuestionTypes,
    required this.supportedLanguages,
    required this.onServiceChanged,
    required this.onModelChanged,
    required this.onLanguageChanged,
    this.onQuestionTypeToggled,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.appColors;
    final borderColor = isDark ? Colors.transparent : AppTheme.borderColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 560,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isStudyMode
                          ? localizations.aiStudyGenerationTitle
                          : localizations.generateQuestionsWithAI,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: colors.title,
                      ),
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
            ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AiServiceModelSelector(
                      initialModel: selectedModel,
                      onModelChanged: onModelChanged,
                      saveToPreferences: false,
                    ),

                    if (!isStudyMode) ...[
                      const SizedBox(height: 24),

                      // Question Types
                      Text(
                        AppLocalizations.of(context)!.questionType,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colors.subtitle,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AiQuestionType.values.map((type) {
                          return AiQuestionTypeChip(
                            type: type,
                            isSelected:
                                selectedQuestionTypes?.contains(type) ?? false,
                            onTap: () => onQuestionTypeToggled?.call(type),
                            isDark: isDark,
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Language
                    Text(
                      isStudyMode
                          ? localizations.aiStudyLanguageLabel
                          : localizations.aiLanguageLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colors.subtitle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedLanguage,
                          isExpanded: true,
                          icon: Icon(
                            LucideIcons.chevronDown,
                            color: colors.title,
                            size: 18,
                          ),
                          dropdownColor: isDark
                              ? AppTheme.borderColorDark
                              : AppTheme.zinc100,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colors.title,
                          ),
                          items: supportedLanguages
                              .map(
                                (lang) => DropdownMenuItem(
                                  value: lang,
                                  child: Text(
                                    localizations.getLanguageName(lang),
                                  ),
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
                  ],
                ),
              ),
            ),

            // Footer (Fixed Next Button)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(height: 1, thickness: 1, color: colors.border),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                  child: QuizdyButton(
                    title: AppLocalizations.of(context)!.next,
                    icon: LucideIcons.arrowRight,
                    expanded: true,
                    onPressed: selectedService != null ? onNext : null,
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
