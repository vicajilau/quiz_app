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
import 'package:flutter_math_fork/flutter_math.dart';

/// A widget that renders text with LaTeX support.
///
/// Uses [Math.tex] to render LaTeX expressions wrapped in `$...$` (inline)
/// or `$$...$$` (display mode). Plain text is rendered normally.
class LaTeXText extends StatelessWidget {
  /// The text content that may contain LaTeX expressions
  final String text;

  /// Text style for non-LaTeX content
  final TextStyle? style;

  /// Max lines for the text
  final int? maxLines;

  /// Text overflow behavior
  final TextOverflow overflow;

  const LaTeXText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });

  @override
  Widget build(BuildContext context) {
    // Check if text contains at least one potentially valid LaTeX expression
    // using either $...$ or $$...$$
    final hasInline =
        text.contains('\$') && text.indexOf('\$', text.indexOf('\$') + 1) != -1;

    if (!hasInline) {
      return Text(text, style: style, maxLines: maxLines, overflow: overflow);
    }

    // Parse and render mixed LaTeX and plain text
    return _LaTeXRichText(
      text: text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Internal widget that handles parsing and rendering of mixed LaTeX and plain text
class _LaTeXRichText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;

  const _LaTeXRichText({
    required this.text,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve the effective text style by merging the provided style with the default text style
    final effectiveStyle = DefaultTextStyle.of(context).style.merge(style);
    final spans = _parseLatexExpression(text, effectiveStyle);

    if (spans.isEmpty) {
      return Text(
        text,
        style: effectiveStyle,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    return RichText(
      maxLines: maxLines,
      overflow: overflow,
      text: TextSpan(children: spans, style: effectiveStyle),
    );
  }

  /// Parses text to extract LaTeX expressions and plain text
  /// Returns a list of InlineSpans that can be rendered as RichText
  /// Supports both inline math mode ($...$) and display mode math ($$...$$)
  List<InlineSpan> _parseLatexExpression(
    String input,
    TextStyle effectiveStyle,
  ) {
    final spans = <InlineSpan>[];
    int currentIndex = 0;

    while (currentIndex < input.length) {
      // Look for the next dollar sign
      final nextDollar = input.indexOf('\$', currentIndex);

      if (nextDollar == -1) {
        // No more LaTeX, add remaining text
        spans.add(
          TextSpan(text: input.substring(currentIndex), style: effectiveStyle),
        );
        break;
      }

      // Add plain text before the dollar sign
      if (nextDollar > currentIndex) {
        spans.add(
          TextSpan(
            text: input.substring(currentIndex, nextDollar),
            style: effectiveStyle,
          ),
        );
      }

      // Check if it's double dollar sign ($$)
      final isDisplayMode =
          nextDollar + 1 < input.length && input[nextDollar + 1] == '\$';
      final delimiter = isDisplayMode ? '\$\$' : '\$';
      final startPos = nextDollar + delimiter.length;

      // Look for the closing delimiter
      final endPos = input.indexOf(delimiter, startPos);

      if (endPos != -1) {
        // Extract and render math
        final mathExpression = input.substring(startPos, endPos);
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                mathExpression,
                textStyle: effectiveStyle,
                mathStyle:
                    isDisplayMode ? MathStyle.display : MathStyle.text,
                onErrorFallback: (error) {
                  return Text(
                    '$delimiter$mathExpression$delimiter',
                    style: effectiveStyle.copyWith(color: Colors.red),
                  );
                },
              ),
            ),
          ),
        );
        currentIndex = endPos + delimiter.length;
      } else {
        // No closing delimiter, treat as plain text
        spans.add(
          TextSpan(text: input.substring(nextDollar), style: effectiveStyle),
        );
        break;
      }
    }

    return spans;
  }
}
