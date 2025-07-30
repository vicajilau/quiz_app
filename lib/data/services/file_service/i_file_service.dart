import 'dart:typed_data';

import 'package:quiz_app/domain/models/quiz/quiz_file.dart';

/// Interface for file handling services, defining methods for reading,
/// saving, and exporting `.quiz` files across different platforms.
abstract class IFileService {
  /// Stores an original copy of the `QuizFile` to track changes.
  QuizFile? originalFile;

  /// Reads a `.quiz` file from the specified [filePath] and returns a `QuizFile` object.
  ///
  /// - Throws a [FileInvalidException] if the file does not have a `.quiz` extension.
  /// - [filePath]: The path to the `.quiz` file.
  /// - Returns: A `QuizFile` object containing the parsed data from the file.
  Future<QuizFile> readQuizFile(String filePath);

  /// Saves a `QuizFile` object to the file system.
  ///
  /// Opens a save dialog for the user to choose the file path and writes
  /// the `QuizFile` data in JSON format to the selected file.
  ///
  /// - [quizFile]: The `QuizFile` object to save.
  /// - [dialogTitle]: The title for the save dialog window.
  /// - [fileName]: The name of the file.
  /// - Returns: The `QuizFile` object with an updated file path if the user selects a path.
  Future<QuizFile?> saveQuizFile(
    QuizFile quizFile,
    String dialogTitle,
    String fileName,
  );

  /// Saves an exported file to the file system.
  ///
  /// Opens a save dialog for the user to choose the file path and writes
  /// the provided `Uint8List` byte data to the selected file.
  ///
  /// - [bytes]: The binary content to be saved.
  /// - [dialogTitle]: The title for the save dialog window.
  /// - [fileName]: The name of the file.
  Future<void> saveExportedFile(
    Uint8List bytes,
    String dialogTitle,
    String fileName,
  );

  /// Opens a file picker dialog for the user to select a `.quiz` file.
  ///
  /// If a valid file is selected, it reads and parses the file into a `QuizFile` object.
  ///
  /// - Returns: A `QuizFile` object if a valid file is selected, or `null` if no file is selected.
  Future<QuizFile?> pickFile();
}
