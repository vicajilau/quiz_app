import 'dart:typed_data';

import 'package:quiz_app/core/debug_print.dart';
import 'package:quiz_app/core/service_locator.dart';

import '../../domain/models/quiz/quiz_file.dart';
import '../../domain/models/quiz/quiz_metadata.dart';
import '../services/file_service/i_quiz_file_service.dart';

/// The `QuizFileRepository` class manages file-related operations such as loading, saving,
/// and selecting quiz files. It delegates these tasks to an instance of `QuizFileService`.
class QuizFileRepository {
  /// Instance of `IQuizFileService` to handle file operations.
  final IQuizFileService _fileService;

  /// Constructor to initialize `QuizFileRepository` with a `QuizFileService` instance.
  /// This allows for the delegation of file-related tasks.
  ///
  /// - [fileService]: The `QuizFileService` instance that handles file operations.
  QuizFileRepository({required IQuizFileService fileService})
    : _fileService = fileService;

  /// Loads a `QuizFile` from a file at the specified [filePath].
  /// This method calls `readQuizFile` from `QuizFileService` to read the file,
  /// and then registers the loaded file in the service locator.
  ///
  /// - [filePath]: The path to the file to load.
  /// - Returns: A `Future<QuizFile>` containing the loaded `QuizFile`.
  /// - Throws: An exception if there is an error loading the file.
  Future<QuizFile> loadQuizFile(String filePath) async {
    final quizFile = await _fileService.readQuizFile(filePath);
    ServiceLocator.instance.registerQuizFile(quizFile);
    return quizFile;
  }

  /// Creates a new `QuizFile` with the specified metadata.
  /// The method generates a new `QuizFile` with the provided metadata.
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

  /// Saves an exported file to the file system.
  /// This method calls `saveExportedFile` from `QuizFileService` to save the file.
  ///
  /// - [bytes]: The binary content to be saved.
  /// - [dialogTitle]: The title for the save dialog window.
  /// - [fileName]: The name of the file.
  Future<void> saveExportedFile(
    Uint8List bytes,
    String dialogTitle,
    String fileName,
  ) async {
    return await _fileService.saveExportedFile(bytes, dialogTitle, fileName);
  }

  /// Opens a file picker for the user to select a quiz file.
  /// This method calls `pickFile` from `QuizFileService` to open the file picker.
  ///
  /// - Returns: A `Future<QuizFile?>` containing the selected `QuizFile`, or `null` if no file is selected.
  Future<QuizFile?> pickFile() async {
    final quizFile = await _fileService.pickFile();
    if (quizFile != null) {
      ServiceLocator.instance.registerQuizFile(quizFile);
    }
    return quizFile;
  }

    /// Picks a file manually using the file picker dialog.
  /// This method delegates the task of selecting a file to the `_fileService`'s
  /// `pickFile` method, and registers the selected file in the service locator.
  ///
  /// - Returns: A `Future<QuizFile?>` containing the selected `QuizFile`, or `null` if no file was selected.
  Future<QuizFile?> pickFileManually() async {
    final quizFile = await _fileService.pickFile();
    if (quizFile != null) {
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
    printInDebug("El original es: ${_fileService.originalFile}");
    printInDebug("El cached es: $cachedQuizFile");
    return _fileService.originalFile != cachedQuizFile;
  }
}
