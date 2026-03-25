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
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/domain/models/ai/ai_generation_category.dart';
import 'package:quizdy/domain/models/ai/ai_difficulty_level.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/extensions/confirm_dialog_colors_extension.dart';
import 'package:quizdy/presentation/widgets/quizdy_switch.dart';
import 'package:quizdy/presentation/widgets/quizdy_text_field.dart';

class AiGenerationConfigSection extends StatelessWidget {
  final bool isStudyMode;
  final AiGenerationCategory selectedCategory;
  final ValueChanged<AiGenerationCategory> onCategoryChanged;
  final int? questionCount;
  final TextEditingController? questionCountController;
  final FocusNode? questionCountFocusNode;
  final ValueChanged<int>? onQuestionCountChanged;
  final bool isAutoDifficulty;
  final bool hasFile;
  final ValueChanged<bool> onAutoDifficultyChanged;
  final AiDifficultyLevel selectedDifficulty;
  final ValueChanged<AiDifficultyLevel> onDifficultyChanged;

  const AiGenerationConfigSection({
    super.key,
    required this.isStudyMode,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.questionCount,
    this.questionCountController,
    this.questionCountFocusNode,
    this.onQuestionCountChanged,
    required this.isAutoDifficulty,
    required this.hasFile,
    required this.onAutoDifficultyChanged,
    required this.selectedDifficulty,
    required this.onDifficultyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.appColors;
    final inputBg = isDark ? const Color(0xFF1E1E22) : const Color(0xFFFAFAFA);
    final attachStroke = isDark
        ? const Color(0xFF3F3F46)
        : const Color(0xFFE4E4E7);

    final isEffectivelyAuto = hasFile && isAutoDifficulty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isStudyMode) ...[
          // Content Mode (Category selection)
          Text(
            localizations.aiGenerationCategoryLabel,
            style: TextStyle(
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
                  label: Text(localizations.aiGenerationCategoryBoth),
                ),
                ButtonSegment<AiGenerationCategory>(
                  value: AiGenerationCategory.exercises,
                  label: Text(localizations.aiGenerationCategoryExercises),
                ),
                ButtonSegment<AiGenerationCategory>(
                  value: AiGenerationCategory.theory,
                  label: Text(localizations.aiGenerationCategoryTheory),
                ),
              ],
              selected: {selectedCategory},
              onSelectionChanged: (Set<AiGenerationCategory> newSelection) {
                onCategoryChanged(newSelection.first);
              },
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: Theme.of(context).primaryColor,
                selectedForegroundColor: Colors.white,
                backgroundColor: inputBg,
                side: BorderSide(color: attachStroke),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
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
                  if (onQuestionCountChanged != null &&
                      questionCount != null &&
                      questionCount! > 1) {
                    onQuestionCountChanged!(questionCount! - 1);
                  }
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(LucideIcons.minus, color: colors.title, size: 18),
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
                  child: QuizdyTextField(
                    controller:
                        questionCountController ?? TextEditingController(),
                    focusNode: questionCountFocusNode ?? FocusNode(),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    onChanged: (value) {
                      if (value.isEmpty || onQuestionCountChanged == null) {
                        return;
                      }
                      final count = int.tryParse(value);
                      if (count != null) {
                        if (count > 50) {
                          onQuestionCountChanged!(50);
                        } else if (count > 0) {
                          onQuestionCountChanged!(count);
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
                  if (onQuestionCountChanged != null &&
                      questionCount != null &&
                      questionCount! < 50) {
                    onQuestionCountChanged!(questionCount! + 1);
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
        ],

        // Difficulty Level
        Text(
          localizations.aiDifficultyTitle,
          style: TextStyle(
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEffectivelyAuto
                                ? localizations.aiDifficultyAutoTurnedOn
                                : localizations.aiDifficultyAutoTurnedOff,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: colors.title,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isEffectivelyAuto
                                ? localizations.aiDifficultyAutoDescription
                                : localizations.aiDifficultyManualDescription,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: colors.subtitle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    QuizdySwitch(
                      value: isEffectivelyAuto,
                      onChanged: !hasFile
                          ? null
                          : (value) {
                              onAutoDifficultyChanged(value);
                            },
                    ),
                  ],
                ),
              ),
              if (!isEffectivelyAuto) ...[
                Divider(height: 1, color: attachStroke),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<AiDifficultyLevel>(
                      value: selectedDifficulty,
                      isExpanded: true,
                      icon: Icon(
                        LucideIcons.chevronDown,
                        color: colors.subtitle,
                        size: 16,
                      ),
                      dropdownColor: inputBg,
                      items: [
                        DropdownMenuItem(
                          value: AiDifficultyLevel.elementary,
                          child: Text(
                            localizations.aiDifficultyElementary,
                            style: TextStyle(fontSize: 14, color: colors.title),
                          ),
                        ),
                        DropdownMenuItem(
                          value: AiDifficultyLevel.highSchool,
                          child: Text(
                            localizations.aiDifficultyHighSchool,
                            style: TextStyle(fontSize: 14, color: colors.title),
                          ),
                        ),
                        DropdownMenuItem(
                          value: AiDifficultyLevel.bachelors,
                          child: Text(
                            localizations.aiDifficultyBachelors,
                            style: TextStyle(fontSize: 14, color: colors.title),
                          ),
                        ),
                        DropdownMenuItem(
                          value: AiDifficultyLevel.university,
                          child: Text(
                            localizations.aiDifficultyUniversity,
                            style: TextStyle(fontSize: 14, color: colors.title),
                          ),
                        ),
                        DropdownMenuItem(
                          value: AiDifficultyLevel.masters,
                          child: Text(
                            localizations.aiDifficultyMasters,
                            style: TextStyle(fontSize: 14, color: colors.title),
                          ),
                        ),
                        DropdownMenuItem(
                          value: AiDifficultyLevel.doctorate,
                          child: Text(
                            localizations.aiDifficultyDoctorate,
                            style: TextStyle(fontSize: 14, color: colors.title),
                          ),
                        ),
                      ],
                      onChanged: (AiDifficultyLevel? value) {
                        if (value != null) {
                          onDifficultyChanged(value);
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
    );
  }
}
