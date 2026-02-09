import 'package:hive_ce/hive.dart';
import 'package:quiz_app/data/services/quiz_record/quiz_record_service.dart';
import 'package:quiz_app/domain/models/history/quiz_record.dart';
import 'package:quiz_app/domain/models/history/quiz_mode.dart';
import 'package:quiz_app/domain/models/history/question_result.dart';

/// Hive-based implementation of QuizRecordService.
class HiveQuizRecordService implements QuizRecordService {
  static const String _boxName = 'quiz_records';

  Box<QuizRecord>? _box;

  Box<QuizRecord> get _recordsBox {
    if (_box == null || !_box!.isOpen) {
      throw StateError(
        'QuizRecordService not initialized. Call initialize() first.',
      );
    }
    return _box!;
  }

  @override
  Future<void> initialize() async {
    if (_box != null && _box!.isOpen) return;
    _box = await Hive.openBox<QuizRecord>(_boxName);
  }

  @override
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }

  // ============ CRUD Operations ============

  @override
  Future<QuizRecord> saveRecord(QuizRecord record) async {
    await _recordsBox.put(record.id, record);
    return record;
  }

  @override
  Future<QuizRecord?> getRecordById(String id) async {
    return _recordsBox.get(id);
  }

  @override
  Future<List<QuizRecord>> getAllRecords() async {
    final records = _recordsBox.values.toList();
    records.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return records;
  }

  @override
  Future<bool> deleteRecord(String id) async {
    if (_recordsBox.containsKey(id)) {
      await _recordsBox.delete(id);
      return true;
    }
    return false;
  }

  @override
  Future<int> deleteRecordsForQuiz(String quizId) async {
    final keysToDelete =
        _recordsBox.keys
            .where((key) => _recordsBox.get(key)?.quizId == quizId)
            .toList();
    await _recordsBox.deleteAll(keysToDelete);
    return keysToDelete.length;
  }

  @override
  Future<void> clearAllHistory() async {
    await _recordsBox.clear();
  }

  // ============ Query Operations ============

  @override
  Future<List<QuizRecord>> getRecordsByQuizId(String quizId) async {
    final records =
        _recordsBox.values.where((record) => record.quizId == quizId).toList();
    records.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return records;
  }

  @override
  Future<List<QuizRecord>> getRecordsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final records =
        _recordsBox.values.where((record) {
          return record.completedAt.isAfter(startDate) &&
              record.completedAt.isBefore(endDate.add(const Duration(days: 1)));
        }).toList();
    records.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return records;
  }

  @override
  Future<List<QuizRecord>> getRecordsByMinScore(double minScore) async {
    final records =
        _recordsBox.values.where((record) => record.score >= minScore).toList();
    records.sort((a, b) => b.score.compareTo(a.score));
    return records;
  }

  @override
  Future<List<QuizRecord>> getRecordsByMaxScore(double maxScore) async {
    final records =
        _recordsBox.values.where((record) => record.score <= maxScore).toList();
    records.sort((a, b) => a.score.compareTo(b.score));
    return records;
  }

  @override
  Future<List<QuizRecord>> getRecordsByMode(QuizMode mode) async {
    final records =
        _recordsBox.values.where((record) => record.mode == mode).toList();
    records.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return records;
  }

  @override
  Future<List<QuizRecord>> getRecentRecords(int limit) async {
    final records = _recordsBox.values.toList();
    records.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return records.take(limit).toList();
  }

  // ============ Aggregation & Statistics ============

  @override
  Future<int> getRecordCountForQuiz(String quizId) async {
    return _recordsBox.values.where((record) => record.quizId == quizId).length;
  }

  @override
  Future<int> getTotalRecordCount() async {
    return _recordsBox.length;
  }

  @override
  Future<double?> getAverageScoreForQuiz(String quizId) async {
    final records =
        _recordsBox.values.where((record) => record.quizId == quizId).toList();
    if (records.isEmpty) return null;
    final totalScore = records.fold<double>(0, (sum, r) => sum + r.score);
    return totalScore / records.length;
  }

  @override
  Future<double?> getBestScoreForQuiz(String quizId) async {
    final records =
        _recordsBox.values.where((record) => record.quizId == quizId).toList();
    if (records.isEmpty) return null;
    return records.map((r) => r.score).reduce((a, b) => a > b ? a : b);
  }

  @override
  Future<List<String>> getAttemptedQuizIds() async {
    return _recordsBox.values.map((record) => record.quizId).toSet().toList();
  }

  // ============ Question-Level Analytics ============

  @override
  Future<List<QuestionFailureStat>> getMostFailedQuestions(
    String quizId, {
    int limit = 10,
  }) async {
    final records = await getRecordsByQuizId(quizId);

    // Aggregate failures by question hash
    final Map<String, QuestionFailureStat> stats = {};

    for (final record in records) {
      for (final qr in record.questionResults) {
        final key = qr.questionHash;
        stats.putIfAbsent(
          key,
          () => QuestionFailureStat(
            questionHash: qr.questionHash,
            questionText: qr.questionText,
          ),
        );
        stats[key]!.totalAttempts++;
        if (!qr.isCorrect) stats[key]!.failureCount++;
      }
    }

    // Sort by failure rate descending
    final sorted =
        stats.values.toList()
          ..sort((a, b) => b.failureRate.compareTo(a.failureRate));

    return sorted.take(limit).toList();
  }

  @override
  Future<QuestionFailureStat?> getQuestionStats(
    String quizId,
    String questionHash,
  ) async {
    final records = await getRecordsByQuizId(quizId);

    QuestionFailureStat? stat;

    for (final record in records) {
      for (final qr in record.questionResults) {
        if (qr.questionHash == questionHash) {
          stat ??= QuestionFailureStat(
            questionHash: qr.questionHash,
            questionText: qr.questionText,
          );
          stat.totalAttempts++;
          if (!qr.isCorrect) stat.failureCount++;
        }
      }
    }

    return stat;
  }
}
