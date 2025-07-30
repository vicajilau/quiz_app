import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:quiz_app/domain/models/custom_exceptions/bad_quiz_file_exception.dart';
import 'package:platform_detail/platform_detail.dart';

import '../../../domain/models/custom_exceptions/bad_quiz_file_error_type.dart';
import '../../../domain/models/quiz/quiz_file.dart';
import 'i_quiz_file_service.dart';

/// The `QuizFileService` class provides functionalities for managing `.quiz` files.
/// This includes reading a `.quiz` file, saving a `QuizFile` object to the file system,
/// and interacting with the user for file selection.
class QuizFileService implements IQuizFileService {
  @override
  QuizFile? originalFile;

  /// Reads a `.quiz` file from the specified [filePath] and parses it into a `QuizFile` object.
  ///
  /// Throws a [BadQuizFileException] if the file does not have a `.quiz` extension.
  ///
  /// - [filePath]: The path to the `.quiz` file.
  /// - Returns: A `QuizFile` object containing the parsed data from the file.
  /// - Throws: [BadQuizFileException] if the file extension is invalid.
  @override
  Future<QuizFile> readQuizFile(String filePath) async {
    if (!filePath.endsWith('.quiz')) {
      throw BadQuizFileException(type: BadQuizFileErrorType.invalidExtension);
    }
    // Create a File object for the provided file path
    final file = File(filePath);
    // Read the file content as a string
    final content = await file.readAsString();

    // Decode the string content into a Map and convert it to a QuizFile object
    final json = jsonDecode(content) as Map<String, dynamic>;
    final quizFile = QuizFile.fromJson(json, filePath);
    originalFile = quizFile.copyWith();
    return quizFile;
  }

  /// Saves a `QuizFile` object to the file system.
  ///
  /// This method opens a save dialog for the user to choose the file path
  /// and writes the `QuizFile` data in JSON format to the selected file.
  ///
  /// - [quizFile]: The `QuizFile` object to save.
  /// - [dialogTitle]: The title for the save dialog.
  /// - [fileName]: The name of the file.
  /// - Returns: The `QuizFile` object with the updated file path, or `null` if the user cancels.
  @override
  Future<QuizFile?> saveQuizFile(
    QuizFile quizFile,
    String dialogTitle,
    String fileName,
  ) async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      allowedExtensions: ['quiz'],
      type: FileType.custom,
    );

    if (outputFile != null) {
      final file = File(outputFile);
      final content = jsonEncode(quizFile.toJson());
      await file.writeAsString(content);
      quizFile = quizFile.copyWith(filePath: outputFile);
      originalFile = quizFile.copyWith();
      return quizFile;
    }
    return null;
  }

  /// Saves an exported file to the file system.
  ///
  /// Opens a save dialog for the user to choose the file path and writes
  /// the provided `Uint8List` byte data to the selected file.
  ///
  /// - [bytes]: The binary content to be saved.
  /// - [dialogTitle]: The title for the save dialog window.
  /// - [fileName]: The name of the file.
  @override
  Future<void> saveExportedFile(
    Uint8List bytes,
    String dialogTitle,
    String fileName,
  ) async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
    );

    if (outputFile != null) {
      final file = File(outputFile);
      await file.writeAsBytes(bytes);
    }
  }

  /// Opens a file picker dialog for the user to select a `.quiz` file.
  ///
  /// If a valid file is selected, it reads and parses the file into a `QuizFile` object.
  ///
  /// - Returns: A `QuizFile` object if a valid file is selected, or `null` if no file is selected.
  @override
  Future<QuizFile?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['quiz'],
      allowMultiple: false,
    );

    if (result != null) {
      final platformFile = result.files.first;

      if (PlatformDetail.isWeb) {
        // Handle web platform
        if (platformFile.bytes != null) {
          final content = String.fromCharCodes(platformFile.bytes!);
          final json = jsonDecode(content) as Map<String, dynamic>;
          final quizFile = QuizFile.fromJson(json, platformFile.name);
          originalFile = quizFile.copyWith();
          return quizFile;
        }
      } else {
        // Handle desktop/mobile platforms
        if (platformFile.path != null) {
          return await readQuizFile(platformFile.path!);
        }
      }
    }
    return null;
  }
}