import 'bad_quiz_file_error_type.dart';

/// Exception thrown when there are issues with a Quiz file.
class BadQuizFileException implements Exception {
  /// The type of error that occurred.
  final BadQuizFileErrorType type;

  /// Additional error message providing more details.
  final String? message;

  /// Constructor for creating a `BadQuizFileException`.
  ///
  /// - [type]: The type of error that occurred.
  /// - [message]: Optional additional error message.
  const BadQuizFileException({required this.type, this.message});

  @override
  String toString() {
    String baseMessage;
    switch (type) {
      case BadQuizFileErrorType.invalidExtension:
        baseMessage =
            'Invalid file extension. The file must have a .quiz extension.';
        break;
      case BadQuizFileErrorType.invalidFormat:
        baseMessage =
            'Invalid Quiz file format. The file structure is incorrect.';
        break;
      case BadQuizFileErrorType.unsupportedVersion:
        baseMessage = 'Unsupported Quiz file version.';
        break;
      case BadQuizFileErrorType.invalidQuestionData:
        baseMessage = 'Invalid question data in the Quiz file.';
        break;
    }

    if (message != null) {
      return '$baseMessage Details: $message';
    }
    return baseMessage;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BadQuizFileException &&
        other.type == type &&
        other.message == message;
  }

  @override
  int get hashCode => type.hashCode ^ message.hashCode;
}
