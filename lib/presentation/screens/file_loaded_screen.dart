import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/context_extension.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/quiz_file.dart';
import 'package:quiz_app/presentation/screens/dialogs/add_edit_question_dialog.dart';
import 'package:quiz_app/presentation/screens/widgets/question_list_widget.dart';
import 'package:quiz_app/routes/app_router.dart';
import 'package:platform_detail/platform_detail.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/service_locator.dart';
import '../../domain/use_cases/check_file_changes_use_case.dart';
import '../blocs/file_bloc/file_bloc.dart';
import '../blocs/file_bloc/file_event.dart';
import '../blocs/file_bloc/file_state.dart';
import 'dialogs/exit_confirmation_dialog.dart';
import 'dialogs/question_count_selection_dialog.dart';
import 'widgets/request_file_name_dialog.dart';
import '../widgets/dialogs/question_order_config_dialog.dart';

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

  Future<void> _showQuestionOrderConfigDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => const QuestionOrderConfigDialog(),
    );
  }

  @override
  void initState() {
    super.initState();
    cachedQuizFile = widget.quizFile;
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
                          builder: (context) =>
                              AddEditQuestionDialog(quizFile: cachedQuizFile),
                        );
                        if (createdQuestion != null) {
                          cachedQuizFile.questions.add(createdQuestion);
                          _checkFileChange();
                        }
                      },
                      icon: const Icon(Icons.add),
                      tooltip: AppLocalizations.of(context)!.addTooltip,
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
                      onPressed: () => _showQuestionOrderConfigDialog(context),
                      icon: const Icon(Icons.settings),
                      tooltip: AppLocalizations.of(context)!.questionOrderConfigTooltip,
                    ),
                  ],
                ),
                body: QuestionListWidget(
                  quizFile: cachedQuizFile,
                  onFileChange: _checkFileChange,
                ),
                floatingActionButton: cachedQuizFile.questions.isNotEmpty
                    ? FloatingActionButton(
                        tooltip: AppLocalizations.of(context)!.executeTooltip,
                        onPressed: () async {
                          final selectedQuestionCount = await showDialog<int>(
                            context: context,
                            builder: (context) => QuestionCountSelectionDialog(
                              totalQuestions: cachedQuizFile.questions.length,
                            ),
                          );

                          if (selectedQuestionCount != null &&
                              context.mounted) {
                            // Register the selected question count in the service locator
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
      fileName = AppLocalizations.of(context)!.saveDialogTitle;
    }
    if (fileName != null && context.mounted) {
      context.read<FileBloc>().add(
        QuizFileSaveRequested(cachedQuizFile, fileName, "output-file.quiz"),
      );
    }
  }
}
