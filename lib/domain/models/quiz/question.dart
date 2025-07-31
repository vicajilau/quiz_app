/// Represents a question in a quiz.
class Question {
  /// The type of the question (e.g., "multiple_choice").
  final String type;

  /// The text of the question.
  final String text;

  /// Optional image for the question in base64 format: data:image/[type];base64,[data]
  final String? image;

  /// The list of possible options for the question.
  final List<String> options;

  /// The list of indices of correct answers.
  final List<int> correctAnswers;

  /// The explanation for the correct answer(s).
  final String explanation;

  /// Constructor for creating a `Question` instance.
  const Question({
    required this.type,
    required this.text,
    this.image,
    required this.options,
    required this.correctAnswers,
    required this.explanation,
  });

  /// Creates a `Question` instance from a JSON map.
  ///
  /// - [json]: The JSON map containing the question data.
  /// - Returns: A `Question` instance populated with the data from the JSON.
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      type: json['type'] ?? 'multiple_choice',
      text: json['text'] ?? '',
      image: json['image'],
      options: List<String>.from(json['options'] ?? []),
      correctAnswers: List<int>.from(json['correct_answers'] ?? []),
      explanation: json['explanation'] ?? '',
    );
  }

  /// Converts the `Question` instance to a JSON map.
  ///
  /// - Returns: A JSON map representation of the question.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'type': type,
      'text': text,
      'options': options,
      'correct_answers': correctAnswers,
      'explanation': explanation,
    };

    if (image != null) {
      json['image'] = image;
    }

    return json;
  }

  /// Creates a copy of the `Question` with optional parameter modifications.
  ///
  /// - [type]: New type to replace the current one.
  /// - [text]: New text to replace the current one.
  /// - [image]: New image to replace the current one.
  /// - [options]: New options to replace the current ones.
  /// - [correctAnswers]: New correct answers to replace the current ones.
  /// - [explanation]: New explanation to replace the current one.
  /// - Returns: A new `Question` instance with the specified modifications.
  Question copyWith({
    String? type,
    String? text,
    String? image,
    List<String>? options,
    List<int>? correctAnswers,
    String? explanation,
  }) {
    return Question(
      type: type ?? this.type,
      text: text ?? this.text,
      image: image ?? this.image,
      options: options ?? this.options,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      explanation: explanation ?? this.explanation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Question &&
        other.type == type &&
        other.text == text &&
        other.image == image &&
        other.explanation == explanation &&
        _listEquals(other.options, options) &&
        _listEquals(other.correctAnswers, correctAnswers);
  }

  @override
  int get hashCode {
    if (image == null) {
      return type.hashCode ^
          text.hashCode ^
          options.hashCode ^
          correctAnswers.hashCode ^
          explanation.hashCode;
    }
    return type.hashCode ^
        text.hashCode ^
        image.hashCode ^
        options.hashCode ^
        correctAnswers.hashCode ^
        explanation.hashCode;
  }

  /// Helper method to compare two lists for equality.
  bool _listEquals<Question>(List<Question>? a, List<Question>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return a == b;
  }

  @override
  String toString() {
    return 'Question(type: $type, text: $text, image: $image, options: $options, correctAnswers: $correctAnswers, explanation: $explanation)';
  }
}
