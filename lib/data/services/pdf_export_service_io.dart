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

import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:platform_detail/platform_detail.dart';
import 'package:quizdy/data/services/pdf_export_generator.dart';
import 'package:quizdy/data/services/pdf_viewer_dialog.dart';
import 'package:quizdy/domain/models/quiz/question.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';

/// Mobile and desktop implementation of the PDF export service.
///
/// Generates the PDF and displays it in a full-screen viewer dialog.
/// The viewer includes a close button and a save action.
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
    List<Question> questions = const [],
    bool includeAnswers = false,
    String questionsPageTitle = 'Questions',
    String answersLabel = 'Answer',
  }) async {
    final pdfBytes = await StudyPdfGenerator.generate(
      documentTitle: documentTitle,
      documentSummary: documentSummary,
      chunks: chunks,
      advantagesLabel: advantagesLabel,
      limitationsLabel: limitationsLabel,
      tableOfContentsLabel: tableOfContentsLabel,
      latexImages: latexImages,
      questions: questions,
      includeAnswers: includeAnswers,
      questionsPageTitle: questionsPageTitle,
      answersLabel: answersLabel,
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
            if (result != null && PlatformDetail.isDesktop) {
              await File(result).writeAsBytes(pdfBytes);
            }
            return result != null;
          },
        ),
      ),
    );
  }
}
