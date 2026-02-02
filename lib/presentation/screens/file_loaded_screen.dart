import 'package:flutter/material.dart';
import 'package:quiz_app/core/constants/theme_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:quiz_app/core/context_extension.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/quiz_file.dart';
import 'package:quiz_app/presentation/screens/dialogs/add_edit_question_dialog.dart';
import 'package:quiz_app/presentation/screens/widgets/question_list_widget.dart';
import 'package:quiz_app/routes/app_router.dart';
import 'package:platform_detail/platform_detail.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/extensions/string_extensions.dart';
import '../../core/service_locator.dart';
import '../../data/services/configuration_service.dart';
import '../../domain/use_cases/check_file_changes_use_case.dart';
import '../blocs/file_bloc/file_bloc.dart';
import '../blocs/file_bloc/file_event.dart';
import '../blocs/file_bloc/file_state.dart';
import 'dialogs/exit_confirmation_dialog.dart';
import 'dialogs/question_count_selection_dialog.dart';
import 'dialogs/import_questions_dialog.dart';
import 'dialogs/ai_generate_questions_dialog.dart';
import 'widgets/request_file_name_dialog.dart';
import 'dialogs/settings_dialog.dart';
import 'dialogs/quiz_metadata_dialog.dart';
import '../../data/services/ai/ai_question_generation_service.dart';

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
  bool _hasFileChanged = false; // Variable to track file change status

  // Function to check if the file has changed
  void _checkFileChange() {
    final hasChanged = widget.checkFileChangesUseCase.execute(cachedQuizFile);
    setState(() {
      _hasFileChanged = hasChanged;
    });
  }

  Future<bool> _confirmExit() async {
    if (widget.checkFileChangesUseCase.execute(cachedQuizFile)) {
      return await showDialog<bool>(
            context: context,
            builder: (context) => ExitConfirmationDialog(),
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
            _checkFileChange();
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
            _checkFileChange();

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

  /// Handle importing questions using file picker
  Future<void> _pickAndImportFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['quiz'],
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        if (pickedFile.path != null) {
          await _handleFileImport(pickedFile.path!);
        } else {
          if (mounted) {
            context.presentSnackBar(
              AppLocalizations.of(context)!.errorLoadingFile(
                AppLocalizations.of(context)!.couldNotAccessFile,
              ),
            );
          }
        }
      }
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
      final isAIactivated = await ConfigurationService.instance
          .getAIAssistantEnabled();

      // Check if AI is enabled and has API keys
      final openaiKey = await ConfigurationService.instance.getOpenAIApiKey();
      final geminiKey = await ConfigurationService.instance.getGeminiApiKey();

      if (!isAIactivated) {
        if (mounted) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!.aiAssistantDisabled),
                content: Text(AppLocalizations.of(context)!.enableAiAssistant),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: Text(AppLocalizations.of(context)!.acceptButton),
                  ),
                ],
              );
            },
          );
        }
        return;
      }

      if ((openaiKey?.isEmpty ?? true) && (geminiKey?.isEmpty ?? true)) {
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
        barrierDismissible: false, // Prevent dismissing by tapping outside
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
          _checkFileChange();
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
          _checkFileChange();

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

  @override
  void initState() {
    super.initState();
    cachedQuizFile = widget.quizFile.deepCopy();
    _checkFileChange(); // Check the file change status when the screen is loaded
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
              // Update the cached file reference when a file is saved successfully
              // This ensures that change detection works correctly with the new file path
              cachedQuizFile = state.quizFile.deepCopy();

              context.presentSnackBar(
                AppLocalizations.of(
                  context,
                )!.fileSaved(state.quizFile.filePath!),
              );
              _checkFileChange();
            }
            if (state is FileError) {
              context.presentSnackBar(state.getDescription(context));
            }
          },
          child: Builder(
            builder: (context) {
              return Scaffold(
                appBar: AppBar(
                  title: Tooltip(
                    message: cachedQuizFile.metadata.description,
                    child: InkWell(
                      onTap: () => _editQuizMetadata(context),
                      child: Text(
                        cachedQuizFile.metadata.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      semanticLabel: AppLocalizations.of(
                        context,
                      )!.backSemanticLabel,
                    ),
                    onPressed: () async {
                      final shouldExit = await _confirmExit();
                      if (shouldExit && context.mounted) {
                        context.pop();
                      }
                    },
                  ),
                  actions: [
                    IconButton(
                      onPressed: () async {
                        final createdQuestion = await showDialog<Question>(
                          context: context,
                          barrierDismissible:
                              false, // Prevent dismissing by tapping outside
                          builder: (context) =>
                              AddEditQuestionDialog(quizFile: cachedQuizFile),
                        );
                        if (createdQuestion != null) {
                          setState(() {
                            cachedQuizFile.questions.add(createdQuestion);
                          });
                          _checkFileChange();
                        }
                      },
                      icon: const Icon(Icons.add),
                      tooltip: AppLocalizations.of(context)!.addTooltip,
                    ),
                    // Generate with AI Action
                    IconButton(
                      onPressed: () async {
                        await _generateQuestionsWithAI();
                      },
                      icon: Icon(
                        Icons.auto_awesome,
                        color: Theme.of(
                          context,
                        ).extension<CustomColors>()!.aiIconColor,
                      ),
                      tooltip: AppLocalizations.of(
                        context,
                      )!.generateQuestionsWithAI,
                    ),
                    // Import Action
                    IconButton(
                      onPressed: () async {
                        await _pickAndImportFile();
                      },
                      icon: const Icon(Icons.file_upload),
                      tooltip: AppLocalizations.of(
                        context,
                      )!.importQuestionsTooltip,
                    ),
                    // Save Action
                    IconButton(
                      icon: const Icon(Icons.save),
                      tooltip: _hasFileChanged
                          ? AppLocalizations.of(context)!.saveTooltip
                          : AppLocalizations.of(context)!.saveDisabledTooltip,
                      onPressed: _hasFileChanged
                          ? () async {
                              await _onSavePressed(context);
                            }
                          : null, // Disable button if file hasn't changed
                    ),
                    // Configuration button
                    IconButton(
                      onPressed: () => _showSettingsDialog(context),
                      icon: const Icon(Icons.settings),
                      tooltip: AppLocalizations.of(
                        context,
                      )!.questionOrderConfigTooltip,
                    ),
                  ],
                ),
                body: DropTarget(
                  onDragDone: (details) {
                    // Handle file drop for importing questions
                    if (details.files.isNotEmpty) {
                      final firstFile = details.files.first;
                      if (firstFile.path.isNotEmpty) {
                        _handleFileImport(firstFile.path);
                      }
                    }
                  },
                  child: QuestionListWidget(
                    quizFile: cachedQuizFile,
                    onFileChange: _checkFileChange,
                  ),
                ),
                floatingActionButton: cachedQuizFile.questions.isNotEmpty
                    ? FloatingActionButton(
                        tooltip: AppLocalizations.of(context)!.executeTooltip,
                        onPressed: () async {
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

                          final selectedQuestionCount = await showDialog<int>(
                            context: context,
                            builder: (context) => QuestionCountSelectionDialog(
                              totalQuestions: enabledQuestions.length,
                            ),
                          );

                          if (selectedQuestionCount != null &&
                              context.mounted) {
                            // Register the updated quiz file and question count in the service locator
                            ServiceLocator.instance.registerQuizFile(
                              cachedQuizFile,
                            );
                            ServiceLocator.instance.registerQuizConfig(
                              questionCount: selectedQuestionCount,
                            );

                            // Navigate to the quiz execution screen
                            context.push(AppRoutes.quizFileExecutionScreen);
                          }
                        },
                        child: const Icon(Icons.play_arrow),
                      )
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _onSavePressed(BuildContext context) async {
    final String? fileName;
    if (PlatformDetail.isWeb) {
      final result = await showDialog<String>(
        context: context,
        builder: (_) => RequestFileNameDialog(format: '.quiz'),
      );
      fileName = result;
    } else {
      fileName = AppLocalizations.of(context)!.defaultOutputFileName;
    }
    if (fileName != null && context.mounted) {
      context.read<FileBloc>().add(
        QuizFileSaveRequested(
          cachedQuizFile,
          AppLocalizations.of(context)!.saveDialogTitle,
          fileName,
        ),
      );
    }
  }

  Future<void> _editQuizMetadata(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => QuizMetadataDialog(
        initialName: cachedQuizFile.metadata.title,
        initialDescription: cachedQuizFile.metadata.description,
        initialAuthor: cachedQuizFile.metadata.author,
        isEditing: true,
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
      _checkFileChange();
    }
  }
}
