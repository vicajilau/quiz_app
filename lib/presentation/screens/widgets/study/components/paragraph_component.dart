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
import 'package:quizdy/domain/models/quiz/study_component.dart';
import 'package:quizdy/presentation/widgets/quizdy_markdown.dart';
import 'package:quizdy/core/theme/extensions/study_theme_extension.dart';

class ParagraphComponent extends StatelessWidget {
  final StudyComponent element;

  const ParagraphComponent({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final title = element.props['title']?.toString();
    final body = element.props['body']?.toString() ?? '';
    final studyTheme = context.studyTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title.isNotEmpty) ...[
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: studyTheme.cardTitle,
              ),
            ),
            const SizedBox(height: 12),
          ],
          QuizdyMarkdown(data: body),
        ],
      ),
    );
  }
}
