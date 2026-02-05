import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/context_extension.dart';
import 'package:quiz_app/domain/models/custom_exceptions/bad_quiz_file_exception.dart';

import 'package:quiz_app/core/file_handler.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/core/service_locator.dart';
import 'package:quiz_app/routes/app_router.dart';
import 'package:quiz_app/core/constants/quiz_metadata.dart';
import 'package:quiz_app/presentation/blocs/file_bloc/file_bloc.dart';
import 'package:quiz_app/presentation/blocs/file_bloc/file_event.dart';
import 'package:quiz_app/presentation/blocs/file_bloc/file_state.dart';
import 'package:quiz_app/presentation/screens/dialogs/quiz_metadata_dialog.dart';
import 'package:quiz_app/presentation/screens/dialogs/settings_dialog.dart';

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
      builder: (_) => const QuizMetadataDialog(),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      // Validate required fields before proceeding
      final name = result['name']?.trim() ?? '';
      final description = result['description']?.trim() ?? '';
      const version = QuizMetadataConstants.version;
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
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SettingsDialog(),
    );
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
                    '${state.quizFile.metadata.title}.quiz',
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
              body: SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: DropTarget(
                            onDragDone: (details) {
                              // Validate that we have files
                              if (details.files.isNotEmpty && !_isLoading) {
                                // If we are not on the home screen, ignore the drop in HomeScreen
                                if (context.currentRoute != AppRoutes.home) {
                                  return;
                                }

                                final firstFile = details.files.first;
                                // Additional validation: check if the file has a valid path
                                if (firstFile.path.isNotEmpty) {
                                  // Reset state before loading to ensure clean state on web
                                  context.read<FileBloc>().add(QuizFileReset());
                                  context.read<FileBloc>().add(
                                    FileDropped(firstFile.path),
                                  );
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
                                            : () {
                                                context.read<FileBloc>().add(
                                                  QuizFileReset(),
                                                );
                                                context.read<FileBloc>().add(
                                                  QuizFilePickRequested(),
                                                );
                                              },
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.7,
                                            maxHeight:
                                                MediaQuery.of(
                                                  context,
                                                ).size.height *
                                                0.4,
                                          ),
                                          child: Image.asset(
                                            'images/QUIZ.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.dropFileHere,
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
                        ),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: 12,
                            children: [
                              // Primary Action: Create Quiz
                              Tooltip(
                                message: AppLocalizations.of(
                                  context,
                                )!.createFileTooltip,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading
                                      ? null
                                      : () =>
                                            _showCreateQuizFileDialog(context),
                                  icon: const Icon(Icons.add),
                                  label: Text(
                                    AppLocalizations.of(context)!.create,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                ),
                              ),

                              // Secondary Action: Load Quiz
                              Tooltip(
                                message: AppLocalizations.of(
                                  context,
                                )!.loadFileTooltip,
                                child: OutlinedButton.icon(
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          context.read<FileBloc>().add(
                                            QuizFileReset(),
                                          );
                                          context.read<FileBloc>().add(
                                            QuizFilePickRequested(),
                                          );
                                        },
                                  icon: const Icon(Icons.file_upload),
                                  label: Text(
                                    AppLocalizations.of(context)!.load,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),

                              // Tertiary Action: Raffle / Tools
                              Tooltip(
                                message: AppLocalizations.of(
                                  context,
                                )!.raffleTooltip,
                                child: TextButton.icon(
                                  onPressed: _isLoading
                                      ? null
                                      : () => context.go(AppRoutes.raffle),
                                  icon: Icon(
                                    Icons.casino_outlined,
                                    size: 20,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                  ),
                                  label: Text(
                                    AppLocalizations.of(context)!.sorteosLabel,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Tooltip(
                        message: AppLocalizations.of(
                          context,
                        )!.questionOrderConfigTooltip,
                        child: IconButton(
                          onPressed: _isLoading
                              ? null
                              : () => _showSettingsDialog(context),
                          icon: Icon(
                            Icons.settings,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Check if there is a deep link and handle it
  /// Check if there is a deep link and handle it
  void checkDeepLink(BuildContext c) {
    FileHandler.initialize((filePath) {
      c.read<FileBloc>().add(FileDropped(filePath));
    });
  }
}
