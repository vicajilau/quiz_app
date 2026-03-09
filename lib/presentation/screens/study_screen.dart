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
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime/mime.dart';
import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/core/extensions/string_extension.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/data/services/ai/ai_jit_processing_service.dart';
import 'package:quizdy/domain/models/ai/ai_difficulty_level.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/use_cases/check_file_changes_use_case.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_bloc.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_event.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_bloc.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_event.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_state.dart';
import 'package:quizdy/presentation/screens/dialogs/ai_generate_study_dialog.dart';
import 'package:quizdy/presentation/screens/dialogs/exit_confirmation_dialog.dart';
import 'package:quizdy/domain/models/ai/ai_study_generation_config.dart';
import 'package:quizdy/presentation/screens/widgets/request_file_name_dialog.dart';
import 'package:quizdy/presentation/screens/widgets/study/add_edit_chunk_dialog.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_app_bar.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_bottom_navigation.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_body.dart';
import 'package:quizdy/presentation/screens/widgets/study/utils/study_quiz_file_helper.dart';

class StudyScreen extends StatelessWidget {
  final List<StudyChunk> initialChunks;
  final AiFileAttachment? fileAttachment;
  final String documentTitle;
  final String? documentSummary;
  final QuizFile? quizFile;
  final bool isAutoDifficulty;
  final AiDifficultyLevel? difficultyLevel;
  final AiGenerationMode? generationMode;
  final String? originalText;
  final String? language;

  const StudyScreen({
    super.key,
    required this.initialChunks,
    this.fileAttachment,
    required this.documentTitle,
    this.documentSummary,
    this.quizFile,
    this.isAutoDifficulty = true,
    this.difficultyLevel,
    this.generationMode,
    this.originalText,
    this.language,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => StudyExecutionBloc(
        jitProcessingService: ServiceLocator.getIt<AiJitProcessingService>(),
        localizations: localizations,
        initialChunks: initialChunks,
        fileAttachment: fileAttachment ?? quizFile?.fileAttachment,
        fileUri: quizFile?.fileUri,
        fileExpirationTime: quizFile?.fileExpirationTime,
        documentTitle: documentTitle,
        documentSummary: documentSummary ?? quizFile?.metadata.description,
        isAutoDifficulty: quizFile?.study?.isAutoDifficulty ?? isAutoDifficulty,
        difficultyLevel: difficultyLevel ?? quizFile?.study?.difficultyLevel,
        originalText: originalText ?? quizFile?.study?.originalText,
        language: language ?? quizFile?.study?.language,
        generationMode: generationMode ?? quizFile?.study?.generationMode,
        onProgressChanged:
            (progress, processedChunks, chunks, fileUri, expirationTime) {
              context.read<FileBloc>().add(
                StudyProgressUpdated(
                  progress: progress,
                  processedChunks: processedChunks,
                  chunks: chunks,
                  fileUri: fileUri,
                  fileExpirationTime: expirationTime,
                ),
              );
            },
      ),
      child: StudyScreenView(
        quizFile: quizFile,
        generationMode: generationMode,
        originalText: originalText,
      ),
    );
  }
}

class StudyScreenView extends StatefulWidget {
  const StudyScreenView({
    super.key,
    required this.quizFile,
    this.generationMode,
    this.originalText,
  });

  final QuizFile? quizFile;
  final AiGenerationMode? generationMode;
  final String? originalText;

  @override
  State<StudyScreenView> createState() => _StudyScreenViewState();
}

class _StudyScreenViewState extends State<StudyScreenView> {
  Future<bool> _confirmExit() async {
    final studyState = context.read<StudyExecutionBloc>().state;
    final fileToSave = _getCurrentQuizFile(studyState);
    final checkChanges = ServiceLocator.getIt<CheckFileChangesUseCase>();
    if (checkChanges.execute(fileToSave)) {
      return await showDialog<bool>(
            context: context,
            builder: (context) => const ExitConfirmationDialog(),
          ) ??
          false;
    }
    return true;
  }

  QuizFile _getCurrentQuizFile(StudyExecutionState studyState) {
    final fileState = context.read<FileBloc>().state;
    return StudyQuizFileHelper.getCurrentQuizFile(
      studyState: studyState,
      fileState: fileState,
      initialQuizFile: widget.quizFile,
      generationMode: widget.generationMode,
      originalText: widget.originalText,
    );
  }

