import 'package:flutter/material.dart';
import 'package:quiz_app/domain/models/export_formats.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../domain/models/maso/maso_file.dart';

/// Abstract class representing the base state for file operations.
abstract class FileState {}

/// Initial state when no file operation is in progress.
class FileInitial extends FileState {}

/// State representing that a file operation is currently loading.
class FileLoading extends FileState {}

/// State representing a successfully loaded file, containing the file data and path.
class FileLoaded extends FileState {
  final MasoFile masoFile; // The loaded MasoFile object

  FileLoaded(this.masoFile);
}

/// State representing a successfully exported file, containing the file data and path.
class FileExported extends FileState {
  final ExportFormats fileFormat;
  FileExported(this.fileFormat);
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
      case FileErrorType.errorSavingMasoFile:
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

  /// There was an error while trying to save the Maso file.
  errorSavingMasoFile,

  /// There was an error while trying to save the exported file.
  errorSavingExportedFile,

  /// There was an error while trying to pick the file.
  errorPickingFileManually,
}
