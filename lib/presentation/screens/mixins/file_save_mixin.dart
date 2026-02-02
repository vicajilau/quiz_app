import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:platform_detail/platform_detail.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/domain/models/quiz/quiz_file.dart';
import 'package:quiz_app/presentation/blocs/file_bloc/file_bloc.dart';
import 'package:quiz_app/presentation/blocs/file_bloc/file_event.dart';
import 'package:quiz_app/presentation/screens/dialogs/create_quiz_dialog.dart';
import 'package:quiz_app/presentation/screens/widgets/request_file_name_dialog.dart';

/// A mixin that handles file saving operations for [FileLoadedScreen].
///
/// This mixin provides functionality to save the current quiz file, including
/// prompting for metadata if it is incomplete.
mixin FileSaveMixin<T extends StatefulWidget> on State<T> {
  /// The currently cached [QuizFile] that is being edited.
  QuizFile get cachedQuizFile;

  /// Updates the cached [QuizFile] with a new instance.
  ///
  /// This method typically calls `setState` in the consuming widget.
  void updateQuizFile(QuizFile newFile);

  /// Handles the save action.
  ///
  /// Checks if the quiz metadata (title, description) is incomplete.
  /// If it is, shows a [CreateQuizFileDialog] to collect the missing information.
  /// Otherwise, proceeds to save the file using the [FileBloc].
  Future<void> onSavePressed(BuildContext context) async {
    // Check if metadata is incomplete (title is "Untitled Quiz" or description is empty)
    // Note: "Untitled Quiz" is the default title we set in home_screen.dart
    final isMetadataIncomplete =
        cachedQuizFile.metadata.title == 'Untitled Quiz' ||
        cachedQuizFile.metadata.description == 'Description' ||
        cachedQuizFile.metadata.description.isEmpty;

    if (isMetadataIncomplete) {
      final result = await showDialog<Map<String, String>>(
        context: context,
        barrierDismissible: false,
        builder: (_) => CreateQuizFileDialog(
          initialMetadata: {
            'name': cachedQuizFile.metadata.title,
            'description': cachedQuizFile.metadata.description,
            'version': cachedQuizFile.metadata.version,
            'author': cachedQuizFile.metadata.author,
          },
        ),
      );

      if (result == null) return; // User cancelled

      // Update cached metadata
      updateQuizFile(
        cachedQuizFile.copyWith(
          metadata: cachedQuizFile.metadata.copyWith(
            title: result['name'],
            description: result['description'],
            version: result['version'],
            author: result['author'],
          ),
        ),
      );
    }

    if (!context.mounted) return;

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
}
