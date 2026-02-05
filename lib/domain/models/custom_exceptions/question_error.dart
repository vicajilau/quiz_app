import 'package:flutter/material.dart';
import 'package:quiz_app/domain/models/custom_exceptions/question_error_type.dart';
import 'package:quiz_app/domain/models/custom_exceptions/process_error.dart';

class QuestionError implements ProcessError {
  final QuestionErrorType errorType;
  final Object? param1;
  final Object? param2;
  final Object? param3;
  @override
  final bool success;

  QuestionError({
    required this.errorType,
    this.param1,
    this.param2,
    this.param3,
    this.success = false,
  });

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
