import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/data/repositories/quiz_file_repository.dart';

import 'file_event.dart';
import 'file_state.dart';

/// The `FileBloc` class handles file operations such as loading, saving, and picking files.
/// It listens for file-related events and emits the corresponding states based on the outcome of those events.
class FileBloc extends Bloc<FileEvent, FileState> {
  /// The repository responsible for handling file-related operations.
  final QuizFileRepository _fileRepository;

  /// Constructor for `FileBloc` that initializes the state and event handlers.
  ///
  /// - [fileRepository]: An instance of `FileRepository` used to manage file operations.
  FileBloc({required QuizFileRepository fileRepository})
    : _fileRepository = fileRepository,
      super(FileInitial()) {
    // Handling the FileDropped event
    on<FileDropped>((event, emit) async {
      emit(
        FileLoading(),
      ); // Emit loading state while the file is being processed
      try {
        final quizFile = await _fileRepository.loadQuizFile(event.filePath);
        emit(FileLoaded(quizFile)); // Emit the loaded file state
      } on Exception catch (e) {
        emit(
          FileError(reason: FileErrorType.errorOpeningFile, error: e),
        ); // Emit error if file saving fails
      } catch (e) {
        emit(
          FileError(
            reason: FileErrorType.errorOpeningFile,
            error: Exception(e),
          ),
        ); // Emit error if file loading fails
      }
    });

    // Handling the CreateQuizMetadata event
    on<CreateQuizMetadata>((event, emit) async {
      emit(
        FileLoading(),
      ); // Emit loading state while the file is being processed
      try {
        final quizFile = await _fileRepository.createQuizFile(
          title: event.name,
          version: event.version,
          author: event.author,
          description: event.description,
        );
        emit(FileLoaded(quizFile)); // Emit the loaded file state after creation
      } on Exception catch (e) {
        emit(
          FileError(reason: FileErrorType.errorOpeningFile, error: e),
        ); // Emit error if file creation fails
      } catch (e) {
        emit(
          FileError(
            reason: FileErrorType.errorOpeningFile,
            error: Exception(e),
          ),
        ); // Emit error if file creation fails
      }
    });

    // Handling the QuizFileSaveRequested event
    on<QuizFileSaveRequested>((event, emit) async {
      emit(FileLoading()); // Emit loading state while saving the file
      try {
        // Save the `QuizFile` and update the state with the saved file
        final quizFile = await _fileRepository.saveQuizFile(
          event.quizFile,
          event.dialogTitle,
          event.fileName,
        );
        if (quizFile != null) {
          event.quizFile = quizFile;
          emit(FileLoaded(event.quizFile));
        }
      } on Exception catch (e) {
        emit(
          FileError(reason: FileErrorType.errorSavingMasoFile, error: e),
        ); // Emit error if file saving fails
      } catch (e) {
        emit(
          FileError(
            reason: FileErrorType.errorSavingMasoFile,
            error: Exception(e),
          ),
        );
      }
    });

    // Handling the ExportedFileSaveRequested event
    on<ExportedFileSaveRequested>((event, emit) async {
      emit(FileLoading()); // Emit loading state while saving the file
      try {
        // Save the exported file and update the state
        await _fileRepository.saveExportedFile(
          event.bytes,
          event.dialogTitle,
          event.fileName,
        );
        emit(
          FileExported(event.fileFormat),
        ); // Emit the FileExported state after saving
      } on Exception catch (e) {
        emit(
          FileError(reason: FileErrorType.errorSavingExportedFile, error: e),
        ); // Emit error if file saving fails
      } catch (e) {
        emit(
          FileError(
            reason: FileErrorType.errorSavingExportedFile,
            error: Exception(e),
          ),
        );
      }
    });

    // Handling the MasoFileReset event
    on<MasoFileReset>((event, emit) async {
      emit(FileInitial()); // Emit initial state after reset
    });

    // Handling the QuizFilePickRequested event
    on<QuizFilePickRequested>((event, emit) async {
      emit(FileLoading()); // Emit loading state while picking the file
      try {
        final quizFile = await _fileRepository.pickFileManually();
        if (quizFile != null) {
          emit(FileLoaded(quizFile)); // Emit the loaded file state if picked
        } else {
          emit(FileInitial()); // Emit initial state if no file is picked
        }
      } on Exception catch (e) {
        emit(
          FileError(reason: FileErrorType.errorOpeningFile, error: e),
        ); // Emit error if file picking fails
      } catch (e) {
        emit(
          FileError(
            reason: FileErrorType.errorOpeningFile,
            error: Exception(e),
          ),
        );
      }
    });
  }
}
