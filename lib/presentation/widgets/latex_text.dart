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
    // Check if text contains LaTeX expressions
    if (!text.contains('\$')) {
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
    final spans = _parseLatexExpression(text);

    if (spans.isEmpty) {
      return Text(text, style: style, maxLines: maxLines, overflow: overflow);
    }

    return RichText(
      maxLines: maxLines,
      overflow: overflow,
      text: TextSpan(children: spans, style: style),
    );
  }

  /// Parses text to extract LaTeX expressions and plain text
  /// Returns a list of InlineSpans that can be rendered as RichText
  /// Supports only inline math mode: $...$
  List<InlineSpan> _parseLatexExpression(String input) {
    final spans = <InlineSpan>[];
    int currentIndex = 0;

    while (currentIndex < input.length) {
      // Look for inline math ($...$)
      final inlineStart = input.indexOf('\$', currentIndex);

      if (inlineStart != -1) {
        // Add plain text before the LaTeX
        if (inlineStart > currentIndex) {
          spans.add(
            TextSpan(
              text: input.substring(currentIndex, inlineStart),
              style: style,
            ),
          );
        }

        final inlineEnd = input.indexOf('\$', inlineStart + 1);
        if (inlineEnd != -1 && inlineEnd > inlineStart + 1) {
          // Extract and render inline math
          final mathExpression = input.substring(inlineStart + 1, inlineEnd);
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Math.tex(
                mathExpression,
                textStyle: style,
                onErrorFallback: (error) {
                  return Text(
                    '\$$mathExpression\$',
                    style: style?.copyWith(color: Colors.red),
                  );
                },
              ),
            ),
          );
          currentIndex = inlineEnd + 1;
        } else {
          // No closing $, treat as plain text
          spans.add(TextSpan(text: input.substring(inlineStart), style: style));
          break;
        }
      } else {
        // No more LaTeX expressions, add remaining text
        spans.add(TextSpan(text: input.substring(currentIndex), style: style));
        break;
      }
    }

    return spans;
  }
}
