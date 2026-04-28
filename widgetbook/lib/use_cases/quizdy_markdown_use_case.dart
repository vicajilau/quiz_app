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
import 'package:quizdy/presentation/widgets/quizdy_markdown.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'All variants', type: QuizdyMarkdown)
Widget buildQuizdyMarkdownUseCase(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      children: const [
        _MarkdownCard(
          title: 'Plain text',
          data: 'This is a simple paragraph with plain text content.',
        ),
        SizedBox(height: 10.0),
        _MarkdownCard(
          title: 'Headings',
          data:
              '# Heading 1\n\n## Heading 2\n\n### Heading 3\n\nBody text below.',
        ),
        SizedBox(height: 10.0),
        _MarkdownCard(
          title: 'Bold, italic & lists',
          data:
              '**Bold text** and *italic text*.\n\n'
              '- Item one\n'
              '- Item two\n'
              '- Item three',
        ),
        SizedBox(height: 10.0),
        _MarkdownCard(
          title: 'Inline code & code block',
          data:
              'Use `print()` to output values.\n\n'
              '```dart\nvoid main() {\n  print("Hello, Quizdy!");\n}\n```',
        ),
        SizedBox(height: 10.0),
        _MarkdownCard(
          title: 'With LaTeX (inline)',
          data: r'The derivative of $f(x) = x^2$ is $f(x) = 2x$.',
        ),
        SizedBox(height: 10.0),
        _MarkdownCard(
          title: 'With LaTeX (block)',
          data:
              r'The Pythagorean theorem:'
              '\n\n'
              r'$$a^2 + b^2 = c^2$$',
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Interactive', type: QuizdyMarkdown)
Widget buildInteractiveQuizdyMarkdownUseCase(BuildContext context) {
  final data = context.knobs.string(
    label: 'Content',
    initialValue:
        '# Hello\n\nThis is **bold** and *italic* text.\n\n- Item 1\n- Item 2\n\n'
        r'Inline math: $E = mc^2$',
  );
  final fontSize = context.knobs.double.slider(
    label: 'Font size',
    initialValue: 14,
    min: 8,
    max: 28,
    divisions: 20,
  );

  return QuizdyMarkdown(
    data: data,
    style: TextStyle(fontSize: fontSize),
  );
}

class _MarkdownCard extends StatelessWidget {
  final String title;
  final String data;

  const _MarkdownCard({required this.title, required this.data});

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
            QuizdyMarkdown(data: data),
          ],
        ),
      ),
    );
  }
}
