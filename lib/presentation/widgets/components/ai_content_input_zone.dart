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
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/core/theme/extensions/confirm_dialog_colors_extension.dart';
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';
import 'package:quizdy/core/theme/extensions/custom_colors.dart';

class AiContentInputZone extends StatelessWidget {
  final TextEditingController controller;
  final String wordCountText;
  final AiGenerationMode generationMode;

  const AiContentInputZone({
    super.key,
    required this.controller,
    required this.wordCountText,
    required this.generationMode,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.appColors;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final inputBg = isDark ? AppTheme.borderColorDark : AppTheme.cardColorLight;
    final textColor = isDark ? Colors.white : AppTheme.textColor;

    return Container(
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
              controller: controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: TextStyle(fontSize: 14, color: textColor, height: 1.65),
              decoration: InputDecoration(
                hintText: localizations.aiContentFieldHint,
                hintStyle: const TextStyle(
                  color: AppTheme.zinc500,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            alignment: Alignment.centerRight,
            child: Text(
              wordCountText,
              style: TextStyle(
                fontSize: 12,
                color: generationMode == AiGenerationMode.topic
                    ? Theme.of(context).primaryColor
                    : (generationMode == AiGenerationMode.context
                          ? customColors.success
                          : colors.subtitle),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
