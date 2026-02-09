import 'dart:convert';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:quiz_app/domain/models/history/quiz_mode.dart';
import 'package:quiz_app/domain/models/history/question_result.dart';

/// Represents a single quiz attempt/record with all relevant data.
class QuizRecord extends HiveObject {
  /// Unique identifier for this record (UUID).
  final String id;

  /// Identifier for the quiz (UUID from quiz metadata).
  final String quizId;

  /// Title of the quiz for display purposes.
  final String quizTitle;

  /// Version of the quiz when taken.
  final String quizVersion;

  /// Author of the quiz.
  final String? quizAuthor;

  /// Timestamp when the quiz was started.
  final DateTime startedAt;

  /// Timestamp when the quiz was completed.
  final DateTime completedAt;

  /// Per-question results stored as JSON string.
  final String questionResultsJson;

  /// Essay answers stored as JSON string (questionIndex -> answer text).
  final String essayAnswersJson;

  /// Number of correct answers.
  final int correctCount;

  /// Total number of questions in the quiz.
  final int totalQuestions;

  /// Score as a percentage (0-100).
  final double score;

  /// The mode in which the quiz was taken.
  final QuizMode mode;

  QuizRecord({
    required this.id,
    required this.quizId,
    required this.quizTitle,
    required this.quizVersion,
    this.quizAuthor,
    required this.startedAt,
    required this.completedAt,
    required this.questionResultsJson,
    required this.essayAnswersJson,
    required this.correctCount,
    required this.totalQuestions,
    required this.score,
    required this.mode,
  });

  /// Creates a QuizRecord from quiz completion data.
  factory QuizRecord.fromQuizCompletion({
    required String quizId,
    required String quizTitle,
    required String quizVersion,
    String? quizAuthor,
    required DateTime startedAt,
    required List<QuestionResult> questionResults,
    required Map<int, String> essayAnswers,
    required int correctCount,
    required int totalQuestions,
    required double score,
    required bool isStudyMode,
  }) {
    return QuizRecord(
      id: const Uuid().v4(),
      quizId: quizId,
      quizTitle: quizTitle,
      quizVersion: quizVersion,
      quizAuthor: quizAuthor,
      startedAt: startedAt,
      completedAt: DateTime.now(),
      questionResultsJson: QuestionResult.encodeList(questionResults),
      essayAnswersJson: _encodeEssayAnswers(essayAnswers),
      correctCount: correctCount,
      totalQuestions: totalQuestions,
      score: score,
      mode: QuizMode.fromBool(isStudyMode),
    );
  }

  /// Decodes question results from JSON string.
  List<QuestionResult> get questionResults =>
      QuestionResult.decodeList(questionResultsJson);

  /// Decodes essay answers from JSON string.
  Map<int, String> get essayAnswers => _decodeEssayAnswers(essayAnswersJson);

  /// Duration of the quiz attempt.
  Duration get duration => completedAt.difference(startedAt);

  /// Whether the quiz was passed (score >= 50%).
  bool get passed => score >= 50.0;

  static String _encodeEssayAnswers(Map<int, String> answers) {
    return jsonEncode(answers.map((k, v) => MapEntry(k.toString(), v)));
  }

  static Map<int, String> _decodeEssayAnswers(String json) {
    if (json.isEmpty || json == '{}') return {};
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(int.parse(k), v as String));
  }

  @override
  String toString() {
    return 'QuizRecord(id: $id, quizTitle: $quizTitle, score: ${score.toStringAsFixed(1)}%, mode: $mode)';
  }
}

/// Hive TypeAdapter for QuizRecord.
class QuizRecordAdapter extends TypeAdapter<QuizRecord> {
  @override
  final int typeId = 1;

  @override
  QuizRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizRecord(
      id: fields[0] as String,
      quizId: fields[1] as String,
      quizTitle: fields[2] as String,
      quizVersion: fields[3] as String,
      quizAuthor: fields[4] as String?,
      startedAt: fields[5] as DateTime,
      completedAt: fields[6] as DateTime,
      questionResultsJson: fields[7] as String,
      essayAnswersJson: fields[8] as String,
      correctCount: fields[9] as int,
      totalQuestions: fields[10] as int,
      score: fields[11] as double,
      mode: fields[12] as QuizMode,
    );
  }

  @override
  void write(BinaryWriter writer, QuizRecord obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.quizId)
      ..writeByte(2)
      ..write(obj.quizTitle)
      ..writeByte(3)
      ..write(obj.quizVersion)
      ..writeByte(4)
      ..write(obj.quizAuthor)
      ..writeByte(5)
      ..write(obj.startedAt)
      ..writeByte(6)
      ..write(obj.completedAt)
      ..writeByte(7)
      ..write(obj.questionResultsJson)
      ..writeByte(8)
      ..write(obj.essayAnswersJson)
      ..writeByte(9)
      ..write(obj.correctCount)
      ..writeByte(10)
      ..write(obj.totalQuestions)
      ..writeByte(11)
      ..write(obj.score)
      ..writeByte(12)
      ..write(obj.mode);
  }
}
