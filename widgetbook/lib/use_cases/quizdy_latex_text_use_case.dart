// Copyright (C) 2026 Victor Carreras
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
import 'package:quizdy/presentation/widgets/quizdy_latex_text.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'All variants', type: QuizdyLatexText)
Widget buildQuizdyLatexTextUseCase(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      children: [
        _LatexCard(
          title: 'Plain text (no LaTeX)',
          child: const QuizdyLatexText(
            'The quick brown fox jumps over the lazy dog.',
          ),
        ),
        const SizedBox(height: 10.0),
        _LatexCard(
          title: 'Inline math',
          child: const QuizdyLatexText(
            r'The area of a circle is $A = \pi r^2$ where $r$ is the radius.',
          ),
        ),
        const SizedBox(height: 10.0),
        _LatexCard(
          title: 'Display math (block)',
          child: const QuizdyLatexText(
            r'The quadratic formula: $$x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}$$',
          ),
        ),
        const SizedBox(height: 10.0),
        _LatexCard(
          title: 'Mixed content',
          child: const QuizdyLatexText(
            r"Einstein's famous equation $E = mc^2$ relates energy $E$ to mass $m$ "
            r'and the speed of light $c$. In integral form: $$\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}$$',
          ),
        ),
        const SizedBox(height: 10.0),
        _LatexCard(
          title: 'Custom style',
          child: QuizdyLatexText(
            r'Euler identity: $e^{i\pi} + 1 = 0$',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Interactive', type: QuizdyLatexText)
Widget buildInteractiveQuizdyLatexTextUseCase(BuildContext context) {
  final text = context.knobs.string(
    label: 'Text',
    initialValue:
        r'The area of a circle is $A = \pi r^2$ where $r$ is the radius.',
  );
  final fontSize = context.knobs.double.slider(
    label: 'Font size',
    initialValue: 14,
    min: 8,
    max: 36,
    divisions: 28,
  );
  final fontWeight = context.knobs.object.dropdown<FontWeight>(
    label: 'Font weight',
    options: [
      FontWeight.w400,
      FontWeight.w500,
      FontWeight.w600,
      FontWeight.bold,
    ],
    initialOption: FontWeight.w400,
    labelBuilder: (w) {
      if (w == FontWeight.w400) return 'Regular (400)';
      if (w == FontWeight.w500) return 'Medium (500)';
      if (w == FontWeight.w600) return 'SemiBold (600)';
      return 'Bold (700)';
    },
  );
  final overflow = context.knobs.object.dropdown<TextOverflow>(
    label: 'Overflow',
    options: TextOverflow.values,
    initialOption: TextOverflow.clip,
    labelBuilder: (o) => o.name,
  );
  final maxLines = context.knobs.intOrNull.slider(
    label: 'Max lines',
    initialValue: null,
    min: 1,
    max: 10,
  );

  return QuizdyLatexText(
    text,
    style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
    overflow: overflow,
    maxLines: maxLines,
  );
}

class _LatexCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _LatexCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12.0),
            child,
          ],
        ),
      ),
    );
  }
}
