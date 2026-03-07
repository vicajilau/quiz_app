// Copyright (C) 2026 Víctor Carreras
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/foundation.dart';
import 'package:quizdy/domain/models/custom_exceptions/bad_quiz_file_exception.dart';
import 'package:quizdy/domain/models/custom_exceptions/bad_quiz_file_error_type.dart';
import 'package:quizdy/domain/models/quiz/quiz_metadata.dart';
import 'package:quizdy/domain/models/quiz/question.dart';
import 'package:quizdy/domain/models/quiz/study.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';

enum QuizMode { study, quiz }

/// The `QuizFile` class represents a Quiz file, which consists of metadata
/// and a list of questions. This class provides methods for deserialization,
/// validation, and modification of the Quiz file's contents.
class QuizFile {
  String? filePath;

  /// The metadata of the Quiz file.
  final QuizMetadata metadata;

  /// The questions described in the Quiz file.
  final List<Question> questions;

  /// The interactive study sequence content associated with the Quiz file.
  final Study? study;

  /// The original file associated with this quiz (in-memory only).
  final AiFileAttachment? fileAttachment;

  /// SHA-256 hash of the original file content, persisted in the `.quiz` file.
  final String? fileContentHash;

  /// The URI of the uploaded file in the AI service (e.g. Gemini File API).
  final String? fileUri;

  /// The expiration time of the uploaded file in the AI service.
  final DateTime? fileExpirationTime;

  /// Get generationMode from study
  AiGenerationMode? get generationMode => study?.generationMode;

  /// Get originalText from study
  String? get originalText => study?.originalText;

  /// Constructor for creating a `QuizFile` instance with metadata and questions.
  QuizFile({
    required this.metadata,
    required this.questions,
    this.study,
    this.filePath,
    this.fileAttachment,
    this.fileContentHash,
    this.fileUri,
    this.fileExpirationTime,
  });

  /// Creates a `QuizFile` instance from a JSON map.
  ///
  /// - [json]: The JSON map containing the quiz file data.
  /// - [filePath]: Optional file path of the quiz file.
  /// - Returns: A `QuizFile` instance populated with the data from the JSON.
  /// - Throws: `BadQuizFileException` if the JSON structure is invalid.
  factory QuizFile.fromJson(Map<String, dynamic> json, {String? filePath}) {
    try {
      final metadata = QuizMetadata.fromJson(json['metadata'] ?? {});
      final studyJson = json['study'] as Map<String, dynamic>?;
      final study = studyJson != null ? Study.fromJson(studyJson) : null;
      final questionsJson = json['questions'] as List<dynamic>? ?? [];
      final questions = questionsJson
          .map((questionJson) => Question.fromJson(questionJson))
          .toList();

      final fileContentHash = json['fileContentHash'] as String?;
      final fileUri = json['fileUri'] as String?;
      final fileExpirationTimeStr = json['fileExpirationTime'] as String?;
      final fileExpirationTime = fileExpirationTimeStr != null
          ? DateTime.parse(fileExpirationTimeStr)
          : null;

      return QuizFile(
        metadata: metadata,
        questions: questions,
        study: study,
        filePath: filePath,
        fileContentHash: fileContentHash,
        fileUri: fileUri,
        fileExpirationTime: fileExpirationTime,
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
      if (study != null) 'study': study!.toJson(),
      'questions': questions.map((question) => question.toJson()).toList(),
      if (fileContentHash != null) 'fileContentHash': fileContentHash,
      if (fileUri != null) 'fileUri': fileUri,
      if (fileExpirationTime != null)
        'fileExpirationTime': fileExpirationTime!.toIso8601String(),
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
    Study? study,
    String? filePath,
    AiFileAttachment? fileAttachment,
    String? fileContentHash,
    String? fileUri,
    DateTime? fileExpirationTime,
    // Note: generationMode and originalText are now part of study
  }) {
    return QuizFile(
      metadata: metadata ?? this.metadata,
      questions: questions ?? this.questions,
      study: study ?? this.study,
      filePath: filePath ?? this.filePath,
      fileAttachment: fileAttachment ?? this.fileAttachment,
      fileContentHash: fileContentHash ?? this.fileContentHash,
      fileUri: fileUri ?? this.fileUri,
      fileExpirationTime: fileExpirationTime ?? this.fileExpirationTime,
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
      study: study?.copyWith(),
      filePath: filePath,
      fileContentHash: fileContentHash,
      fileUri: fileUri,
      fileExpirationTime: fileExpirationTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizFile &&
        other.metadata == metadata &&
        listEquals(other.questions, questions) &&
        other.study == study &&
        other.filePath == filePath &&
        other.fileContentHash == fileContentHash &&
        other.fileUri == fileUri &&
        other.fileExpirationTime == fileExpirationTime;
  }

  @override
  int get hashCode {
    return metadata.hashCode ^
        Object.hashAll(questions) ^
        study.hashCode ^
        filePath.hashCode ^
        fileContentHash.hashCode ^
        fileUri.hashCode ^
        fileExpirationTime.hashCode;
  }

  @override
  String toString() {
    return 'QuizFile(metadata: $metadata, questions: ${questions.length}, study: ${study != null ? "Present" : "None"}, filePath: $filePath, generationMode: $generationMode)';
  }
}
