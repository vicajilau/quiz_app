import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/core/context_extension.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/core/service_locator.dart';
import 'package:quiz_app/domain/models/quiz/quiz_file.dart';
import 'package:quiz_app/presentation/blocs/file_bloc/file_bloc.dart';
import 'package:quiz_app/presentation/blocs/file_bloc/file_event.dart';
import 'package:quiz_app/presentation/blocs/file_bloc/file_state.dart';
import 'package:quiz_app/presentation/screens/dialogs/import_questions_dialog.dart';

/// A mixin that handles file import operations for [FileLoadedScreen].
///
/// This mixin provides functionality to import questions from external files,
/// either by drag-and-drop or using a file picker.
mixin FileImportMixin<T extends StatefulWidget> on State<T> {
  /// The currently cached [QuizFile] that is being edited.
  QuizFile get cachedQuizFile;

  /// Updates the cached [QuizFile] with a new instance.
  ///
  /// This method typically calls `setState` in the consuming widget.
  void updateQuizFile(QuizFile newFile);

  /// Triggers a check to see if the file has unsaved changes.
  void checkFileChange();

  /// Handle importing questions from a dropped file.
  ///
  /// [filePath] is the path to the file that was dropped onto the application.
  /// If the file is valid and contains questions, they will be imported into
  /// the current quiz file.
  Future<void> handleFileImport(String filePath) async {
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
            updateQuizFile(
              cachedQuizFile.copyWith(
                questions: [...importedQuizFile.questions],
              ),
            );
            checkFileChange();
            if (mounted) {
              context.presentSnackBar(
                AppLocalizations.of(
                  context,
                )!.questionsImportedSuccess(importedQuizFile.questions.length),
              );
            }
            return;
          }

          if (!mounted) break;

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
            final updatedQuestions = [...cachedQuizFile.questions];
            if (questionsPosition == QuestionsPosition.beginning) {
              updatedQuestions.insertAll(0, importedQuizFile.questions);
            } else {
              updatedQuestions.addAll(importedQuizFile.questions);
            }

            updateQuizFile(
              cachedQuizFile.copyWith(questions: updatedQuestions),
            );
            checkFileChange();

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

  /// Handle importing questions using the system file picker.
  ///
  /// Opens a file picker dialog restricted to `.quiz` files.
  Future<void> pickAndImportFile() async {
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
          await handleFileImport(pickedFile.path!);
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
}
