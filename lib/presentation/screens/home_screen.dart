import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/context_extension.dart';
import 'package:quiz_app/domain/models/custom_exceptions/bad_quiz_file_exception.dart';

import '../../core/file_handler.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/service_locator.dart';
import '../../routes/app_router.dart';
import '../blocs/file_bloc/file_bloc.dart';
import '../blocs/file_bloc/file_event.dart';
import '../blocs/file_bloc/file_state.dart';
import 'dialogs/create_quiz_dialog.dart';
import 'dialogs/settings_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false; // Variable to track loading state

  Future<void> _showCreateQuizFileDialog(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (_) => const CreateQuizFileDialog(),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      // Validate required fields before proceeding
      final name = result['name']?.trim() ?? '';
      final description = result['description']?.trim() ?? '';
      final version = result['version']?.trim() ?? '1.0';
      final author = result['author']?.trim() ?? '';

      if (name.isNotEmpty && description.isNotEmpty && author.isNotEmpty) {
        context.read<FileBloc>().add(
          CreateQuizMetadata(
            name: name,
            version: version,
            description: description,
            author: author,
          ),
        );
      } else {
        // Show error if required fields are missing
        context.presentSnackBar(
          AppLocalizations.of(context)!.requiredFieldsError,
        );
      }
    }
  }

  Future<void> _showSettingsDialog(BuildContext context) async {
    await showDialog(context: context, builder: (_) => const SettingsDialog());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FileBloc>(
      create: (_) => ServiceLocator.instance.getIt<FileBloc>(),
      child: BlocListener<FileBloc, FileState>(
        listener: (context, state) async {
          if (state is FileLoaded) {
            context.presentSnackBar(
              AppLocalizations.of(context)!.fileLoaded(
                state.quizFile.filePath ??
                    "${state.quizFile.metadata.title}.quiz",
              ),
            );
            if (!context.mounted) return;
            final _ = await context.push(AppRoutes.fileLoadedScreen);
            if (!context.mounted) return;
            context.read<FileBloc>().add(QuizFileReset());
          }
          if (state is FileError && context.mounted) {
            if (state.error is BadQuizFileException) {
              final badFileException = state.error as BadQuizFileException;
              context.presentSnackBar(badFileException.toString());
            } else {
              context.presentSnackBar(state.getDescription(context));
            }
          }
          if (state is FileLoading) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        },
        child: Builder(
          builder: (context) {
            checkDeepLink(context);
            return Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.titleAppBar),
                leading: Tooltip(
                  message: AppLocalizations.of(context)!.raffleTooltip,
                  child: IconButton(
                    onPressed: _isLoading ? null : () => context.go('/raffle'),
                    icon: const Icon(Icons.casino, color: Colors.white),
                  ),
                ),
                actions: [
                  // Disable the create and load button if a file is loading
                  Tooltip(
                    message: AppLocalizations.of(context)!.createFileTooltip,
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => _showCreateQuizFileDialog(context),
                      child: Text(
                        AppLocalizations.of(context)!.create,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Tooltip(
                    message: AppLocalizations.of(context)!.loadFileTooltip,
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => context.read<FileBloc>().add(
                              QuizFilePickRequested(),
                            ),
                      child: Text(
                        AppLocalizations.of(context)!.load,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  // Configuration button
                  Tooltip(
                    message: AppLocalizations.of(
                      context,
                    )!.questionOrderConfigTooltip,
                    child: IconButton(
                      onPressed: _isLoading
                          ? null
                          : () => _showSettingsDialog(context),
                      icon: const Icon(Icons.settings, color: Colors.white),
                    ),
                  ),
                ],
              ),
              body: DropTarget(
                onDragDone: (details) {
                  // Validate that we have files and the file bloc is not already loaded
                  if (context.read<FileBloc>().state is! FileLoaded &&
                      details.files.isNotEmpty) {
                    final firstFile = details.files.first;
                    // Additional validation: check if the file has a valid path
                    if (firstFile.path.isNotEmpty) {
                      context.read<FileBloc>().add(FileDropped(firstFile.path));
                    }
                  }
                },
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () => context.read<FileBloc>().add(
                                    QuizFilePickRequested(),
                                  ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7,
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.4,
                              ),
                              child: Image.asset(
                                'images/QUIZ.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            AppLocalizations.of(context)!.dropFileHere,
                            style: TextStyle(
                              fontSize: 16,
                              color: _isLoading
                                  ? Colors.grey
                                  : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Check if there is a deep link and handle it
  void checkDeepLink(BuildContext c) {
    FileHandler.initialize((filePath) {
      c.read<FileBloc>().add(FileDropped(filePath));
    });
  }
}
