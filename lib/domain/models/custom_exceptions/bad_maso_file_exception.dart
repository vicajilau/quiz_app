import 'package:flutter/material.dart';
import 'package:quiz_app/domain/models/custom_exceptions/regular_process_error.dart';

import '../../../core/l10n/app_localizations.dart';
import 'bad_maso_file_error_type.dart';
import 'burst_process_error.dart';

/// Exception class for errors related to MASO file processing.
class BadMasoFileException implements Exception {
  /// The specific type of error that occurred.
  final BadMasoFileErrorType? type;
  final RegularProcessError? regularProcessError;
  final BurstProcessError? burstProcessError;

  /// Creates a new `BadMasoFileException` with the given error type.
  BadMasoFileException({
    this.type,
    this.regularProcessError,
    this.burstProcessError,
  }) : assert(
         type != null ||
             regularProcessError != null ||
             burstProcessError != null,
       );

  /// Returns a localized description of the error based on the current app language.
  ///
  /// Uses `AppLocalizations` to provide error messages in the appropriate language.
  ///
  /// Example usage:
  /// ```dart
  /// try {
  ///   throw BadMasoFileException(BadMasoFileErrorType.unsupportedVersion);
  /// } catch (e) {
  ///   if (e is BadMasoFileException) {
  ///     print(e.description(context)); // Localized error message
  ///   }
  /// }
  /// ```
  ///
  /// - `metadataBadContent`: The file metadata is invalid or corrupted.
  /// - `processesBadContent`: The process list contains invalid data.
  /// - `unsupportedVersion`: The file version is not supported by the current app.
  /// - `invalidExtension`: The file does not have a valid `.maso` extension.
  String description(BuildContext context) {
    if (regularProcessError != null) {
      return regularProcessError!.getDescriptionForFileError(context);
    } else if (burstProcessError != null) {
      return burstProcessError!.getDescriptionForFileError(context);
    }

    switch (type) {
      case BadMasoFileErrorType.metadataBadContent:
        return AppLocalizations.of(context)!.metadataBadContent;
      case BadMasoFileErrorType.processesBadContent:
        return AppLocalizations.of(context)!.processesBadContent;
      case BadMasoFileErrorType.unsupportedVersion:
        return AppLocalizations.of(context)!.unsupportedVersion;
      case BadMasoFileErrorType.invalidExtension:
        return AppLocalizations.of(context)!.invalidExtension;
      case null:
        throw UnimplementedError();
    }
  }

  @override
  String toString() => "BadMasoFileException: $type";
}
