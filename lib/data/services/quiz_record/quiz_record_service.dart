import 'package:quiz_app/domain/models/history/quiz_record.dart';
import 'package:quiz_app/domain/models/history/quiz_mode.dart';
import 'package:quiz_app/domain/models/history/question_result.dart';

/// Abstract interface for quiz record persistence operations.
/// Follows clean architecture principles for testability and flexibility.
abstract class QuizRecordService {
  /// Initializes the service. Must be called before any other operations.
  Future<void> initialize();

  /// Closes the service and releases resources.
  Future<void> close();

  // ============ CRUD Operations ============

  /// Saves a quiz record to storage.
  /// Returns the saved record.
  Future<QuizRecord> saveRecord(QuizRecord record);

  /// Retrieves a quiz record by its unique ID.
  /// Returns null if not found.
  Future<QuizRecord?> getRecordById(String id);

  /// Retrieves all quiz records.
  /// Ordered by completedAt descending (most recent first).
  Future<List<QuizRecord>> getAllRecords();

  /// Deletes a quiz record by its ID.
  /// Returns true if deleted, false if not found.
  Future<bool> deleteRecord(String id);

  /// Deletes all records for a specific quiz.
  /// Returns the number of deleted records.
  Future<int> deleteRecordsForQuiz(String quizId);

  /// Clears all quiz history.
  Future<void> clearAllHistory();

  // ============ Query Operations ============

  /// Retrieves all records for a specific quiz.
  /// Ordered by completedAt descending.
  Future<List<QuizRecord>> getRecordsByQuizId(String quizId);

  /// Retrieves records within a date range.
  Future<List<QuizRecord>> getRecordsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Retrieves records with score at or above the threshold.
  Future<List<QuizRecord>> getRecordsByMinScore(double minScore);

  /// Retrieves records with score at or below the threshold.
  Future<List<QuizRecord>> getRecordsByMaxScore(double maxScore);

  /// Retrieves records by quiz mode.
  Future<List<QuizRecord>> getRecordsByMode(QuizMode mode);

  /// Retrieves the most recent N records.
  Future<List<QuizRecord>> getRecentRecords(int limit);

  // ============ Aggregation & Statistics ============

  /// Gets the count of records for a specific quiz.
  Future<int> getRecordCountForQuiz(String quizId);

  /// Gets the total count of all records.
  Future<int> getTotalRecordCount();

  /// Gets the average score for a specific quiz.
  /// Returns null if no records exist.
  Future<double?> getAverageScoreForQuiz(String quizId);

  /// Gets the best score for a specific quiz.
  /// Returns null if no records exist.
  Future<double?> getBestScoreForQuiz(String quizId);

  /// Gets unique quiz IDs that have been attempted.
  Future<List<String>> getAttemptedQuizIds();

  // ============ Question-Level Analytics ============

  /// Gets the most failed questions for a quiz.
  /// Returns questions sorted by failure rate (highest first).
  Future<List<QuestionFailureStat>> getMostFailedQuestions(
    String quizId, {
    int limit = 10,
  });

  /// Gets statistics for a specific question in a quiz.
  /// Returns null if no data exists for this question.
  Future<QuestionFailureStat?> getQuestionStats(
    String quizId,
    String questionHash,
  );
}
