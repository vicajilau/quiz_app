import 'package:quiz_app/data/repositories/quiz_file_repository.dart';
import 'package:quiz_app/domain/models/quiz/quiz_file.dart';

/// Use case for checking if a QuizFile has changed.
class CheckFileChangesUseCase {
  final QuizFileRepository _fileRepository;

  /// Constructor that receives the repository as a dependency.
  CheckFileChangesUseCase({required QuizFileRepository fileRepository})
    : _fileRepository = fileRepository;

  /// Executes the business logic to check if the file has changed.
  ///
  /// [cachedFile] is the QuizFile that needs to be checked for changes.
  /// It calls the repository method to check whether the file has changed.
  /// Returns true if the file has changed, false otherwise.
  bool execute(QuizFile cachedFile) {
    // Calls the repository to check if the file has changed
    return _fileRepository.hasQuizFileChanged(cachedFile);
  }
}
