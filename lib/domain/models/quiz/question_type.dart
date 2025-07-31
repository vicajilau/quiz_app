/// Enumeration representing the different types of questions available in a quiz.
enum QuestionType {
  /// Multiple choice question where multiple answers can be selected.
  multipleChoice('multiple_choice'),

  /// Single choice question where only one answer can be selected.
  singleChoice('single_choice'),

  /// True or false question.
  trueFalse('true_false'),

  /// Essay question requiring a written response.
  essay('essay');

  const QuestionType(this.value);

  /// The string value used for serialization/deserialization.
  final String value;

  /// Creates a QuestionType from a string value.
  ///
  /// Returns [QuestionType.multipleChoice] as default if the value is not recognized.
  static QuestionType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'multiple_choice':
        return QuestionType.multipleChoice;
      case 'single_choice':
        return QuestionType.singleChoice;
      case 'true_false':
        return QuestionType.trueFalse;
      case 'essay':
        return QuestionType.essay;
      default:
        return QuestionType.multipleChoice; // Default fallback
    }
  }

  /// Converts the QuestionType to its string representation for serialization.
  String toJson() => value;

  @override
  String toString() => value;
}
