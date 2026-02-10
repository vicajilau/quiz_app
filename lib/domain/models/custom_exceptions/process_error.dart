import 'package:flutter/material.dart';

/// Interface defining error reporting capabilities for quiz-related processes.
abstract class ProcessError {
  /// Whether the operation that produced this error was successful.
  bool get success;

  /// Returns a descriptive error message suitable for direct input validation feedback.
  String getDescriptionForInputError(BuildContext context);

  /// Returns a descriptive error message suitable for file-wide validation reports.
  String getDescriptionForFileError(BuildContext context);
}
