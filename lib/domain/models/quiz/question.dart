/// Represents a question in a quiz.
class Question {
  /// The type of the question (e.g., "multiple_choice").
  final String type;

  /// The text of the question.
  final String text;

  /// The list of possible options for the question.
  final List<String> options;

  /// The list of indices of correct answers.
  final List<int> correctAnswers;

  /// Constructor for creating a `Question` instance.
  const Question({
    required this.type,
    required this.text,
    required this.options,
    required this.correctAnswers,
  });

  /// Creates a `Question` instance from a JSON map.
  ///
  /// - [json]: The JSON map containing the question data.
  /// - Returns: A `Question` instance populated with the data from the JSON.
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      type: json['type'] ?? 'multiple_choice',
      text: json['text'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswers: List<int>.from(json['correct_answers'] ?? []),
    );
  }

  /// Converts the `Question` instance to a JSON map.
  ///
  /// - Returns: A JSON map representation of the question.
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
      'options': options,
      'correct_answers': correctAnswers,
    };
  }

  /// Creates a copy of the `Question` with optional parameter modifications.
  ///
  /// - [type]: New type to replace the current one.
  /// - [text]: New text to replace the current one.
  /// - [options]: New options to replace the current ones.
  /// - [correctAnswers]: New correct answers to replace the current ones.
  /// - Returns: A new `Question` instance with the specified modifications.
  Question copyWith({
    String? type,
    String? text,
    List<String>? options,
    List<int>? correctAnswers,
  }) {
    return Question(
      type: type ?? this.type,
      text: text ?? this.text,
      options: options ?? this.options,
      correctAnswers: correctAnswers ?? this.correctAnswers,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Question &&
        other.type == type &&
        other.text == text &&
        _listEquals(other.options, options) &&
        _listEquals(other.correctAnswers, correctAnswers);
  }

  @override
  int get hashCode {
    return type.hashCode ^
        text.hashCode ^
        options.hashCode ^
        correctAnswers.hashCode;
  }

  /// Helper method to compare two lists for equality.
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'Question(type: $type, text: $text, options: $options, correctAnswers: $correctAnswers)';
  }
}
