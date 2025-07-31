import 'package:quiz_app/domain/models/quiz/quiz_file.dart';

/// Abstract class representing the base event for file operations.
abstract class FileEvent {}

/// Event triggered when a file is dropped into the application.
class FileDropped extends FileEvent {
  final String filePath; // Path of the dropped file
  FileDropped(this.filePath);
}

/// Event triggered when a file save is requested, with the file path and data.
class QuizFileSaveRequested extends FileEvent {
  QuizFile quizFile; // The QuizFile object to be saved
  final String dialogTitle;
  final String fileName;
  QuizFileSaveRequested(this.quizFile, this.dialogTitle, this.fileName);
}

/// Event triggered when a file is requested to be picked.
/// This event can be used to initiate the file selection process.
class QuizFilePickRequested extends FileEvent {}

/// Event triggered when a file is requested to be picked.
/// This event can be used to initiate the file selection process.
class CreateQuizMetadata extends FileEvent {
  final String name;
  final String version;
  final String description;
  final String author;
  CreateQuizMetadata({
    required this.name,
    required this.version,
    required this.description,
    required this.author,
  });
}

/// Event triggered to reset the file state.
/// This event can be used to clear any file-related data or state.
class QuizFileReset extends FileEvent {}
