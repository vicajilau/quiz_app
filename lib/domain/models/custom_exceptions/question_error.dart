import 'package:flutter/material.dart';
import 'package:quiz_app/domain/models/custom_exceptions/question_error_type.dart';
import 'package:quiz_app/domain/models/custom_exceptions/process_error.dart';

/// Implementation of [ProcessError] for question-specific validation issues.
class QuestionError implements ProcessError {
  /// The specific category of the error.
  final QuestionErrorType errorType;

  /// Optional parameters to provide context for the error message.
  final Object? param1;

  /// Optional parameters to provide context for the error message.
  final Object? param2;

  /// Optional parameters to provide context for the error message.
  final Object? param3;

  @override
  final bool success;

  /// Creates a [QuestionError] with the specified [errorType] and metadata.
  QuestionError({
    required this.errorType,
    this.param1,
    this.param2,
    this.param3,
    this.success = false,
  });

  /// Creates a successful [QuestionError] instance.
  QuestionError.success()
    : this(success: true, errorType: QuestionErrorType.emptyText);

  @override
  String getDescriptionForInputError(BuildContext context) {
    switch (errorType) {
      case QuestionErrorType.emptyText:
        return 'Question text cannot be empty';
      case QuestionErrorType.duplicatedText:
        return 'Question text already exists';
      case QuestionErrorType.insufficientOptions:
        return 'Question must have at least 2 options';
      case QuestionErrorType.invalidCorrectAnswers:
        return 'Invalid correct answer indices';
      case QuestionErrorType.emptyOption:
        return 'Option text cannot be empty';
    }
  }

  @override
  String getDescriptionForFileError(BuildContext context) {
    return getDescriptionForInputError(context);
  }
}
