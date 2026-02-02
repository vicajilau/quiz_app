import 'package:flutter/material.dart';
import 'package:quiz_app/core/constants/theme_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:quiz_app/core/context_extension.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/core/service_locator.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/quiz_file.dart';
import 'package:quiz_app/domain/use_cases/check_file_changes_use_case.dart';
import 'package:quiz_app/presentation/blocs/file_bloc/file_bloc.dart';
import 'package:quiz_app/presentation/blocs/file_bloc/file_state.dart';
import 'package:quiz_app/presentation/screens/dialogs/add_edit_question_dialog.dart';
import 'package:quiz_app/presentation/screens/dialogs/exit_confirmation_dialog.dart';
import 'package:quiz_app/presentation/screens/dialogs/question_count_selection_dialog.dart';
import 'package:quiz_app/presentation/screens/dialogs/settings_dialog.dart';
import 'package:quiz_app/presentation/screens/widgets/question_list_widget.dart';
import 'package:quiz_app/routes/app_router.dart';
import 'mixins/file_import_mixin.dart';
import 'mixins/ai_generation_mixin.dart';
import 'mixins/file_save_mixin.dart';

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

class _FileLoadedScreenState extends State<FileLoadedScreen>
    with FileImportMixin, AiGenerationMixin, FileSaveMixin {
  @override
  late QuizFile cachedQuizFile;
  bool _hasFileChanged = false; // Variable to track file change status

  // Function to check if the file has changed
  @override
  void checkFileChange() {
    final hasChanged = widget.checkFileChangesUseCase.execute(cachedQuizFile);
    setState(() {
      _hasFileChanged = hasChanged;
    });
  }

  @override
  void updateQuizFile(QuizFile newFile) {
    setState(() {
      cachedQuizFile = newFile;
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

  @override
  void initState() {
    super.initState();
    cachedQuizFile = widget.quizFile.deepCopy();
    checkFileChange(); // Check the file change status when the screen is loaded
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
              checkFileChange();
            }
            if (state is FileError) {
              context.presentSnackBar(state.getDescription(context));
            }
          },
          child: Builder(
            builder: (context) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    "${cachedQuizFile.metadata.title} - ${cachedQuizFile.metadata.description}",
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
                          checkFileChange();
                        }
                      },
                      icon: const Icon(Icons.add),
                      tooltip: AppLocalizations.of(context)!.addTooltip,
                    ),
                    // Generate with AI Action
                    IconButton(
                      onPressed: () async {
                        await generateQuestionsWithAI();
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
                        await pickAndImportFile();
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
                              await onSavePressed(context);
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
                        handleFileImport(firstFile.path);
                      }
                    }
                  },
                  child: QuestionListWidget(
                    quizFile: cachedQuizFile,
                    onFileChange: checkFileChange,
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
}
