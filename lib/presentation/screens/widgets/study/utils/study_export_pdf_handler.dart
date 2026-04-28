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
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/data/services/pdf_export_service_io.dart'
    if (dart.library.js_interop) 'package:quizdy/data/services/pdf_export_service.dart';
import 'package:quizdy/domain/models/quiz/question.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_component.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_bloc.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_state.dart';
import 'package:quizdy/presentation/screens/dialogs/export_pdf_options_dialog.dart';
import 'package:quizdy/presentation/utils/latex_image_renderer.dart';

/// Exports a PDF, optionally showing a dialog to configure question/answer pages.
///
/// Behaviour:
/// - No questions → skips the dialog and exports the study content directly.
/// - Has questions but no study chunks → shows the dialog and exports only the
///   selected question/answer pages (no study content).
/// - Has both → shows the dialog and exports study content plus the selected
///   question/answer pages.
///
/// [questions] are the quiz questions available for inclusion in the PDF.
/// [documentTitle], [documentSummary] and [studyChunks] can be supplied
/// directly (e.g. from the quiz-loaded screen where no [StudyExecutionBloc]
/// is present). When omitted they are read from [StudyExecutionBloc].
Future<void> handleExportPdf({
  required BuildContext context,
  List<Question> questions = const [],
  String? documentTitle,
  String? documentSummary,
  List<StudyChunk>? studyChunks,
}) async {
  final localizations = AppLocalizations.of(context)!;

  final StudyExecutionState? studyState = studyChunks == null
      ? context.read<StudyExecutionBloc>().state
      : null;

  final String title = documentTitle ?? studyState?.documentTitle ?? '';
  final String? summary = documentSummary ?? studyState?.documentSummary;
  final List<StudyChunk> chunks = studyChunks ?? studyState?.chunks ?? const [];

  final hasStudy = chunks.isNotEmpty;
  final hasQuestions = questions.isNotEmpty;

  PdfExportOptions options;

  if (!hasQuestions) {
    // No questions: export study directly without showing the dialog.
    options = const PdfExportOptions(
      includeStudy: true,
      includeQuestions: false,
      includeAnswers: false,
    );
  } else {
    // Has questions: let the user choose what to include.
    final result = await showDialog<PdfExportOptions>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          ExportPdfOptionsDialog(hasStudy: hasStudy, hasQuestions: true),
    );
    if (result == null || !context.mounted) return;
    options = result;
  }

  final exportQuestions = options.includeQuestions
      ? questions
      : const <Question>[];
  final exportChunks = (hasStudy && options.includeStudy)
      ? chunks
      : const <StudyChunk>[];

  try {
    final equations = _collectEquations(chunks, exportQuestions);

    final latexImages = await LaTeXImageRenderer.renderEquations(
      context,
      equations,
    );

    if (!context.mounted) return;

    final success = await ServiceLocator.getIt<StudyPdfExportService>()
        .exportStudy(
          context: context,
          documentTitle: title,
          documentSummary: summary,
          chunks: exportChunks,
          advantagesLabel: localizations.studyComponentAdvantages,
          limitationsLabel: localizations.studyComponentLimitations,
          tableOfContentsLabel: localizations.studyPdfTableOfContents,
          latexImages: latexImages,
          questions: exportQuestions,
          includeAnswers: options.includeAnswers,
          questionsPageTitle: localizations.exportPdfQuestionsPageTitle,
          answersLabel: localizations.exportPdfAnswersLabel,
        );

    if (success == true && context.mounted) {
      context.presentSnackBar(localizations.exportPdfSuccess);
    }
  } catch (_) {
    if (context.mounted) {
      context.presentSnackBar(localizations.exportPdfError);
    }
  }
}

List<String> _collectEquations(
  List<StudyChunk> chunks,
  List<Question> questions,
) {
  final seen = <String>{};

  void addEquation(String eq) {
    if (eq.isNotEmpty) seen.add(eq);
  }

  // Equations from study chunk formula components.
  for (final chunk in chunks) {
    for (final page in chunk.pages) {
      for (final component in page.uiElements) {
        if (component.componentType == StudyComponentType.formula) {
          addEquation(component.props['equation']?.toString() ?? '');
        }
      }
    }
  }

  // Inline equations embedded in question texts, options and explanations.
  for (final q in questions) {
    for (final eq in _extractInlineEquations(q.text)) {
      addEquation(eq);
    }
    for (final option in q.options) {
      for (final eq in _extractInlineEquations(option)) {
        addEquation(eq);
      }
    }
    for (final eq in _extractInlineEquations(q.explanation)) {
      addEquation(eq);
    }
  }

  return seen.toList();
}

/// Extracts raw equation strings (without delimiters) from a text that may
/// contain inline or display LaTeX math.
List<String> _extractInlineEquations(String text) {
  final equations = <String>[];
  final patterns = [
    RegExp(r'\$\$(.+?)\$\$', dotAll: true),
    RegExp(r'(?<!\$)\$(?!\$)(.+?)(?<!\$)\$(?!\$)', dotAll: true),
    RegExp(r'\\\[(.+?)\\\]', dotAll: true),
    RegExp(r'\\\((.+?)\\\)', dotAll: true),
  ];
  for (final pattern in patterns) {
    for (final match in pattern.allMatches(text)) {
      final eq = match.group(1)?.trim() ?? '';
      if (eq.isNotEmpty) equations.add(eq);
    }
  }
  return equations;
}
