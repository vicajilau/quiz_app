import 'package:flutter/foundation.dart';
import 'package:quiz_app/domain/models/custom_exceptions/bad_quiz_file_exception.dart';
import 'package:quiz_app/domain/models/custom_exceptions/bad_quiz_file_error_type.dart';
import 'package:quiz_app/domain/models/quiz/quiz_metadata.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';

/// The `QuizFile` class represents a Quiz file, which consists of metadata
/// and a list of questions. This class provides methods for deserialization,
/// validation, and modification of the Quiz file's contents.
class QuizFile {
  String? filePath;

  /// The metadata of the Quiz file.
  final QuizMetadata metadata;

  /// The questions described in the Quiz file.
  final List<Question> questions;

  /// Constructor for creating a `QuizFile` instance with metadata and questions.
  QuizFile({required this.metadata, required this.questions, this.filePath});

  /// Creates a `QuizFile` instance from a JSON map.
  ///
  /// - [json]: The JSON map containing the quiz file data.
  /// - [filePath]: Optional file path of the quiz file.
  /// - Returns: A `QuizFile` instance populated with the data from the JSON.
  /// - Throws: `BadQuizFileException` if the JSON structure is invalid.
  factory QuizFile.fromJson(Map<String, dynamic> json, {String? filePath}) {
    try {
      final metadata = QuizMetadata.fromJson(json['metadata'] ?? {});
      final questionsJson = json['questions'] as List<dynamic>? ?? [];
      final questions = questionsJson
          .map((questionJson) => Question.fromJson(questionJson))
          .toList();

      return QuizFile(
        metadata: metadata,
        questions: questions,
        filePath: filePath,
      );
    } catch (e) {
      throw BadQuizFileException(
        type: BadQuizFileErrorType.invalidFormat,
        message: 'Error parsing quiz file: $e',
      );
    }
  }

  /// Converts the `QuizFile` instance to a JSON map.
  ///
  /// - Returns: A JSON map representation of the quiz file.
  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata.toJson(),
      'questions': questions.map((question) => question.toJson()).toList(),
    };
  }

  /// Creates a copy of the `QuizFile` with optional parameter modifications.
  ///
  /// - [metadata]: New metadata to replace the current one.
  /// - [questions]: New questions list to replace the current one.
  /// - [filePath]: New file path to replace the current one.
  /// - Returns: A new `QuizFile` instance with the specified modifications.
  QuizFile copyWith({
    QuizMetadata? metadata,
    List<Question>? questions,
    String? filePath,
  }) {
    return QuizFile(
      metadata: metadata ?? this.metadata,
      questions: questions ?? this.questions,
      filePath: filePath ?? this.filePath,
    );
  }

  /// Creates a deep copy of the `QuizFile` with all nested objects copied.
  ///
  /// This method ensures that modifying the returned `QuizFile` will not
  /// affect the original instance, including its metadata and questions.
  ///
  /// - Returns: A new `QuizFile` instance with deep copies of all properties.
  QuizFile deepCopy() {
    return QuizFile(
      metadata: metadata.copyWith(),
      questions: questions.map((q) => q.copyWith()).toList(),
      filePath: filePath,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizFile &&
        other.metadata == metadata &&
        listEquals(other.questions, questions) &&
        other.filePath == filePath;
  }

  @override
  int get hashCode {
    return metadata.hashCode ^ Object.hashAll(questions) ^ filePath.hashCode;
  }

  @override
  String toString() {
    return 'QuizFile(metadata: $metadata, questions: ${questions.length}, filePath: $filePath)';
  }
}
