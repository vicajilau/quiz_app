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
import 'package:genui/genui.dart';
import 'package:genui_annotations/genui_annotations.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quizdy/presentation/widgets/quizdy_latex_text.dart';
import 'package:quizdy/core/theme/extensions/study_theme_extension.dart';

part 'quote_component.genui.g.dart';

@GenerativeUI(name: 'quote')
class QuoteComponent extends StatelessWidget {
  final String body;
  final String? author;

  const QuoteComponent({super.key, required this.body, this.author});

  @override
  Widget build(BuildContext context) {
    final author = this.author;
    final studyTheme = context.studyTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: studyTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: studyTheme.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            LucideIcons.quote,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.6),
            size: 32,
          ),
          const SizedBox(height: 12),
          QuizdyLatexText(
            '"$body"',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              fontSize: 16,
              height: 1.5,
              color: studyTheme.cardSubtitle,
            ),
          ),
          if (author != null && author.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              alignment: Alignment.centerRight,
              child: Text(
                '— $author',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: studyTheme.cardSubtitle,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
