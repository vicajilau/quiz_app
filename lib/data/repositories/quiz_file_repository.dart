import 'package:uuid/uuid.dart';
import 'package:quiz_app/core/debug_print.dart';
import 'package:quiz_app/core/service_locator.dart';
import 'package:quiz_app/data/services/file_service/i_file_service.dart';

import 'package:quiz_app/domain/models/quiz/quiz_file.dart';
import 'package:quiz_app/domain/models/quiz/quiz_metadata.dart';

/// The `QuizFileRepository` class manages file-related operations such as loading, saving,
/// and selecting quiz files. It delegates these tasks to an instance of `FileService`.
class QuizFileRepository {
  /// Instance of `IFileService` to handle file operations.
  final IFileService _fileService;

  /// Constructor to initialize `QuizFileRepository` with a `FileService` instance.
  /// This allows for the delegation of file-related tasks.
  ///
  /// - [fileService]: The `FileService` instance that handles file operations.
  QuizFileRepository({required IFileService fileService})
    : _fileService = fileService;

  /// Loads a `QuizFile` from a file at the specified [filePath].
  /// This method calls `readQuizFile` from `QuizFileService` to read the file,
  /// and then registers the loaded file in the service locator.
  /// If the quiz file doesn't have an ID, one is generated for tracking purposes.
  ///
  /// - [filePath]: The path to the file to load.
  /// - Returns: A `Future<QuizFile>` containing the loaded `QuizFile`.
  /// - Throws: An exception if there is an error loading the file.
  Future<QuizFile> loadQuizFile(String filePath) async {
    var quizFile = await _fileService.readQuizFile(filePath);

    // Generate UUID if quiz doesn't have one (migration for old files)
    if (quizFile.metadata.id == null) {
      final newMetadata = quizFile.metadata.copyWith(id: const Uuid().v4());
      quizFile = quizFile.copyWith(metadata: newMetadata);
      printInDebug('Generated new UUID for quiz: ${newMetadata.id}');
    }

    ServiceLocator.instance.registerQuizFile(quizFile);
    return quizFile;
  }

  /// Creates a new `QuizFile` with the specified metadata.
  /// The method generates a new `QuizFile` with the provided metadata and a unique ID.
  ///
  /// - [title]: The title for the new `QuizFile`.
  /// - [description]: The description for the new `QuizFile`.
  /// - [version]: The version for the new `QuizFile`.
  /// - [author]: The author for the new `QuizFile`.
  /// - Returns: A `Future<QuizFile>` containing the created `QuizFile`.
  Future<QuizFile> createQuizFile({
    required String title,
    required String description,
    required String version,
    required String author,
  }) async {
    final metadata = QuizMetadata(
      id: const Uuid().v4(), // Generate unique ID for new quiz
      title: title,
      description: description,
      version: version,
      author: author,
    );

    final quizFile = QuizFile(
      metadata: metadata,
      questions: [], // Start with empty questions
    );

    ServiceLocator.instance.registerQuizFile(quizFile);
    return quizFile;
  }

  /// Saves a `QuizFile` to the file system.
  /// This method calls `saveQuizFile` from `QuizFileService` to save the file.
  ///
  /// - [quizFile]: The `QuizFile` to save.
  /// - [dialogTitle]: The title for the save dialog.
  /// - [fileName]: The name of the file.
  /// - Returns: A `Future<QuizFile?>` containing the saved `QuizFile` with updated path, or `null` if cancelled.
  Future<QuizFile?> saveQuizFile(
    QuizFile quizFile,
    String dialogTitle,
    String fileName,
  ) async {
    final savedFile = await _fileService.saveQuizFile(
      quizFile,
      dialogTitle,
      fileName,
    );
    if (savedFile != null) {
      ServiceLocator.instance.registerQuizFile(savedFile);
    }
    return savedFile;
  }

  /// Opens a file picker for the user to select a quiz file.
  /// This method calls `pickFile` from `QuizFileService` to open the file picker.
  /// If the quiz file doesn't have an ID, one is generated for tracking purposes.
  ///
  /// - Returns: A `Future<QuizFile?>` containing the selected `QuizFile`, or `null` if no file is selected.
  Future<QuizFile?> pickFile() async {
    var quizFile = await _fileService.pickFile();
    if (quizFile != null) {
      // Generate UUID if quiz doesn't have one (migration for old files)
      if (quizFile.metadata.id == null) {
        final newMetadata = quizFile.metadata.copyWith(id: const Uuid().v4());
        quizFile = quizFile.copyWith(metadata: newMetadata);
        printInDebug('Generated new UUID for picked quiz: ${newMetadata.id}');
      }
      ServiceLocator.instance.registerQuizFile(quizFile);
    }
    return quizFile;
  }

  /// Picks a file manually using the file picker dialog.
  /// This method delegates the task of selecting a file to the `_fileService`'s
  /// `pickFile` method, and registers the selected file in the service locator.
  /// If the quiz file doesn't have an ID, one is generated for tracking purposes.
  ///
  /// - Returns: A `Future<QuizFile?>` containing the selected `QuizFile`, or `null` if no file was selected.
  Future<QuizFile?> pickFileManually() async {
    var quizFile = await _fileService.pickFile();
    if (quizFile != null) {
      // Generate UUID if quiz doesn't have one (migration for old files)
      if (quizFile.metadata.id == null) {
        final newMetadata = quizFile.metadata.copyWith(id: const Uuid().v4());
        quizFile = quizFile.copyWith(metadata: newMetadata);
        printInDebug('Generated new UUID for picked quiz: ${newMetadata.id}');
      }
      ServiceLocator.instance.registerQuizFile(quizFile);
    }
    return quizFile;
  }

  /// Checks if a `QuizFile` has changed by comparing the current file content
  /// with the cached version of the file. This method reads the original file
  /// content from [filePath] and compares it with the [cachedQuizFile].
  ///
  /// - [filePath]: The path to the file to check.
  /// - [cachedQuizFile]: The cached version of the `QuizFile` for comparison.
  /// - Returns: A `Future<bool>` indicating whether the file content has changed (`true`) or not (`false`).
  bool hasQuizFileChanged(QuizFile cachedQuizFile) {
    if (cachedQuizFile.filePath == null) return true;

    final originalFile = _fileService.originalFile;
    if (originalFile == null) return true;

    final hasChanged = originalFile != cachedQuizFile;
    printInDebug(
      'File changed: $hasChanged (Original questions: ${originalFile.questions.length}, Cached questions: ${cachedQuizFile.questions.length})',
    );

    return hasChanged;
  }
}
