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
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MarkdownWidget extends StatelessWidget {
  final String data;
  final TextStyle? style;

  const MarkdownWidget({super.key, required this.data, this.style});

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.bodyMedium;
    final effectiveStyle = style ?? defaultStyle;

    // Preprocess data to convert LaTeX dollar signs to brackets
    // since GptMarkdown only natively supports \( \) and \[ \]
    String preprocessedData = data;

    // Replace block math $$...$$ with \[...\]
    preprocessedData = preprocessedData.replaceAllMapped(
      RegExp(r'\$\$(.*?)\$\$', dotAll: true),
      (match) => '\\[${match.group(1)}\\]',
    );

    // Replace inline math $...$ with \(...\)
    preprocessedData = preprocessedData.replaceAllMapped(
      RegExp(r'(?<!\\)\$((?:\\.|[^$])+?)(?<!\\)\$'),
      (match) => '\\(${match.group(1)}\\)',
    );

    return GptMarkdown(
      preprocessedData,
      style: effectiveStyle,
      latexBuilder: (context, latex, latexStyle, inline) {
        return Math.tex(
          latex,
          mathStyle: inline ? MathStyle.text : MathStyle.display,
          textScaleFactor: inline ? 0.9 : 1.0,
          textStyle: latexStyle,
          onErrorFallback: (error) {
            return Text(
              '\$$latex\$',
              style: latexStyle.copyWith(color: Colors.red),
            );
          },
        );
      },
    );
  }
}
