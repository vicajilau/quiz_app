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

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quizdy/routes/app_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mime/mime.dart';
import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/presentation/utils/dialog_drop_guard.dart';
import 'package:quizdy/core/extensions/string_extension.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/data/repositories/quiz_file_repository.dart';
import 'package:quizdy/data/services/configuration_service.dart';
import 'package:quizdy/data/services/ai/ai_jit_processing_service.dart';
import 'package:quizdy/data/services/pdf_export_service_io.dart'
    if (dart.library.js_interop) 'package:quizdy/data/services/pdf_export_service.dart';
import 'package:quizdy/domain/models/ai/ai_difficulty_level.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';
import 'package:quizdy/domain/models/custom_exceptions/bad_quiz_file_exception.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/use_cases/check_file_changes_use_case.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_bloc.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_event.dart';
import 'package:quizdy/presentation/blocs/study_editor_cubit/study_editor_cubit.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_bloc.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_event.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_state.dart';
import 'package:quizdy/presentation/screens/dialogs/ai_generate_study_dialog.dart';
import 'package:quizdy/presentation/screens/dialogs/exit_confirmation_dialog.dart';
import 'package:quizdy/domain/models/ai/ai_study_generation_config.dart';
import 'package:quizdy/presentation/screens/dialogs/import_chunks_dialog.dart';
import 'package:quizdy/presentation/screens/dialogs/import_questions_dialog.dart';
import 'package:quizdy/presentation/screens/widgets/request_file_name_dialog.dart';
import 'package:quizdy/presentation/screens/widgets/study/add_edit_chunk_dialog.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_app_bar.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_bottom_navigation.dart';
import 'package:quizdy/domain/models/quiz/study_component.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_body.dart';
import 'package:quizdy/presentation/screens/widgets/study/utils/study_quiz_file_helper.dart';
import 'package:quizdy/presentation/utils/latex_image_renderer.dart';

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
  final bool hideStartQuizButton;

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
    this.hideStartQuizButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => StudyExecutionBloc(
            jitProcessingService:
                ServiceLocator.getIt<AiJitProcessingService>(),
            localizations: localizations,
            initialChunks: initialChunks,
            fileAttachment: fileAttachment ?? quizFile?.fileAttachment,
            fileUri: quizFile?.fileUri,
            fileExpirationTime: quizFile?.fileExpirationTime,
            documentTitle: documentTitle,
            documentSummary: documentSummary ?? quizFile?.metadata.description,
            isAutoDifficulty:
                quizFile?.study?.isAutoDifficulty ?? isAutoDifficulty,
            difficultyLevel:
                difficultyLevel ?? quizFile?.study?.difficultyLevel,
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
        ),
        BlocProvider(
          create: (_) => StudyEditorCubit(
            initialChunks: initialChunks,
            quizFile: quizFile,
            repository: ServiceLocator.getIt<QuizFileRepository>(),
          ),
        ),
      ],
      child: StudyScreenView(
        quizFile: quizFile,
        generationMode: generationMode,
        originalText: originalText,
        hideStartQuizButton: hideStartQuizButton,
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
    this.hideStartQuizButton = false,
  });

  final QuizFile? quizFile;
  final AiGenerationMode? generationMode;
  final String? originalText;
  final bool hideStartQuizButton;

  @override
  State<StudyScreenView> createState() => _StudyScreenViewState();
}

class _StudyScreenViewState extends State<StudyScreenView> {
  bool _isDragging = false;

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

  Future<void> _handleExportPdf() async {
    final localizations = AppLocalizations.of(context)!;
    final studyState = context.read<StudyExecutionBloc>().state;

    try {
      final sanitizedTitle = studyState.documentTitle.replaceAll(
        RegExp(r'[^\w\s\-]'),
        '',
      );
      final fileName =
          '${sanitizedTitle.trim().isNotEmpty ? sanitizedTitle.trim() : "study"}.pdf';

      // Collect all formula equations across all ready chunks.
      final equations = <String>[];
      for (final chunk in studyState.chunks) {
        for (final page in chunk.pages) {
          for (final component in page.uiElements) {
            if (component.componentType == StudyComponentType.formula) {
              final eq = component.props['equation']?.toString() ?? '';
              if (eq.isNotEmpty) equations.add(eq);
            }
          }
        }
      }

      final latexImages = await LaTeXImageRenderer.renderEquations(
        context,
        equations,
      );

      final success = await ServiceLocator.getIt<StudyPdfExportService>()
          .exportStudy(
            documentTitle: studyState.documentTitle,
            documentSummary: studyState.documentSummary,
            chunks: studyState.chunks,
            dialogTitle: localizations.exportAsPdf,
            fileName: fileName,
            advantagesLabel: localizations.studyComponentAdvantages,
            limitationsLabel: localizations.studyComponentLimitations,
            latexImages: latexImages,
          );

      if (success && mounted) {
        context.presentSnackBar(localizations.exportPdfSuccess);
      }
    } catch (_) {
      if (mounted) {
        context.presentSnackBar(localizations.exportPdfError);
      }
    }
  }

