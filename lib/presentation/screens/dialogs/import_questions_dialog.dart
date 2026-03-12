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
import 'package:quizdy/presentation/widgets/quizdy_button.dart';

enum QuestionsPosition { beginning, end }

/// Shared dialog for importing items (questions or chunks) at a position.
///
/// Accepts pre-resolved [title], [message], and [positionQuestion] strings so
/// it can be reused for different content types without duplicating layout code.
class ImportPositionDialog extends StatelessWidget {
  final String title;
  final String message;
  final String positionQuestion;
  final String importAtBeginning;
  final String importAtEnd;
  final String cancelButton;

  const ImportPositionDialog({
    super.key,
    required this.title,
    required this.message,
    required this.positionQuestion,
    required this.importAtBeginning,
    required this.importAtEnd,
    required this.cancelButton,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.appColors;
    final borderColor = isDark ? Colors.transparent : AppTheme.borderColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colors.title,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: colors.subtitle,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              positionQuestion,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.subtitle,
              ),
            ),
            const SizedBox(height: 24),
            QuizdyButton(
              title: importAtBeginning,
              icon: LucideIcons.arrowUpToLine,
              expanded: true,
              onPressed: () => context.pop(QuestionsPosition.beginning),
            ),
            const SizedBox(height: 8),
            QuizdyButton(
              title: importAtEnd,
              icon: LucideIcons.arrowDownToLine,
              expanded: true,
              onPressed: () => context.pop(QuestionsPosition.end),
            ),
            const SizedBox(height: 8),
            QuizdyButton(
              type: QuizdyButtonType.tertiary,
              title: cancelButton,
              expanded: true,
              onPressed: () => context.pop(null),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog to confirm importing questions from another quiz file
class ImportQuestionsDialog extends StatelessWidget {
  final int questionCount;
  final String fileName;

  const ImportQuestionsDialog({
    super.key,
    required this.questionCount,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return ImportPositionDialog(
      title: localizations.importQuestionsTitle,
      message: localizations.importQuestionsMessage(questionCount, fileName),
      positionQuestion: localizations.importQuestionsPositionQuestion,
      importAtBeginning: localizations.importAtBeginning,
      importAtEnd: localizations.importAtEnd,
      cancelButton: localizations.cancelButton,
    );
  }
}
