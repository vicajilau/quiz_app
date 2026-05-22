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
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';

enum QuizSelectionMode { exam, practice, smart }

class QuizModeSelection extends StatelessWidget {
  final QuizSelectionMode selectedMode;
  final ValueChanged<QuizSelectionMode> onModeChanged;
  final Color primaryColor;
  final Color controlBgColor;
  final Color subTextColor;

  const QuizModeSelection({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
    required this.primaryColor,
    required this.controlBgColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.quizModeTitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: subTextColor,
          ),
        ),
        const SizedBox(height: 12),
        _buildModeOption(
          context: context,
          title: localizations.examModeLabel,
          icon: LucideIcons.fileText,
          isSelected: selectedMode == QuizSelectionMode.exam,
          onTap: () => onModeChanged(QuizSelectionMode.exam),
          primaryColor: primaryColor,
          defaultBgColor: controlBgColor,
          defaultTextColor: subTextColor,
          expand: true,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildModeOption(
                context: context,
                title: localizations.practiceModeLabel,
                icon: LucideIcons.bookOpen,
                isSelected: selectedMode == QuizSelectionMode.practice,
                onTap: () => onModeChanged(QuizSelectionMode.practice),
                primaryColor: primaryColor,
                defaultBgColor: controlBgColor,
                defaultTextColor: subTextColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModeOption(
                context: context,
                title: localizations.smartModeLabel,
                icon: LucideIcons.brain,
                isSelected: selectedMode == QuizSelectionMode.smart,
                onTap: () => onModeChanged(QuizSelectionMode.smart),
                primaryColor: primaryColor,
                defaultBgColor: controlBgColor,
                defaultTextColor: subTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
    required Color defaultBgColor,
    required Color defaultTextColor,
    bool expand = false,
  }) {
    return IconButton(
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: isSelected ? primaryColor : defaultBgColor,
        foregroundColor: isSelected ? Colors.white : defaultTextColor,
        minimumSize: const Size(double.infinity, 92),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: SizedBox(
        width: expand ? double.infinity : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : defaultTextColor,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : defaultTextColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
