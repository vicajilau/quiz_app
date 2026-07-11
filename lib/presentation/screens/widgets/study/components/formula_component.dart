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
import 'package:quizdy/presentation/widgets/quizdy_markdown.dart';
import 'package:quizdy/presentation/widgets/quizdy_latex_text.dart';
import 'package:quizdy/core/theme/extensions/study_theme_extension.dart';

part 'formula_component.genui.g.dart';

@GenerativeUI(name: 'formula')
class FormulaComponent extends StatelessWidget {
  final String? title;
  final String equation;
  final String? equationLabel;
  final String? body;

  const FormulaComponent({
    super.key,
    this.title,
    required this.equation,
    this.equationLabel,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    final equationLabel = this.equationLabel;
    final body = this.body;
    final studyTheme = context.studyTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title.isNotEmpty) ...[
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 16.0,
            ),
            decoration: BoxDecoration(
              color: studyTheme.formulaBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: QuizdyLatexText(
                    equation.trim().startsWith('\$')
                        ? equation
                        : '\$$equation\$',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: studyTheme.formulaText,
                    ),
                  ),
                ),
                if (equationLabel != null && equationLabel.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    equationLabel,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: studyTheme.formulaLabel,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (body != null && body.isNotEmpty) ...[
            const SizedBox(height: 12),
            QuizdyMarkdown(data: body),
          ],
        ],
      ),
    );
  }
}
