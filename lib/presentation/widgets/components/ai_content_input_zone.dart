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

class AiContentInputZone extends StatelessWidget {
  final TextEditingController controller;
  final String wordCountText;
  final bool isTopicMode;

  const AiContentInputZone({
    super.key,
    required this.controller,
    required this.wordCountText,
    required this.isTopicMode,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.appColors;
    final inputBg = isDark ? AppTheme.borderColorDark : AppTheme.cardColorLight;

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
              wordCountText,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: isTopicMode
                    ? Theme.of(context).primaryColor
                    : colors.subtitle,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
