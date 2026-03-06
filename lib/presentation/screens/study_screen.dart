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
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:quizdy/domain/use_cases/check_file_changes_use_case.dart';
import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/core/extensions/string_extensions.dart';
import 'package:quizdy/core/theme/extensions/file_loaded_theme.dart';
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';
import 'package:quizdy/presentation/screens/dialogs/settings_dialog.dart';
import 'package:quizdy/presentation/screens/dialogs/exit_confirmation_dialog.dart';
import 'package:quizdy/presentation/screens/widgets/study/add_edit_chunk_dialog.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/data/services/ai/ai_jit_processing_service.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/domain/models/quiz/quiz_metadata.dart';
import 'package:quizdy/domain/models/quiz/study.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/domain/models/quiz/study_content.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/domain/models/ai/ai_difficulty_level.dart';
import 'package:quizdy/core/constants/quiz_metadata.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_bloc.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_event.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_state.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_bloc.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_event.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_state.dart';
import 'package:quizdy/presentation/screens/widgets/request_file_name_dialog.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_index_view.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_sections_sidebar.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_index_footer_widget.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_execution_bottom_bar.dart';
import 'package:quizdy/routes/app_router.dart';

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
        documentTitle: documentTitle,
        documentSummary: documentSummary ?? quizFile?.metadata.description,
        isAutoDifficulty: quizFile?.study?.isAutoDifficulty ?? isAutoDifficulty,
        difficultyLevel: difficultyLevel ?? quizFile?.study?.difficultyLevel,
        originalText: originalText ?? quizFile?.study?.originalText,
        language: language ?? quizFile?.study?.language,
        generationMode: generationMode ?? quizFile?.study?.generationMode,
        onProgressChanged: (progress, processedChunks, chunks, fileUri) {
          context.read<FileBloc>().add(
            StudyProgressUpdated(
              progress: progress,
              processedChunks: processedChunks,
              chunks: chunks,
              fileUri: fileUri,
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

    QuizFile updatedQuizFile(QuizFile qf) {
      final processedChunks = studyState.chunks
          .where((c) => c.status != StudyChunkState.created)
          .length;
      final studyContent = StudyContent(
        progressPercentage: studyState.progressPercentage,
        totalChunks: studyState.chunks.length,
        processedChunks: processedChunks,
        cache: studyState.chunks,
      );

      return qf.copyWith(
        fileUri: studyState.fileUri,
        fileContentHash:
            qf.fileContentHash ?? studyState.fileAttachment?.contentHash,
        study:
            qf.study?.copyWith(content: studyContent) ??
            Study(
              content: studyContent,
              generationMode: widget.generationMode,
              originalText: widget.originalText,
            ),
      );
    }

    if (fileState is FileLoaded) {
      return updatedQuizFile(fileState.quizFile);
    } else if (fileState is FileSaved) {
      return updatedQuizFile(fileState.quizFile);
    } else {
      return QuizFile(
        metadata: QuizMetadata(
          title: studyState.documentTitle,
          description: studyState.documentSummary ?? '',
          version: QuizMetadataConstants.version,
          author: '',
        ),
        questions: const [],
        study: Study(
          content: StudyContent(
            progressPercentage: studyState.progressPercentage,
            totalChunks: studyState.chunks.length,
            processedChunks: studyState.chunks
                .where((c) => c.status != StudyChunkState.created)
                .length,
            cache: studyState.chunks,
          ),
          generationMode: widget.generationMode,
          originalText: widget.originalText,
        ),
        fileContentHash: studyState.fileAttachment?.contentHash,
        fileUri: studyState.fileUri,
      );
    }
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
        context.read<StudyExecutionBloc>().add(FileReattachmentCancelled());
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
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _confirmExit();
        return shouldExit;
      },
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.zinc900 : AppTheme.zinc50,
        bottomNavigationBar:
            BlocBuilder<StudyExecutionBloc, StudyExecutionState>(
              builder: (context, state) {
                if (state.chunks.isEmpty) return const SizedBox.shrink();

                final currentQuizFile = _getCurrentQuizFile(state);
                final hasChanges =
                    ServiceLocator.getIt<CheckFileChangesUseCase>().execute(
                      currentQuizFile,
                    );

                if (state.isIndexMode) {
                  return StudyIndexFooterWidget(
                    localizations: localizations,
                    hasChunks: state.chunks.isNotEmpty,
                    onStartQuiz: () {
                      context.go(AppRoutes.fileLoadedScreen);
                    },
                    onAddChunk: () async {
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
                    onGenerateAI: null, // TODO: Implement generate AI
                    onImport: null, // TODO: Implement import questions
                    onSave: _handleSave,
                    showSaveButton: hasChanges,
                  );
                }

                return StudyExecutionBottomBar(
                  currentIndex: state.currentChunkIndex,
                  totalCount: state.chunks.length,
                  progressPercentage: state.progressPercentage,
                  localizations: localizations,
                  onPrevious: state.hasPrevious
                      ? () => context.read<StudyExecutionBloc>().add(
                          PreviousStudyChunkRequested(),
                        )
                      : null,
                  onNext: state.hasNext
                      ? () => context.read<StudyExecutionBloc>().add(
                          NextStudyChunkRequested(),
                        )
                      : null,
                );
              },
            ),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            toolbarHeight: 72,
            leadingWidth: 72,
            leading: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.fileLoadedTheme.appBarIconBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: BlocBuilder<StudyExecutionBloc, StudyExecutionState>(
                    builder: (context, state) {
                      return IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          LucideIcons.arrowLeft,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 20,
                        ),
                        tooltip: localizations.backSemanticLabel,
                        onPressed: () async {
                          if (!state.isIndexMode) {
                            context.read<StudyExecutionBloc>().add(
                              ReturnToIndexRequested(),
                            );
                            return;
                          }
                          final shouldExit = await _confirmExit();
                          if (shouldExit && context.mounted) {
                            context.read<FileBloc>().add(QuizFileReset());
                            context.pop();
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BlocBuilder<StudyExecutionBloc, StudyExecutionState>(
                        builder: (context, state) {
                          return Text(
                            state.documentTitle,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                  color: context.fileLoadedTheme.appBarIconBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async => await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const SettingsDialog(),
                  ),
                  icon: Icon(
                    LucideIcons.settings,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 20,
                  ),
                  tooltip: AppLocalizations.of(
                    context,
                  )!.questionOrderConfigTooltip,
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(6.0),
              child: BlocBuilder<StudyExecutionBloc, StudyExecutionState>(
                buildWhen: (previous, current) =>
                    previous.progressPercentage != current.progressPercentage,
                builder: (context, state) {
                  return Tooltip(
                    message: '${state.progressPercentage.toStringAsFixed(1)}%',
                    child: LinearProgressIndicator(
                      value: state.progressPercentage / 100,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                      minHeight: 6,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<StudyExecutionBloc, StudyExecutionState>(
              listenWhen: (previous, current) =>
                  !previous.needsFileReattachment &&
                  current.needsFileReattachment,
              listener: (context, state) {
                _handleFileReattachment(context);
              },
            ),
            BlocListener<StudyExecutionBloc, StudyExecutionState>(
              listenWhen: (previous, current) {
                final currentChunk = current.currentChunk;
                final previousChunk = previous.currentChunk;
                return currentChunk?.status == StudyChunkState.error &&
                    previousChunk?.status != StudyChunkState.error;
              },
              listener: (context, state) {
                final currentChunk = state.currentChunk;
                if (currentChunk == null) return;

                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(localizations.studyScreenError),
                    content: Text(
                      currentChunk.errorMessage ??
                          localizations.studyScreenError,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(
                          MaterialLocalizations.of(context).closeButtonLabel,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          context.read<StudyExecutionBloc>().add(
                            StudyChunkRequested(state.currentChunkIndex),
                          );
                        },
                        child: Text(localizations.studyScreenRetry),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          child: BlocBuilder<StudyExecutionBloc, StudyExecutionState>(
            builder: (context, state) {
              if (state.chunks.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.isIndexMode) {
                return StudyIndexView(
                  state: state,
                  localizations: localizations,
                  onAddChunk: () async {
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
                  onSave: _handleSave,
                  onImport: () => _handleFileReattachment(context),
                );
              }

              final currentChunk = state.currentChunk;
              if (currentChunk == null) {
                return Center(
                  child: Text(localizations.studyScreenNoSlidesAvailable),
                );
              }

              if (currentChunk.status == StudyChunkState.processing) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(localizations.studyScreenGenerating),
                    ],
                  ),
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StudySectionsSidebar(
                    chunks: state.chunks,
                    currentChunkIndex: state.currentChunkIndex,
                    localizations: localizations,
                    onChunkSelected: (index) {
                      context.read<StudyExecutionBloc>().add(
                        StudyChunkRequested(index),
                      );
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: currentChunk.status == StudyChunkState.error
                                ? const SizedBox.shrink()
                                : (currentChunk.slides != null &&
                                          currentChunk.slides!.isNotEmpty
                                      ? ListView.builder(
                                          itemCount:
                                              currentChunk.slides!.length,
                                          itemBuilder: (context, index) {
                                            final slide =
                                                currentChunk.slides![index];
                                            return Card(
                                              margin: const EdgeInsets.only(
                                                bottom: 16,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: slide.uiElements.map((
                                                    element,
                                                  ) {
                                                    final text =
                                                        element.props['text']
                                                            ?.toString() ??
                                                        '';
                                                    if (element.componentType ==
                                                        'Title') {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              bottom: 8.0,
                                                            ),
                                                        child: Text(
                                                          text,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .titleLarge,
                                                        ),
                                                      );
                                                    }
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            bottom: 8.0,
                                                          ),
                                                      child: Text(text),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : Center(
                                          child: Text(
                                            localizations
                                                .studyScreenNoSlidesGenerated,
                                          ),
                                        )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
