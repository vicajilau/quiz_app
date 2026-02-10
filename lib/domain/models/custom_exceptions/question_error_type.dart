/// Types of validation errors that can occur within a question.
enum QuestionErrorType {
  /// The question text is empty or only contains whitespace.
  emptyText,

  /// The question text is exactly the same as another question's text.
  duplicatedText,

  /// The question does not have enough options to be valid.
  insufficientOptions,

  /// The selected correct answer indices are out of range or inconsistent.
  invalidCorrectAnswers,

  /// One or more option texts are empty.
  emptyOption,
}
