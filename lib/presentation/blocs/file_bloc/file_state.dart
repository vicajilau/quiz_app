import 'package:flutter/material.dart';
import 'package:quiz_app/domain/models/quiz/quiz_file.dart';

import 'package:quiz_app/core/l10n/app_localizations.dart';

/// Abstract class representing the base state for file operations.
abstract class FileState {}

/// Initial state when no file operation is in progress.
class FileInitial extends FileState {}

/// State representing that a file operation is currently loading.
class FileLoading extends FileState {}

/// State representing a successfully loaded file, containing the file data and path.
class FileLoaded extends FileState {
  final QuizFile quizFile; // The loaded QuizFile object

  FileLoaded(this.quizFile);
}

/// State representing an error during file operation, with an error message.
class FileError extends FileState {
  final Exception? error; // Error exception
  final FileErrorType reason; // Error reason

  FileError({required this.reason, this.error});

  /// Returns a descriptive string for the error type.
  /// The [context] parameter can be used for localization if needed.
  String getDescription(BuildContext context) {
    switch (reason) {
      case FileErrorType.invalidExtension:
        return AppLocalizations.of(context)!.errorInvalidFile;
      case FileErrorType.errorOpeningFile:
      case FileErrorType.errorSavingQuizFile:
      case FileErrorType.errorPickingFileManually:
        return AppLocalizations.of(context)!.errorLoadingFile(error.toString());
      case FileErrorType.errorSavingExportedFile:
        return AppLocalizations.of(
          context,
        )!.errorExportingFile(error.toString());
    }
  }
}

/// Enumeration representing specific reasons for file-related errors.
enum FileErrorType {
  /// The file has an unsupported or incorrect extension.
  invalidExtension,

  /// There was an error while trying to open the file.
  errorOpeningFile,

  /// There was an error while trying to save the Quiz file.
  errorSavingQuizFile,

  /// There was an error while trying to save the exported file.
  errorSavingExportedFile,

  /// There was an error while trying to pick the file.
  errorPickingFileManually,
}
