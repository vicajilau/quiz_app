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

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:quizdy/data/services/pdf_export_generator.dart';
import 'package:quizdy/data/services/pdf_viewer_dialog.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';

/// Web implementation of the PDF export service.
///
/// Generates the PDF and displays it in a full-screen viewer dialog.
/// The viewer includes a close button and a download action.
class StudyPdfExportService {
  /// Generates a PDF from the provided study data and opens a viewer dialog.
  ///
  /// Returns `true` after the viewer is shown, `false` if context is no longer
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

    if (!context.mounted) return false;

    return await showDialog<bool?>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: PdfViewerDialog(
          pdfBytes: pdfBytes,
          title: documentTitle,
          onSave: () async {
            final result = await FilePicker.saveFile(
              fileName: '$documentTitle.pdf',
              bytes: pdfBytes,
            );
            return result != null;
          },
        ),
      ),
    );
  }
}
