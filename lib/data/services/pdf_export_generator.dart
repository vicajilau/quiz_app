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

import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/domain/models/quiz/study_component.dart';

/// Bundles localizable labels needed during PDF generation.
class _PdfLabels {
  final String advantages;
  final String limitations;

  const _PdfLabels({required this.advantages, required this.limitations});
}

/// Generates a PDF document from study data.
///
/// This class is platform-independent and contains only the PDF generation
/// logic using the `pdf` package. Saving the result to disk is handled by
/// the platform-specific [StudyPdfExportService].
class StudyPdfGenerator {
  StudyPdfGenerator._();

  /// Generates a PDF document from the provided study data and returns the
  /// bytes of the resulting file.
  ///
  /// [advantagesLabel] and [limitationsLabel] are the localized column headers
  /// used in pros/cons components. They default to English if omitted.
  static Future<Uint8List> generate({
    required String documentTitle,
    String? documentSummary,
    required List<StudyChunk> chunks,
    String advantagesLabel = 'Advantages',
    String limitationsLabel = 'Limitations',
  }) async {
    final labels = _PdfLabels(
      advantages: advantagesLabel,
      limitations: limitationsLabel,
    );

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 40),
        build: (pw.Context context) => [
          ..._buildCoverSection(documentTitle, documentSummary),
          ..._buildChunks(chunks, labels),
        ],
      ),
    );

    return pdf.save();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static List<pw.Widget> _buildCoverSection(String title, String? summary) {
    return [
      pw.Text(
        title,
        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
      ),
      if (summary != null && summary.isNotEmpty) ...[
        pw.SizedBox(height: 8),
        pw.Text(
          _strip(summary),
          style: pw.TextStyle(
            fontSize: 12,
            fontStyle: pw.FontStyle.italic,
            color: PdfColors.grey700,
          ),
        ),
      ],
      pw.SizedBox(height: 6),
      pw.Divider(thickness: 2, color: PdfColors.grey600),
      pw.SizedBox(height: 20),
    ];
  }

  static List<pw.Widget> _buildChunks(
    List<StudyChunk> chunks,
    _PdfLabels labels,
  ) {
    final readyChunks = chunks
        .where(
          (c) =>
              c.status == StudyChunkState.completed ||
              c.status == StudyChunkState.downloaded,
        )
        .toList();

    final widgets = <pw.Widget>[];
    for (int i = 0; i < readyChunks.length; i++) {
      widgets.addAll(_buildChunk(readyChunks[i], i, labels));
    }
    return widgets;
  }

  static List<pw.Widget> _buildChunk(
    StudyChunk chunk,
    int index,
    _PdfLabels labels,
  ) {
    final widgets = <pw.Widget>[];

    widgets.add(
      pw.Text(
        '${index + 1}. ${chunk.title}',
        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
      ),
    );

    if (chunk.aiSummary != null && chunk.aiSummary!.isNotEmpty) {
      widgets.add(pw.SizedBox(height: 4));
      widgets.add(
        pw.Text(
          _strip(chunk.aiSummary!),
          style: pw.TextStyle(
            fontSize: 11,
            fontStyle: pw.FontStyle.italic,
            color: PdfColors.grey700,
          ),
        ),
      );
    }

    widgets.add(pw.SizedBox(height: 8));
    widgets.add(pw.Divider(color: PdfColors.grey400));
    widgets.add(pw.SizedBox(height: 8));

    for (final page in chunk.pages) {
      for (final component in page.uiElements) {
        widgets.addAll(_buildComponent(component, labels));
      }
    }

    widgets.add(pw.SizedBox(height: 16));

    return widgets;
  }

  static List<pw.Widget> _buildComponent(
    StudyComponent component,
    _PdfLabels labels,
  ) {
    switch (component.componentType) {
      case StudyComponentType.sectionTitle:
        return _buildSectionTitle(component);
      case StudyComponentType.paragraph:
        return _buildParagraph(component);
      case StudyComponentType.keyDefinition:
        return _buildKeyDefinition(component);
      case StudyComponentType.numberedList:
        return _buildNumberedList(component);
      case StudyComponentType.comparisonTable:
        return _buildComparisonTable(component);
      case StudyComponentType.quote:
        return _buildQuote(component);
      case StudyComponentType.warning:
        return _buildWarning(component);
      case StudyComponentType.formula:
        return _buildFormula(component);
      case StudyComponentType.timeline:
        return _buildTimeline(component);
      case StudyComponentType.prosCons:
        return _buildProsCons(component, labels);
      case StudyComponentType.keyConcepts:
        return _buildKeyConcepts(component);
      case StudyComponentType.reminder:
        return _buildReminder(component);
      case StudyComponentType.iconCards:
        return _buildIconCards(component);
    }
  }

  // ---
  // Component renderers
  // ---

  static List<pw.Widget> _buildSectionTitle(StudyComponent c) {
    final title = c.props['title']?.toString() ?? '';
    final subtitle = c.props['subtitle']?.toString();
    return [
      pw.SizedBox(height: 6),
      pw.Text(
        _strip(title),
        style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
      ),
      if (subtitle != null && subtitle.isNotEmpty)
        pw.Text(
          _strip(subtitle),
          style: pw.TextStyle(
            fontSize: 12,
            fontStyle: pw.FontStyle.italic,
            color: PdfColors.grey700,
          ),
        ),
      pw.Divider(color: PdfColors.grey400),
      pw.SizedBox(height: 4),
    ];
  }

  static List<pw.Widget> _buildParagraph(StudyComponent c) {
    final title = c.props['title']?.toString();
    final body = c.props['body']?.toString() ?? '';
    return [
      if (title != null && title.isNotEmpty)
        pw.Text(
          _strip(title),
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
      if (body.isNotEmpty)
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4, bottom: 10),
          child: pw.Text(_strip(body), style: const pw.TextStyle(fontSize: 11)),
        ),
    ];
  }

  static List<pw.Widget> _buildKeyDefinition(StudyComponent c) {
    final term = c.props['term']?.toString() ?? '';
    final body = c.props['body']?.toString() ?? '';
    return [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '${_strip(term)}: ',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.Expanded(
            child: pw.Text(
              _strip(body),
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 6),
    ];
  }

  static List<pw.Widget> _buildNumberedList(StudyComponent c) {
    final title = c.props['title']?.toString();
    final rawItems = c.props['items'] as List<dynamic>? ?? [];
    final items = rawItems.map((e) => _strip(e.toString())).toList();
    return [
      if (title != null && title.isNotEmpty)
        pw.Text(
          _strip(title),
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
      pw.SizedBox(height: 4),
      ...List.generate(items.length, (i) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 16, bottom: 4),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${i + 1}. ',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  items[i],
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        );
      }),
      pw.SizedBox(height: 6),
    ];
  }

  static List<pw.Widget> _buildComparisonTable(StudyComponent c) {
    final title = c.props['title']?.toString();
    final rawColumns = (c.props['columns'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    final rawRows = c.props['rows'] as List<dynamic>? ?? [];

    final rows = rawRows.map((row) {
      if (row is Map<String, dynamic>) {
        final label = row['label']?.toString() ?? '';
        final values = (row['values'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();
        return {'label': label, 'values': values};
      }
      return {'label': '', 'values': <String>[]};
    }).toList();

    if (rawColumns.isEmpty && rows.isEmpty) return [];

    // Build header row + data rows
    final headerCells = rawColumns.map((col) {
      return pw.Container(
        color: PdfColors.grey300,
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(
          _strip(col),
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      );
    }).toList();

    final tableRows = <pw.TableRow>[];

    if (headerCells.isNotEmpty) {
      tableRows.add(pw.TableRow(children: headerCells));
    }

    for (final row in rows) {
      final label = row['label'] as String? ?? '';
      final values = row['values'] as List<String>? ?? [];
      final cells = <pw.Widget>[];
      if (label.isNotEmpty || rawColumns.length > values.length) {
        cells.add(
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(
              _strip(label),
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
        );
      }
      for (final v in values) {
        cells.add(
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(_strip(v), style: const pw.TextStyle(fontSize: 10)),
          ),
        );
      }
      if (cells.isNotEmpty) {
        tableRows.add(pw.TableRow(children: cells));
      }
    }

    return [
      if (title != null && title.isNotEmpty)
        pw.Text(
          _strip(title),
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
      pw.SizedBox(height: 4),
      if (tableRows.isNotEmpty)
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          children: tableRows,
        ),
      pw.SizedBox(height: 10),
    ];
  }

  static List<pw.Widget> _buildQuote(StudyComponent c) {
    final body = c.props['body']?.toString() ?? '';
    final author = c.props['author']?.toString();
    return [
      pw.Container(
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            left: pw.BorderSide(color: PdfColors.grey500, width: 3),
          ),
        ),
        padding: const pw.EdgeInsets.only(left: 12, top: 4, bottom: 4),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              '"${_strip(body)}"',
              style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic),
            ),
            if (author != null && author.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                '- ${_strip(author)}',
                textAlign: pw.TextAlign.right,
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ],
        ),
      ),
      pw.SizedBox(height: 10),
    ];
  }

  static List<pw.Widget> _buildWarning(StudyComponent c) {
    final body = c.props['body']?.toString() ?? '';
    return [
      pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColors.orange50,
          border: pw.Border.all(color: PdfColors.orange, width: 0.5),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        padding: const pw.EdgeInsets.all(10),
        child: pw.Text(
          _strip(body),
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.orange900),
        ),
      ),
      pw.SizedBox(height: 10),
    ];
  }

  static List<pw.Widget> _buildFormula(StudyComponent c) {
    final title = c.props['title']?.toString();
    final equation = c.props['equation']?.toString() ?? '';
    final equationLabel = c.props['equation_label']?.toString();
    final body = c.props['body']?.toString();
    return [
      if (title != null && title.isNotEmpty)
        pw.Text(
          _strip(title),
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
      pw.SizedBox(height: 4),
      if (equation.isNotEmpty)
        pw.Container(
          color: PdfColors.grey100,
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(
            equation,
            style: pw.TextStyle(fontSize: 13, font: pw.Font.courier()),
          ),
        ),
      if (equationLabel != null && equationLabel.isNotEmpty)
        pw.Text(
          _strip(equationLabel),
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
      if (body != null && body.isNotEmpty)
        pw.Text(_strip(body), style: const pw.TextStyle(fontSize: 11)),
      pw.SizedBox(height: 10),
    ];
  }

  static List<pw.Widget> _buildTimeline(StudyComponent c) {
    final title = c.props['title']?.toString();
    final rawItems = c.props['items'] as List<dynamic>? ?? [];
    final items = rawItems.map((item) {
      if (item is Map<String, dynamic>) {
        return {
          'date': item['date']?.toString() ?? '',
          'title': item['title']?.toString() ?? '',
          'description': item['description']?.toString() ?? '',
        };
      }
      return {'date': '', 'title': item.toString(), 'description': ''};
    }).toList();

    return [
      if (title != null && title.isNotEmpty)
        pw.Text(
          _strip(title),
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
      pw.SizedBox(height: 4),
      ...items.map((item) {
        final date = item['date'] ?? '';
        final itemTitle = item['title'] ?? '';
        final description = item['description'] ?? '';
        return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 16, bottom: 8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  if (date.isNotEmpty) ...[
                    pw.Text(
                      '[$date] ',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                  pw.Expanded(
                    child: pw.Text(
                      _strip(itemTitle),
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (description.isNotEmpty)
                pw.Text(
                  _strip(description),
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
            ],
          ),
        );
      }),
      pw.SizedBox(height: 6),
    ];
  }

  static List<pw.Widget> _buildProsCons(StudyComponent c, _PdfLabels labels) {
    final items = c.props['items'] as Map<String, dynamic>?;
    final pros = (items?['pros'] as List<dynamic>? ?? [])
        .map((e) => _strip(e.toString()))
        .toList();
    final cons = (items?['cons'] as List<dynamic>? ?? [])
        .map((e) => _strip(e.toString()))
        .toList();

    pw.Widget buildColumn(String header, List<String> list, PdfColor color) {
      return pw.Expanded(
        child: pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: color, width: 0.5),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          padding: const pw.EdgeInsets.all(8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                header,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: color,
                ),
              ),
              pw.SizedBox(height: 6),
              ...list.map(
                (item) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '- ',
                        style: pw.TextStyle(fontSize: 11, color: color),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          item,
                          style:  pw.TextStyle(fontSize: 11, color: color),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          buildColumn(labels.advantages, pros, PdfColors.green700),
          pw.SizedBox(width: 10),
          buildColumn(labels.limitations, cons, PdfColors.red700),
        ],
      ),
      pw.SizedBox(height: 10),
    ];
  }

  static List<pw.Widget> _buildKeyConcepts(StudyComponent c) {
    final title = c.props['title']?.toString();
    final rawItems = c.props['items'] as List<dynamic>? ?? [];
    final items = rawItems.map((e) => _strip(e.toString())).toList();
    return [
      if (title != null && title.isNotEmpty)
        pw.Text(
          _strip(title),
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
      pw.SizedBox(height: 4),
      pw.Wrap(
        spacing: 6,
        runSpacing: 6,
        children: items
            .map(
              (concept) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue400, width: 0.5),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(12),
                  ),
                ),
                child: pw.Text(
                  concept,
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.blue800,
                  ),
                ),
              ),
            )
            .toList(),
      ),
      pw.SizedBox(height: 10),
    ];
  }

  static List<pw.Widget> _buildReminder(StudyComponent c) {
    final body = c.props['body']?.toString() ?? '';
    return [
      pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColors.blue50,
          border: pw.Border.all(color: PdfColors.blue300, width: 0.5),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        padding: const pw.EdgeInsets.all(10),
        child: pw.Text(
          _strip(body),
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.blue900),
        ),
      ),
      pw.SizedBox(height: 10),
    ];
  }

  static List<pw.Widget> _buildIconCards(StudyComponent c) {
    final title = c.props['title']?.toString();
    final rawItems = c.props['items'] as List<dynamic>? ?? [];
    final items = rawItems.map((item) {
      if (item is Map<String, dynamic>) {
        return {
          'title': item['title']?.toString() ?? '',
          'description': item['description']?.toString() ?? '',
        };
      }
      return {'title': item.toString(), 'description': ''};
    }).toList();

    return [
      if (title != null && title.isNotEmpty)
        pw.Text(
          _strip(title),
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
      pw.SizedBox(height: 4),
      ...items.map((item) {
        final cardTitle = item['title'] ?? '';
        final description = item['description'] ?? '';
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            padding: const pw.EdgeInsets.all(8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (cardTitle.isNotEmpty)
                  pw.Text(
                    _strip(cardTitle),
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                if (description.isNotEmpty)
                  pw.Text(
                    _strip(description),
                    style: const pw.TextStyle(fontSize: 10),
                  ),
              ],
            ),
          ),
        );
      }),
      pw.SizedBox(height: 6),
    ];
  }

  // ---------------------------------------------------------------------------
  // Markdown stripper
  // ---------------------------------------------------------------------------

  /// Strips Markdown and LaTeX delimiters from [text] so it renders cleanly
  /// in PDF. LaTeX content is preserved as plain text (e.g. `$x^2$` → `x^2`).
  static String _strip(String text) {
    return text
        // LaTeX: display mode $$...$$ must come before inline $...$
        .replaceAllMapped(
          RegExp(r'\$\$(.+?)\$\$', dotAll: true),
          (m) => m.group(1)!,
        )
        // LaTeX: inline $...$
        .replaceAllMapped(
          RegExp(r'\$(.+?)\$', dotAll: true),
          (m) => m.group(1)!,
        )
        // LaTeX: \(...\) inline
        .replaceAllMapped(
          RegExp(r'\\\((.+?)\\\)', dotAll: true),
          (m) => m.group(1)!,
        )
        // LaTeX: \[...\] display
        .replaceAllMapped(
          RegExp(r'\\\[(.+?)\\\]', dotAll: true),
          (m) => m.group(1)!,
        )
        // Markdown: **bold** and __bold__
        .replaceAllMapped(
          RegExp(r'\*\*(.+?)\*\*', dotAll: true),
          (m) => m.group(1)!,
        )
        .replaceAllMapped(
          RegExp(r'__(.+?)__', dotAll: true),
          (m) => m.group(1)!,
        )
        // Markdown: *italic* and _italic_
        .replaceAllMapped(
          RegExp(r'\*(.+?)\*', dotAll: true),
          (m) => m.group(1)!,
        )
        .replaceAllMapped(RegExp(r'_(.+?)_', dotAll: true), (m) => m.group(1)!)
        // Markdown: `code`
        .replaceAllMapped(RegExp(r'`(.+?)`', dotAll: true), (m) => m.group(1)!)
        // Markdown: [text](url)
        .replaceAllMapped(RegExp(r'\[(.+?)\]\(.+?\)'), (m) => m.group(1)!)
        // Markdown: # headings
        .replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '')
        .trim();
  }
}
