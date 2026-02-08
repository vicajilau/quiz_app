import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quiz_app/core/context_extension.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/quiz_file.dart';
import 'package:quiz_app/domain/models/quiz/quiz_config.dart';
import 'package:quiz_app/presentation/screens/dialogs/add_edit_question_dialog.dart';
import 'package:quiz_app/presentation/screens/dialogs/exit_confirmation_dialog.dart';
import 'package:quiz_app/presentation/screens/widgets/question_list_widget.dart';
import 'package:quiz_app/routes/app_router.dart';

import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/core/extensions/string_extensions.dart';
import 'package:quiz_app/core/service_locator.dart';
import 'package:quiz_app/data/services/configuration_service.dart';
import 'package:quiz_app/domain/use_cases/check_file_changes_use_case.dart';
import 'package:quiz_app/presentation/blocs/file_bloc/file_bloc.dart';
import 'package:quiz_app/presentation/blocs/file_bloc/file_event.dart';
import 'package:quiz_app/presentation/blocs/file_bloc/file_state.dart';
import 'package:quiz_app/presentation/screens/dialogs/question_count_selection_dialog.dart';
import 'package:quiz_app/presentation/screens/dialogs/import_questions_dialog.dart';
import 'package:quiz_app/presentation/screens/dialogs/ai_generate_questions_dialog.dart';
import 'package:quiz_app/presentation/screens/widgets/file_loaded_bottom_bar.dart';
import 'package:quiz_app/presentation/screens/dialogs/settings_dialog.dart';
import 'package:quiz_app/presentation/screens/widgets/request_file_name_dialog.dart';
import 'package:quiz_app/data/services/ai/ai_question_generation_service.dart';
import 'package:quiz_app/presentation/screens/dialogs/quiz_metadata_dialog.dart';

class FileLoadedScreen extends StatefulWidget {
  final FileBloc fileBloc;
  final CheckFileChangesUseCase checkFileChangesUseCase;
  final QuizFile quizFile;

  const FileLoadedScreen({
    super.key,
    required this.fileBloc,
    required this.checkFileChangesUseCase,
    required this.quizFile,
  });

  @override
  State<FileLoadedScreen> createState() => _FileLoadedScreenState();
}

class _FileLoadedScreenState extends State<FileLoadedScreen> {
  late QuizFile cachedQuizFile;
  bool _isSelectionMode = false;
  final Set<int> _selectedQuestions = {};
  bool _isDragging = false;

  Future<bool> _confirmExit() async {
    if (widget.checkFileChangesUseCase.execute(cachedQuizFile)) {
      return await showDialog<bool>(
            context: context,
            builder: (context) => const ExitConfirmationDialog(),
          ) ??
          false;
    }
    return true;
  }

