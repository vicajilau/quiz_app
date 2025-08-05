import 'question_type.dart';
import '../../../core/constants/question_constants.dart';

/// Represents a question in a quiz.
class Question {
  /// The type of the question.
  final QuestionType type;

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

  /// Whether this question is enabled/active or disabled.
  final bool isEnabled;

  /// Constructor for creating a `Question` instance.
  const Question({
    required this.type,
    required this.text,
    this.image,
    required this.options,
    required this.correctAnswers,
    required this.explanation,
    this.isEnabled = true,
  });

  /// Creates a `Question` instance from a JSON map.
  ///
  /// - [json]: The JSON map containing the question data.
  /// - Returns: A `Question` instance populated with the data from the JSON.
  factory Question.fromJson(Map<String, dynamic> json) {
    final questionType = QuestionType.fromString(
      json['type'] ?? 'multiple_choice',
    );

    // Handle options
    List<String> options = [];
    if (json['options'] != null) {
      options = List<String>.from(json['options']);
    } else if (questionType == QuestionType.trueFalse) {
      // For true/false questions without options, create default options
      options = QuestionConstants.defaultTrueFalseOptions;
    }

    // Handle correct answers
    List<int> correctAnswers = [];
    if (json['correct_answers'] != null) {
      final correctAnswersJson = json['correct_answers'] as List;

      if (questionType == QuestionType.trueFalse &&
          correctAnswersJson.isNotEmpty) {
        // Handle boolean values in true/false questions
        if (correctAnswersJson.first is bool) {
          correctAnswers = [correctAnswersJson.first == true ? 0 : 1];
        } else {
          correctAnswers = List<int>.from(correctAnswersJson);
        }
      } else {
        correctAnswers = List<int>.from(correctAnswersJson);
      }
    }

    return Question(
      type: questionType,
      text: json['text'] ?? '',
      image: json['image'],
      options: options,
      correctAnswers: correctAnswers,
      explanation: json['explanation'] ?? '',
      isEnabled: json['isEnabled'] ?? true,
    );
  }

  /// Converts the `Question` instance to a JSON map.
  ///
  /// - Returns: A JSON map representation of the question.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'type': type.toJson(),
      'text': text,
      'options': options,
      'correct_answers': correctAnswers,
      'explanation': explanation,
      'isEnabled': isEnabled,
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
  /// - [options]: New options list to replace the current one.
  /// - [correctAnswers]: New correct answers list to replace the current one.
  /// - [explanation]: New explanation to replace the current one.
  /// - [isEnabled]: New enabled state to replace the current one.
  /// - Returns: A new `Question` instance with the specified modifications.
  Question copyWith({
    QuestionType? type,
    String? text,
    String? image,
    List<String>? options,
    List<int>? correctAnswers,
    String? explanation,
    bool? isEnabled,
  }) {
    return Question(
      type: type ?? this.type,
      text: text ?? this.text,
      image: image ?? this.image,
      options: options ?? this.options,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      explanation: explanation ?? this.explanation,
      isEnabled: isEnabled ?? this.isEnabled,
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
        other.isEnabled == isEnabled &&
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
          explanation.hashCode ^
          isEnabled.hashCode;
    }
    return type.hashCode ^
        text.hashCode ^
        image.hashCode ^
        options.hashCode ^
        correctAnswers.hashCode ^
        explanation.hashCode ^
        isEnabled.hashCode;
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
    return 'Question(type: ${type.value}, text: $text, image: $image, options: $options, correctAnswers: $correctAnswers, explanation: $explanation, isEnabled: $isEnabled)';
  }
}
