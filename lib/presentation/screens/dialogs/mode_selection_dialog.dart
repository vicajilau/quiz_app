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
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/core/theme/extensions/confirm_dialog_colors_extension.dart';
import 'package:quizdy/core/theme/extensions/custom_colors.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';

class ModeSelectionDialog extends StatelessWidget {
  const ModeSelectionDialog({super.key});

  static Future<QuizMode?> show(BuildContext context) {
    return showDialog<QuizMode>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (_) => const ModeSelectionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;

    final studyColor = Theme.of(context).colorScheme.primary;
    final quizColor = customColors.onWarningContainer!;

    final studyBgColor = isDark ? AppTheme.violet900 : AppTheme.violet100;
    final quizBgColor = customColors.warningContainer!;

    return Dialog(
      backgroundColor: AppTheme.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppTheme.transparent : colors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizations.chooseModeDialogTitle,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: colors.title,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              localizations.chooseModeDialogMessage,
              style: TextStyle(fontSize: 14, color: colors.subtitle),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _ModeCard(
                      icon: LucideIcons.bookOpen,
                      label: localizations.studyModeLabel,
                      description: localizations.studyModeSubtitle,
                      accentColor: studyColor,
                      backgroundColor: studyBgColor,
                      borderColor: studyColor,
                      onTap: () => context.pop(QuizMode.study),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ModeCard(
                      icon: LucideIcons.trophy,
                      label: localizations.quizModeTitle,
                      description: localizations.examModeSubtitle,
                      accentColor: quizColor,
                      backgroundColor: quizBgColor,
                      borderColor: quizColor,
                      onTap: () => context.pop(QuizMode.quiz),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.pop(null),
              child: Text(
                localizations.cancelButton,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.subtitle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color accentColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.accentColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: widget.borderColor, width: 2),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 36, color: widget.accentColor),
              const SizedBox(height: 16),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: widget.accentColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.description,
                style: TextStyle(fontSize: 12, color: colors.subtitle),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