  Future<void> _handleChunkImport() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['quiz'],
      );

      if (result != null && result.files.single.path != null) {
        await _importChunksFromFile(result.files.single.path!);
      }
    } catch (e) {
      if (mounted) {
        context.presentSnackBar(
          AppLocalizations.of(context)!.errorLoadingFile(e.toString()),
        );
      }
    }
  }

  Future<void> _importChunksFromFile(String filePath) async {
    try {
      final repository = ServiceLocator.getIt<QuizFileRepository>();
      final importedQuizFile = await repository.loadQuizFileContent(filePath);
      final chunks = importedQuizFile.study?.content.cache ?? [];

      if (chunks.isEmpty) {
        if (mounted) {
          context.presentSnackBar(AppLocalizations.of(context)!.noChunksInFile);
        }
        return;
      }

      if (!mounted) return;
      final currentChunks = context.read<StudyExecutionBloc>().state.chunks;

      if (currentChunks.isEmpty) {
        if (mounted) {
          context.read<StudyExecutionBloc>().add(
            ImportStudyChunksRequested(chunks: chunks, insertAtBeginning: true),
          );
          context.presentSnackBar(
            AppLocalizations.of(context)!.chunksImportedSuccess(chunks.length),
          );
        }
        return;
      }

      if (!mounted) return;
      final position = await showDialog<QuestionsPosition>(
        context: context,
        barrierDismissible: false,
        builder: (context) => ImportChunksDialog(
          chunkCount: chunks.length,
          fileName: filePath.split('/').last,
        ),
      );

      if (position != null && mounted) {
        context.read<StudyExecutionBloc>().add(
          ImportStudyChunksRequested(
            chunks: chunks,
            insertAtBeginning: position == QuestionsPosition.beginning,
          ),
        );
        context.presentSnackBar(
          AppLocalizations.of(context)!.chunksImportedSuccess(chunks.length),
        );
      }
    } on BadQuizFileException catch (e) {
      if (mounted) {
        context.presentSnackBar(e.toString());
      }
    } catch (e) {
      if (mounted) {
        context.presentSnackBar(
          AppLocalizations.of(context)!.errorLoadingFile(e.toString()),
        );
      }
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
          hideStartQuizButton: widget.hideStartQuizButton,
          onSave: _handleSave,
          onImport: _handleChunkImport,
          onExportPdf: _handleExportPdf,
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
            final isAiAvailable =
                await ServiceLocator.getIt<ConfigurationService>()
                    .getIsAiAvailable();

            if (!isAiAvailable) {
              if (context.mounted) {
                context.presentSnackBar(
                  AppLocalizations.of(context)!.aiApiKeyRequired,
                );
              }
              return;
            }

            if (!context.mounted) return;
            final config = await showDialog<AiStudyGenerationConfig>(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  AiGenerateStudyDialog(questions: widget.quizFile?.questions),
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
        appBar: StudyAppBar(
          onConfirmExit: _confirmExit,
          onEditCurrentChunk: () async {
            final cubit = context.read<StudyEditorCubit>();
            final bloc = context.read<StudyExecutionBloc>();
            final blocState = bloc.state;
            final chunkIndex = blocState.currentChunkIndex;

            if (chunkIndex < 0 || chunkIndex >= blocState.chunks.length) {
              return;
            }

            // Keep editor state aligned with current study state before opening the editor.
            cubit.resetToSnapshot(blocState.chunks);
            final snapshot = List.of(cubit.state.chunks);

            final saved = await context.push<bool>(
              AppRoutes.componentEditorScreen,
              extra: {'cubit': cubit, 'chunkIndex': chunkIndex, 'pageIndex': 0},
            );
            if (saved == true) {
              bloc.add(StudyChunksUpdated(cubit.state.chunks));
            } else {
              cubit.resetToSnapshot(snapshot);
            }
          },
        ),
        body: BlocBuilder<StudyExecutionBloc, StudyExecutionState>(
          buildWhen: (previous, current) =>
              previous.isIndexMode != current.isIndexMode,
          builder: (context, state) {
            final body = StudyBody(
              onHandleFileReattachment: _handleFileReattachment,
              onSave: _handleSave,
            );

            if (!state.isIndexMode) return body;

            return DropTarget(
              onDragDone: (details) {
                if (ModalRoute.of(context)?.isCurrent != true) return;
                setState(() => _isDragging = false);
                if (ServiceLocator.getIt<DialogDropGuard>().isActive) return;
                if (details.files.isNotEmpty) {
                  final firstFile = details.files.first;
                  if (firstFile.path.isNotEmpty) {
                    if (!firstFile.name.toLowerCase().endsWith('.quiz')) {
                      if (mounted) {
                        context.presentSnackBar(
                          AppLocalizations.of(context)!.errorInvalidFile,
                        );
                      }
                      return;
                    }
                    _importChunksFromFile(firstFile.path);
                  }
                }
              },
              onDragEntered: (_) {
                if (!ServiceLocator.getIt<DialogDropGuard>().isActive) {
                  setState(() => _isDragging = true);
                }
              },
              onDragExited: (_) => setState(() => _isDragging = false),
              child: Stack(
                children: [
                  body,
                  if (_isDragging)
                    Positioned.fill(
                      child: Container(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.15),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.upload,
                                  size: 48,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(context)!.dropFileHere,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