  Future<void> _handleSave() async {
    final localizations = AppLocalizations.of(context)!;
    final studyState = context.read<StudyExecutionBloc>().state;
    final fileToSave = _getCurrentQuizFile(studyState);

    if (!mounted) return;

    // Get existing filename from path, or generate one from title
    var fileName = fileToSave.filePath?.split('/').last;

    if (fileName == null || fileName.isEmpty) {
      final sanitizedTitle = fileToSave.metadata.title.sanitizeFilename;
      fileName = sanitizedTitle.isNotEmpty
          ? '$sanitizedTitle.quiz'
          : 'quiz.quiz';
    }

    // On Web, if existing filename is invalid, ask for name
    if (kIsWeb &&
        (fileName.isEmpty || !fileName.toLowerCase().endsWith('.quiz'))) {
      if (!mounted) return;
      final result = await showDialog<String>(
        context: context,
        builder: (context) => const RequestFileNameDialog(format: '.quiz'),
      );

      if (result != null && result.isNotEmpty) {
        fileName = result;
      } else {
        return;
      }
    }

    if (mounted) {
      context.read<FileBloc>().add(
        QuizFileSaveRequested(fileToSave, localizations.saveButton, fileName),
      );
    }
  }

  Future<void> _handleFileReattachment(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.reattachFileDialogTitle),
        content: Text(localizations.reattachFileDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(localizations.studyScreenOmit),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(localizations.aiAttachFile),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      if (context.mounted) {
        context.read<StudyExecutionBloc>().add(
          const FileReattachmentCancelled(),
        );
      }
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );

    if (result == null ||
        result.files.isEmpty ||
        result.files.first.bytes == null) {
      return;
    }

    if (!context.mounted) return;

    final pickedFile = result.files.first;
    final file = AiFileAttachment(
      bytes: pickedFile.bytes!,
      mimeType:
          lookupMimeType(pickedFile.name, headerBytes: pickedFile.bytes) ??
          'application/octet-stream',
      name: pickedFile.name,
    );

    // Check hash if we have the original hash stored
    final expectedHash = widget.quizFile?.fileContentHash;
    if (expectedHash != null && file.contentHash != expectedHash) {
      if (!context.mounted) return;
      context.presentSnackBar(localizations.fileHashMismatchError);
      return;
    }

    if (!context.mounted) return;
    context.read<StudyExecutionBloc>().add(FileReattached(file));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _confirmExit,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.zinc900 : AppTheme.zinc50,
        extendBodyBehindAppBar: true,
        extendBody: true,
        bottomNavigationBar: StudyBottomNavigation(
          quizFile: widget.quizFile,
          generationMode: widget.generationMode,
          originalText: widget.originalText,
          onSave: _handleSave,
          onImport: () => _handleFileReattachment(context),
          onAddChunk: () async {
            final localizations = AppLocalizations.of(context)!;
            final result = await showDialog<Map<String, String>>(
              context: context,
              builder: (context) =>
                  AddEditChunkDialog(localizations: localizations),
            );

            if (result != null && context.mounted) {
              context.read<StudyExecutionBloc>().add(
                AddStudyChunkRequested(
                  title: result['title'] ?? '',
                  content: result['text'] ?? '',
                ),
              );
            }
          },
          onGenerateAI: () async {
            final config = await showDialog<AiStudyGenerationConfig>(
              context: context,
              barrierDismissible: false,
              builder: (context) => const AiGenerateStudyDialog(),
            );

            if (config != null && context.mounted) {
              final studyState = context.read<StudyExecutionBloc>().state;
              final quizFile = _getCurrentQuizFile(studyState);
              context.read<StudyExecutionBloc>().add(
                GenerateAiStudyChunksRequested(
                  config: config,
                  quizContext: quizFile.toAIPromptContext(),
                ),
              );
            }
          },
        ),
        appBar: StudyAppBar(onConfirmExit: _confirmExit),
        body: StudyBody(
          onHandleFileReattachment: _handleFileReattachment,
          onSave: _handleSave,
        ),
      ),
    );
  }
}
