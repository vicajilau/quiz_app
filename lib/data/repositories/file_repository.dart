import 'dart:typed_data';

import 'package:quiz_app/core/service_locator.dart';

import '../../core/debug_print.dart';
import '../../domain/models/maso/maso_file.dart';
import '../../domain/models/maso/metadata.dart';
import '../../domain/models/maso/process_mode.dart';
import '../../domain/models/maso/processes.dart';
import '../services/file_service/i_file_service.dart';

/// The `FileRepository` class manages file-related operations such as loading, saving,
/// and selecting files. It delegates these tasks to an instance of `FileService`.
class FileRepository {
  /// Instance of `FileService` to handle file operations.
  final IFileService _fileService;

  /// Constructor to initialize `FileRepository` with a `FileService` instance.
  /// This allows for the delegation of file-related tasks.
  ///
  /// - [fileService]: The `FileService` instance that handles file operations.
  FileRepository({required IFileService fileService})
    : _fileService = fileService;

  /// Loads a `MasoFile` from a file at the specified [filePath].
  /// This method calls `readMasoFile` from `FileService` to read the file,
  /// and then registers the loaded file in the service locator.
  ///
  /// - [filePath]: The path to the file to load.
  /// - Returns: A `Future<MasoFile>` containing the loaded `MasoFile`.
  /// - Throws: An exception if there is an error loading the file.
  Future<MasoFile> loadMasoFile(String filePath) async {
    final masoFile = await _fileService.readMasoFile(filePath);
    ServiceLocator.instance.registerMasoFile(masoFile);
    return masoFile;
  }

  /// Creates a new `MasoFile` with the specified metadata.
  /// The method generates a new `MasoFile` with the provided `name`, `version`,
  /// and `description`, then registers it in the service locator.
  ///
  /// - [name]: The name for the new `MasoFile`.
  /// - [version]: The version for the new `MasoFile`.
  /// - [description]: The description for the new `MasoFile`.
  /// - Returns: A `Future<MasoFile>` containing the created `MasoFile`.
  Future<MasoFile> createMasoFile({
    required String name,
    required String version,
    required String description,
  }) async {
    final processes = Processes(mode: ProcessesMode.regular, elements: []);
    final masoFile = MasoFile(
      metadata: Metadata(
        name: name,
        version: version,
        description: description,
      ),
      processes: processes,
    );
    ServiceLocator.instance.registerMasoFile(masoFile);
    return masoFile;
  }

  /// Saves a `MasoFile` to a file using `FileService`.
  /// This method calls the `saveMasoFile` function from `FileService` to save the file.
  ///
  /// - [masoFile]: The `MasoFile` to save.
  /// - [dialogTitle]: The title of the file save dialog.
  /// - [fileName]: The name of the file.
  /// - Returns: A `Future<MasoFile>` containing the saved `MasoFile`.
  /// - Throws: An exception if there is an error saving the file.
  Future<MasoFile?> saveMasoFile(
    MasoFile masoFile,
    String dialogTitle,
    String fileName,
  ) async {
    return await _fileService.saveMasoFile(masoFile, dialogTitle, fileName);
  }

  /// Saves a `MasoFile` to a file using `FileService`.
  /// This method calls the `saveMasoFile` function from `FileService` to save the file.
  ///
  /// - [masoFile]: The `MasoFile` to save.
  /// - [dialogTitle]: The title of the file save dialog.
  /// - [fileName]: The name of the file.
  /// - Returns: A `Future<MasoFile>` containing the saved `MasoFile`.
  /// - Throws: An exception if there is an error saving the file.
  Future<void> saveExportedFile(
    Uint8List bytes,
    String dialogTitle,
    String fileName,
  ) async {
    return await _fileService.saveExportedFile(bytes, dialogTitle, fileName);
  }

  /// Picks a file manually using the file picker dialog.
  /// This method delegates the task of selecting a file to the `_fileService`'s
  /// `pickFile` method, and registers the selected file in the service locator.
  ///
  /// - Returns: A `Future<MasoFile?>` containing the selected `MasoFile`, or `null` if no file was selected.
  Future<MasoFile?> pickFileManually() async {
    final masoFile = await _fileService.pickFile();
    if (masoFile != null) {
      ServiceLocator.instance.registerMasoFile(masoFile);
    }
    return masoFile;
  }

  /// Checks if a `MasoFile` has changed by comparing the current file content
  /// with the cached version of the file. This method reads the original file
  /// content from [filePath] and compares it with the [cachedMasoFile].
  ///
  /// - [filePath]: The path to the file to check.
  /// - [cachedMasoFile]: The cached version of the `MasoFile` for comparison.
  /// - Returns: A `Future<bool>` indicating whether the file content has changed (`true`) or not (`false`).
  bool hasMasoFileChanged(MasoFile cachedMasoFile) {
    if (cachedMasoFile.filePath == null) return true;
    printInDebug("El original es: ${_fileService.originalFile}");
    printInDebug("El cached es: $cachedMasoFile");
    return _fileService.originalFile != cachedMasoFile;
  }
}