  Future<void> _showSettingsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SettingsDialog(),
    );
  }

  Future<void> _handleImportButton() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['quiz'],
      );

      if (result != null && result.files.single.path != null) {
        await _handleFileImport(result.files.single.path!);
      }
    } catch (e) {
      if (mounted) {
        context.presentSnackBar(
          AppLocalizations.of(context)!.errorLoadingFile(e.toString()),
        );
      }
    }
  }

  Future<void> _handleSave() async {
    var fileName = cachedQuizFile.filePath?.split('/').last;

    // If fileName is null, empty, or likely a blob URL (doesn't have .quiz extension), ask for a name
    if (fileName == null ||
        fileName.isEmpty ||
        !fileName.toLowerCase().endsWith('.quiz')) {
      if (!mounted) return;
      final result = await showDialog<String>(
        context: context,
        builder: (context) => const RequestFileNameDialog(format: '.quiz'),
      );

      if (result != null && result.isNotEmpty) {
        fileName = result;
      } else {
        // User cancelled the dialog
        return;
      }
    }
    if (mounted) {
      widget.fileBloc.add(
        QuizFileSaveRequested(
          cachedQuizFile,
          AppLocalizations.of(context)!.saveButton,
          fileName,
        ),
      );
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedQuestions.clear();
    });
  }

  void _toggleQuestionSelection(int index) {
    setState(() {
      if (_selectedQuestions.contains(index)) {
        _selectedQuestions.remove(index);
      } else {
        _selectedQuestions.add(index);
      }
    });
  }

  /// Handle importing questions from a dropped file
  Future<void> _handleFileImport(String filePath) async {
    try {
      // Create a temporary file bloc to load the dropped file
      final tempFileBloc = FileBloc(
        fileRepository: ServiceLocator.instance.getIt(),
      );

      tempFileBloc.add(FileDropped(filePath));

      // Listen to the file load result
      await for (final state in tempFileBloc.stream) {
        if (state is FileLoaded) {
          final importedQuizFile = state.quizFile;

          if (importedQuizFile.questions.isEmpty) {
            if (mounted) {
              context.presentSnackBar(
                AppLocalizations.of(context)!.errorLoadingFile(
                  AppLocalizations.of(context)!.noQuestionsInFile,
                ),
              );
            }
            break;
          }

          if (cachedQuizFile.questions.isEmpty) {
            setState(() {
              cachedQuizFile.questions.insertAll(0, importedQuizFile.questions);
            });
            if (mounted) {
              context.presentSnackBar(
                AppLocalizations.of(
                  context,
                )!.questionsImportedSuccess(importedQuizFile.questions.length),
              );
            }
            return;
          }

          // Show import dialog
          final questionsPosition = await showDialog<QuestionsPosition>(
            context: context,
            barrierDismissible: false,
            builder: (context) => ImportQuestionsDialog(
              questionCount: importedQuizFile.questions.length,
              fileName: filePath.split('/').last,
            ),
          );

          if (questionsPosition != null && mounted) {
            setState(() {
              if (questionsPosition == QuestionsPosition.beginning) {
                // Insert at the beginning
                cachedQuizFile.questions.insertAll(
                  0,
                  importedQuizFile.questions,
                );
              } else {
                // Insert at the end
                cachedQuizFile.questions.addAll(importedQuizFile.questions);
              }
            });

            if (mounted) {
              context.presentSnackBar(
                AppLocalizations.of(
                  context,
                )!.questionsImportedSuccess(importedQuizFile.questions.length),
              );
            }
          }
          break;
        } else if (state is FileError) {
          if (mounted) {
            context.presentSnackBar(state.getDescription(context));
          }
          break;
        }
      }

      tempFileBloc.close();
    } catch (e) {
      if (mounted) {
        context.presentSnackBar(
          AppLocalizations.of(context)!.errorLoadingFile(e.toString()),
        );
      }
    }
  }

  /// Handle generating questions with AI
  Future<void> _generateQuestionsWithAI() async {
    try {
      final isAiAvailable = await ConfigurationService.instance
          .getIsAiAvailable();

      if (!isAiAvailable) {
        if (mounted) {
          context.presentSnackBar(
            AppLocalizations.of(context)!.aiApiKeyRequired,
          );
        }
        return;
      }

      // Show AI generation dialog
      if (!mounted) return;
      final config = await showDialog<AiQuestionGenerationConfig>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AiGenerateQuestionsDialog(),
      );

      if (config == null || !mounted) return;

      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Generate questions with AI
        final aiService = AiQuestionGenerationService();
        final localizations = AppLocalizations.of(context)!;
        final generatedQuestions = await aiService.generateQuestions(
          config,
          localizations: localizations,
        );

        // Close loading dialog
        if (mounted) {
          context.pop();
        }

        if (generatedQuestions.isEmpty) {
          if (mounted) {
            context.presentSnackBar(
              AppLocalizations.of(context)!.aiGenerationFailed,
            );
          }
          return;
        }

        if (cachedQuizFile.questions.isEmpty) {
          setState(() {
            cachedQuizFile.questions.insertAll(0, generatedQuestions);
          });
          if (mounted) {
            context.presentSnackBar(
              AppLocalizations.of(
                context,
              )!.questionsImportedSuccess(generatedQuestions.length),
            );
          }
          return;
        }

        // Show import dialog to choose position
        if (!mounted) return;
        final questionsPosition = await showDialog<QuestionsPosition>(
          context: context,
          barrierDismissible: false,
          builder: (context) => ImportQuestionsDialog(
            questionCount: generatedQuestions.length,
            fileName: AppLocalizations.of(context)!.aiGeneratedQuestions,
          ),
        );

        if (questionsPosition != null && mounted) {
          setState(() {
            if (questionsPosition == QuestionsPosition.beginning) {
              // Insert at the beginning
              cachedQuizFile.questions.insertAll(0, generatedQuestions);
            } else {
              // Insert at the end
              cachedQuizFile.questions.addAll(generatedQuestions);
            }
          });

          if (mounted) {
            context.presentSnackBar(
              AppLocalizations.of(
                context,
              )!.questionsImportedSuccess(generatedQuestions.length),
            );
          }
        }
      } catch (e) {
        // Close loading dialog if still open
        if (mounted) {
          context.pop();

          context.presentSnackBar(
            AppLocalizations.of(
              context,
            )!.aiGenerationError(e.toString().cleanExceptionPrefix()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        context.presentSnackBar('Error: ${e.toString()}');
      }
    }
  }

  Future<void> _handleDeleteQuestions() async {
    if (_selectedQuestions.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF27272A), // Zinc 800
        title: Text(
          AppLocalizations.of(context)!.deleteButton,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          _selectedQuestions.length == 1
              ? AppLocalizations.of(context)!.deleteSingleQuestionConfirmation
              : AppLocalizations.of(
                  context,
                )!.deleteMultipleQuestionsConfirmation(
                  _selectedQuestions.length,
                ),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              AppLocalizations.of(context)!.cancelButton,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: Text(AppLocalizations.of(context)!.deleteButton),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        final indices = _selectedQuestions.toList()
          ..sort((a, b) => b.compareTo(a));
        for (final index in indices) {
          cachedQuizFile.questions.removeAt(index);
        }
        _selectedQuestions.clear();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    cachedQuizFile = widget.quizFile.deepCopy();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _confirmExit();
        return shouldExit;
      },
      child: BlocProvider<FileBloc>(
        create: (_) => widget.fileBloc,
        child: BlocListener<FileBloc, FileState>(
          listener: (context, state) {
            if (state is FileLoaded) {
              cachedQuizFile = state.quizFile.deepCopy();
              setState(() {});
              context.presentSnackBar(
                AppLocalizations.of(
                  context,
                )!.fileSaved(state.quizFile.filePath!),
              );
            }
            if (state is FileError) {
              context.presentSnackBar(state.getDescription(context));
            }
          },
          child: Builder(
            builder: (context) {
              return Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(72),
                  child: AppBar(
                    backgroundColor: const Color(0xFF8B5CF6), // Violet 500
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(24),
                      ),
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
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              LucideIcons.arrowLeft,
                              color: Colors.white,
                              size: 20,
                            ),
                            tooltip: AppLocalizations.of(
                              context,
                            )!.backSemanticLabel,
                            onPressed: () async {
                              final shouldExit = await _confirmExit();
                              if (shouldExit && context.mounted) {
                                context.pop();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () async {
                              final result =
                                  await showDialog<Map<String, String>>(
                                    context: context,
                                    builder: (context) => QuizMetadataDialog(
                                      isEditing: true,
                                      initialName:
                                          cachedQuizFile.metadata.title,
                                      initialDescription:
                                          cachedQuizFile.metadata.description,
                                      initialAuthor:
                                          cachedQuizFile.metadata.author,
                                    ),
                                  );

                              if (result != null && mounted) {
                                setState(() {
                                  cachedQuizFile = cachedQuizFile.copyWith(
                                    metadata: cachedQuizFile.metadata.copyWith(
                                      title: result['name'],
                                      description: result['description'],
                                      author: result['author'],
                                    ),
                                  );
                                });
                              }
                            },
                            child: Text(
                              AppLocalizations.of(context)!.quizPreviewTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      // Settings Button
                      Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => _showSettingsDialog(context),
                          icon: const Icon(
                            LucideIcons.settings,
                            color: Colors.white,
                            size: 20,
                          ),
                          tooltip: AppLocalizations.of(
                            context,
                          )!.questionOrderConfigTooltip,
                        ),
                      ),
                      // Select Button
                      Container(
                        margin: const EdgeInsets.only(right: 24),
                        child: Material(
                          color: _isSelectionMode
                              ? const Color(0xFF8B5CF6) // Active state color
                              : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              _toggleSelectionMode();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isSelectionMode
                                        ? LucideIcons.checkSquare
                                        : LucideIcons.mousePointer2,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isSelectionMode
                                        ? AppLocalizations.of(context)!.done
                                        : AppLocalizations.of(context)!.select,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter',
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
                ),
                body: DropTarget(
                  onDragDone: (details) {
                    setState(() => _isDragging = false);
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
                        _handleFileImport(firstFile.path);
                      }
                    }
                  },
                  onDragEntered: (_) => setState(() => _isDragging = true),
                  onDragExited: (_) => setState(() => _isDragging = false),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: QuestionListWidget(
                          quizFile: cachedQuizFile,
                          onFileChange: () {},
                          isSelectionMode: _isSelectionMode,
                          selectedQuestions: _selectedQuestions,
                          onToggleSelection: _toggleQuestionSelection,
                          onSelectionChanged: (newSelection) {
                            setState(() {
                              _selectedQuestions.clear();
                              _selectedQuestions.addAll(newSelection);
                            });
                          },
                        ),
                      ),
                      if (_isDragging)
                        Positioned.fill(
                          child: Container(
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1),
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
                                      AppLocalizations.of(
                                        context,
                                      )!.dropFileHere,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
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
                ),

                bottomNavigationBar: FileLoadedBottomBar(
                  onAddQuestion: () async {
                    final createdQuestion = await showDialog<Question>(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) =>
                          AddEditQuestionDialog(quizFile: cachedQuizFile),
                    );
                    if (createdQuestion != null) {
                      setState(() {
                        cachedQuizFile.questions.add(createdQuestion);
                      });
                    }
                  },
                  onGenerateAI: () async {
                    await _generateQuestionsWithAI();
                  },
                  onImport: _handleImportButton,
                  onSave: _handleSave,
                  onDelete: _handleDeleteQuestions,
                  selectedQuestionCount: _selectedQuestions.length,
                  showSaveButton: widget.checkFileChangesUseCase.execute(
                    cachedQuizFile,
                  ),
                  isPlayEnabled: cachedQuizFile.questions.any(
                    (q) => q.isEnabled,
                  ),
                  onPlay: () async {
                    // Filter enabled questions first
                    final enabledQuestions = cachedQuizFile.questions
                        .where((question) => question.isEnabled)
                        .toList();

                    if (enabledQuestions.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(
                              context,
                            )!.noEnabledQuestionsError,
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    final quizConfig = await showDialog<QuizConfig>(
                      context: context,
                      builder: (context) => QuestionCountSelectionDialog(
                        totalQuestions: enabledQuestions.length,
                      ),
                    );

                    if (quizConfig != null && context.mounted) {
                      ServiceLocator.instance.registerQuizFile(cachedQuizFile);
                      ServiceLocator.instance.registerQuizConfig(quizConfig);
                      context.push(AppRoutes.quizFileExecutionScreen);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
