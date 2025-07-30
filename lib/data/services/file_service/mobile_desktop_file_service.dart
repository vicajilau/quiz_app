import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:quiz_app/domain/models/custom_exceptions/bad_maso_file_exception.dart';
import 'package:platform_detail/platform_detail.dart';

import '../../../domain/models/custom_exceptions/bad_maso_file_error_type.dart';
import '../../../domain/models/maso/maso_file.dart';
import 'i_file_service.dart';

/// The `FileService` class provides functionalities for managing `.maso` files.
/// This includes reading a `.maso` file, saving a `MasoFile` object to the file system,
/// and interacting with the user for file selection.
class FileService implements IFileService {
  @override
  MasoFile? originalFile;

  /// Reads a `.maso` file from the specified [filePath] and parses it into a `MasoFile` object.
  ///
  /// Throws a [FileInvalidException] if the file does not have a `.maso` extension.
  ///
  /// - [filePath]: The path to the `.maso` file.
  /// - Returns: A `MasoFile` object containing the parsed data from the file.
  /// - Throws: [FileInvalidException] if the file extension is invalid.
  @override
  Future<MasoFile> readMasoFile(String filePath) async {
    if (!filePath.endsWith('.maso')) {
      throw BadMasoFileException(type: BadMasoFileErrorType.invalidExtension);
    }
    // Create a File object for the provided file path
    final file = File(filePath);
    // Read the file content as a string
    final content = await file.readAsString();

    // Decode the string content into a Map and convert it to a MasoFile object
    final json = jsonDecode(content) as Map<String, dynamic>;
    final masoFile = MasoFile.fromJson(json, filePath);
    originalFile = masoFile.copyWith();
    return masoFile;
  }

  /// Saves a `MasoFile` object to the file system.
  ///
  /// This method opens a save dialog for the user to choose the file path
  /// and writes the `MasoFile` data in JSON format to the selected file.
  ///
  /// - [masoFile]: The `MasoFile` object to save.
  /// - [dialogTitle]: The title for the save dialog window.
  /// - [fileName]: The name for the file.
  /// - Returns: The `MasoFile` object with an updated file path if the user selects a path.
  @override
  Future<MasoFile?> saveMasoFile(
    MasoFile masoFile,
    String dialogTitle,
    String fileName,
  ) async {
    // Convert the MasoFile object to JSON string and encode it to bytes
    String jsonString = jsonEncode(masoFile.toJson());
    final bytes = utf8.encode(jsonString);

    // Open a save dialog for the user to select a file path
    final pathSaved = await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      initialDirectory: masoFile.filePath,
      bytes: bytes,
    );

    if (pathSaved == null) return null;

    masoFile.filePath = pathSaved;
    originalFile = masoFile.copyWith();
    return masoFile;
  }

  /// Saves a `MasoFile` object to the file system.
  ///
  /// This method opens a save dialog for the user to choose the file path
  /// and writes the `MasoFile` data in JSON format to the selected file.
  ///
  /// - [masoFile]: The `MasoFile` object to save.
  /// - [dialogTitle]: The title for the save dialog window.
  /// - [fileName]: The name for the file.
  /// - Returns: The `MasoFile` object with an updated file path if the user selects a path.
  @override
  Future<void> saveExportedFile(
    Uint8List bytes,
    String dialogTitle,
    String fileName,
  ) async {
    // Convert the MasoFile object to JSON string and encode it to bytes

    // Open a save dialog for the user to select a file path
    final path = await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      bytes: bytes,
    );

    // If a path is selected and the platform is desktop, write the file
    if (path != null && PlatformDetail.isDesktop) {
      await _writeExportedFile(bytes, path);
    }
  }

  /// Writes a `Uint8List` object to its file path.
  ///
  /// This is a helper method used internally to perform the actual file writing
  /// after a file path has been determined.
  Future<void> _writeExportedFile(Uint8List bytes, String path) async {
    // Create a File object for the provided file path
    final file = File(path);

    // Write the content to the file
    await file.writeAsBytes(bytes);
  }

  /// Opens a file picker dialog for the user to select a `.maso` file.
  ///
  /// If a file is selected, it reads and parses the file into a `MasoFile` object.
  ///
  /// - Returns: A `MasoFile` object if a valid file is selected, or `null` if no file is selected.
  @override
  Future<MasoFile?> pickFile() async {
    // Open the file picker dialog
    final result = await FilePicker.platform.pickFiles();

    // If a file is selected, read and return the file as a MasoFile object
    if (result != null) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        return readMasoFile(filePath);
      }
    }
    return null; // Return null if no file is selected
  }
}
