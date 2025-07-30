/// Enumeration representing different types of errors that can occur when processing a Quiz file.
enum BadQuizFileErrorType {
  /// Indicates that the extension file is not .quiz.
  invalidExtension,

  /// Indicates that the format of the Quiz file is invalid.
  invalidFormat,

  /// Indicates that the Quiz file version is not supported.
  unsupportedVersion,

  /// Indicates that the Quiz file contains invalid question data.
  invalidQuestionData,
}
