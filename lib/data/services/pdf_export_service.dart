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

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:quizdy/data/services/pdf_export_generator.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:web/web.dart' as web;

/// Web implementation of the PDF export service.
///
/// Generates the PDF and opens it in a new browser tab using a Blob URL,
/// where the browser's built-in PDF viewer displays it automatically.
class StudyPdfExportService {
  /// Generates a PDF from the provided study data and opens it in the browser.
  ///
  /// Returns `true` after opening the new tab, `false` if context is no longer
  /// mounted or an error occurred.
  Future<bool?> exportStudy({
    required BuildContext context,
    required String documentTitle,
    String? documentSummary,
    required List<StudyChunk> chunks,
    String advantagesLabel = 'Advantages',
    String limitationsLabel = 'Limitations',
    String tableOfContentsLabel = 'Table of Contents',
    Map<String, Uint8List> latexImages = const {},
  }) async {
    final pdfBytes = await StudyPdfGenerator.generate(
      documentTitle: documentTitle,
      documentSummary: documentSummary,
      chunks: chunks,
      advantagesLabel: advantagesLabel,
      limitationsLabel: limitationsLabel,
      tableOfContentsLabel: tableOfContentsLabel,
      latexImages: latexImages,
    );

    final blob = web.Blob(
      [pdfBytes.toJS].toJS,
      web.BlobPropertyBag(type: 'application/pdf'),
    );
    final url = web.URL.createObjectURL(blob);
    web.window.open(url, '_blank');
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => web.URL.revokeObjectURL(url),
    );

    return true;
  }
}
