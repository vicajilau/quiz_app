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
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/domain/models/quiz/study_component.dart';
import 'package:quizdy/presentation/screens/widgets/common/markdown_widget.dart';
import 'package:quizdy/core/theme/extensions/study_theme_extension.dart';

class ReminderComponent extends StatelessWidget {
  final StudyComponent element;

  const ReminderComponent({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final body = element.props['body']?.toString() ?? '';
    final studyTheme = context.studyTheme;

    final backgroundColor = studyTheme.reminderBackground;
    final borderColor = studyTheme.reminderBorder;
    final iconColor = studyTheme.reminderIcon;

    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.lightbulb, color: iconColor, size: 16),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.studyScreenReminder,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MarkdownWidget(data: body),
        ],
      ),
    );
  }
}
