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
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:quizdy/presentation/widgets/quizdy_latex_text.dart';

void main() {
  testWidgets('LaTeXText wraps text when it exceeds constraints', (
    WidgetTester tester,
  ) async {
    // A very long text that should definitely wrap in a narrow container
    const longText =
        'This is a very long text that should wrap to multiple lines if the widget is working correctly. '
        'If it is staying on a single line, then there is a bug in the implementation or configuration.';

    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 200, // Narrow width to force wrapping
            child: QuizdyLatexText(
              longText,
              style: TextStyle(
                fontSize: 20,
              ), // Large font to ensure it needs more than 200px
            ),
          ),
        ),
      ),
    );

    // Check if we found either
    expect(find.byType(QuizdyLatexText), findsOneWidget);

    // Verify it takes up enough height to be multi-line
    final Size size = tester.getSize(find.byType(QuizdyLatexText));

    // 20px font size. Single line would be around 20-24px height.
    // Multi-line should be significantly larger.
    expect(
      size.height,
      greaterThan(30.0),
      reason: 'Height should be greater than single line height',
    );
  });

  testWidgets('LaTeXText with LaTeX content wraps', (
    WidgetTester tester,
  ) async {
    const longLatexText =
        r'This is a mixed text with latex $E=mc^2$ that should also wrap when it gets too long for the container width. '
        r'More text here to ensure it definitely wraps $x^2 + y^2 = z^2$.';

    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 200,
            child: QuizdyLatexText(
              longLatexText,
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );

    final Size size = tester.getSize(find.byType(QuizdyLatexText));
    expect(
      size.height,
      greaterThan(30.0),
      reason:
          'Height should be greater than single line height for mixed content',
    );
  });

  testWidgets('LaTeXText supports double dollar sign (\$\$) display mode', (
    WidgetTester tester,
  ) async {
    const textWithDisplayMath = r'Formula in display mode: $$\frac{a}{b}$$';

    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: QuizdyLatexText(
            textWithDisplayMath,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );

    expect(find.byType(QuizdyLatexText), findsOneWidget);
    // Math.tex is used internally
    expect(find.byType(Math), findsOneWidget);
  });

  testWidgets('LaTeXText handles multiple math expressions in one string', (
    WidgetTester tester,
  ) async {
    const mixedMath =
        r'Inline $a^2$ and display $$\sqrt{x}$$ and another inline $y=2$.';

    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: QuizdyLatexText(mixedMath, style: TextStyle(fontSize: 20)),
        ),
      ),
    );

    expect(find.byType(QuizdyLatexText), findsOneWidget);
    expect(find.byType(Math), findsNWidgets(3));
  });

  testWidgets('LaTeXText handles unclosed dollar signs gracefully', (
    WidgetTester tester,
  ) async {
    const unclosed = r'This has an unclosed $ dollar sign.';

    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: QuizdyLatexText(unclosed, style: TextStyle(fontSize: 20)),
        ),
      ),
    );

    expect(find.text(unclosed), findsOneWidget);
  });
}
