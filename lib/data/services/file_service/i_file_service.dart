import 'dart:typed_data';

import '../../../domain/models/maso/maso_file.dart';

/// Interface for file handling services, defining methods for reading,
/// saving, and exporting `.maso` files across different platforms.
abstract class IFileService {
  /// Stores an original copy of the `MasoFile` to track changes.
  MasoFile? originalFile;

  /// Reads a `.maso` file from the specified [filePath] and returns a `MasoFile` object.
  ///
  /// - Throws a [FileInvalidException] if the file does not have a `.maso` extension.
  /// - [filePath]: The path to the `.maso` file.
  /// - Returns: A `MasoFile` object containing the parsed data from the file.
  Future<MasoFile> readMasoFile(String filePath);

  /// Saves a `MasoFile` object to the file system.
  ///
  /// Opens a save dialog for the user to choose the file path and writes
  /// the `MasoFile` data in JSON format to the selected file.
  ///
  /// - [masoFile]: The `MasoFile` object to save.
  /// - [dialogTitle]: The title for the save dialog window.
  /// - [fileName]: The name of the file.
  /// - Returns: The `MasoFile` object with an updated file path if the user selects a path.
  Future<MasoFile?> saveMasoFile(
      MasoFile masoFile, String dialogTitle, String fileName);

  /// Saves an exported file to the file system.
  ///
  /// Opens a save dialog for the user to choose the file path and writes
  /// the provided `Uint8List` byte data to the selected file.
  ///
  /// - [bytes]: The binary content to be saved.
  /// - [dialogTitle]: The title for the save dialog window.
  /// - [fileName]: The name of the file.
  Future<void> saveExportedFile(
      Uint8List bytes, String dialogTitle, String fileName);

  /// Opens a file picker dialog for the user to select a `.maso` file.
  ///
  /// If a valid file is selected, it reads and parses the file into a `MasoFile` object.
  ///
  /// - Returns: A `MasoFile` object if a valid file is selected, or `null` if no file is selected.
  Future<MasoFile?> pickFile();
}
