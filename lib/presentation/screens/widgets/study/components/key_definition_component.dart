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
import 'package:quizdy/domain/models/quiz/ui_element.dart';
import 'package:quizdy/presentation/screens/widgets/common/markdown_widget.dart';

class KeyDefinitionComponent extends StatelessWidget {
  final UiElement element;

  const KeyDefinitionComponent({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final term = element.props['term']?.toString() ?? '';
    final body = element.props['body']?.toString() ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.key,
                color: Theme.of(context).primaryColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.studyScreenKeyDefinition,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            term,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF4F4F5) : const Color(0xFF18181B),
            ),
          ),
          const SizedBox(height: 8),
          MarkdownWidget(data: body),
        ],
      ),
    );
  }
}
