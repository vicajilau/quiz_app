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

import 'package:file_picker/file_picker.dart';
import 'package:platform_detail/platform_detail.dart';
import 'package:quizdy/data/services/pdf_export_generator.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';

/// Mobile and desktop implementation of the PDF export service.
///
/// On mobile platforms, [FilePicker.platform.saveFile] with [bytes] handles
/// saving automatically. On desktop platforms, the bytes are written manually
/// after the user selects a save path.
class StudyPdfExportService {
  /// Generates a PDF from the provided study data and opens a save dialog.
  ///
  /// Returns `true` if the user completed the save, `false` if cancelled or
  /// an error occurred.
  Future<bool> exportStudy({
    required String documentTitle,
    String? documentSummary,
    required List<StudyChunk> chunks,
    required String dialogTitle,
    required String fileName,
    String advantagesLabel = 'Advantages',
    String limitationsLabel = 'Limitations',
  }) async {
    final pdfBytes = await StudyPdfGenerator.generate(
      documentTitle: documentTitle,
      documentSummary: documentSummary,
      chunks: chunks,
      advantagesLabel: advantagesLabel,
      limitationsLabel: limitationsLabel,
    );

    final result = await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      bytes: pdfBytes,
    );

    if (result != null && PlatformDetail.isDesktop) {
      await File(result).writeAsBytes(pdfBytes);
    }

    return result != null;
  }
}
