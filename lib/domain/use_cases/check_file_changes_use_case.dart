import '../../data/repositories/file_repository.dart';
import '../models/maso/maso_file.dart';

/// Use case for checking if a MasoFile has changed.
class CheckFileChangesUseCase {
  final FileRepository _fileRepository;

  /// Constructor that receives the repository as a dependency.
  CheckFileChangesUseCase({required FileRepository fileRepository})
      : _fileRepository = fileRepository;

  /// Executes the business logic to check if the file has changed.
  ///
  /// [cachedFile] is the MasoFile that needs to be checked for changes.
  /// It calls the repository method to check whether the file has changed.
  /// Returns true if the file has changed, false otherwise.
  bool execute(MasoFile cachedFile) {
    // Calls the repository to check if the file has changed
    return _fileRepository.hasMasoFileChanged(cachedFile);
  }
}
