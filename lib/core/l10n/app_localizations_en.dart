// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get titleAppBar => 'Quiz - Exam Simulator';

  @override
  String get create => 'Create';

  @override
  String get load => 'Load';

  @override
  String fileLoaded(String filePath) {
    return 'File loaded: $filePath';
  }

  @override
  String fileSaved(String filePath) {
    return 'File saved: $filePath';
  }

  @override
  String get dropFileHere => 'Drag a .quiz file here';

  @override
  String get errorInvalidFile => 'Error: Invalid file. Must be a .quiz file.';

  @override
  String errorLoadingFile(String error) {
    return 'Error loading the Quiz file: $error';
  }

  @override
  String errorExportingFile(String error) {
    return 'Error exporting the file: $error';
  }

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String get confirmDeleteTitle => 'Confirm Deletion';

  @override
  String confirmDeleteMessage(String processName) {
    return 'Are you sure you want to delete `$processName` process?';
  }

  @override
  String get deleteButton => 'Delete';

  @override
  String get confirmExitTitle => 'Confirm Exit';

  @override
  String get confirmExitMessage =>
      'Are you sure you want to leave without saving?';

  @override
  String get exitButton => 'Exit';

  @override
  String get saveDialogTitle => 'Please select an output file:';

  @override
  String get createQuizFileTitle => 'Create Quiz File';

  @override
  String get fileNameLabel => 'File Name';

  @override
  String get fileDescriptionLabel => 'File Description';

  @override
  String get createButton => 'Create';

  @override
  String get fileNameRequiredError => 'The file name is required.';

  @override
  String get fileDescriptionRequiredError =>
      'The file description is required.';

  @override
  String get requestFileNameTitle => 'Enter the Quiz file name';

  @override
  String get fileNameHint => 'File name';

  @override
  String get emptyFileNameMessage => 'The file name cannot be empty.';

  @override
  String get acceptButton => 'Accept';

  @override
  String get saveTooltip => 'Save the file';

  @override
  String get saveDisabledTooltip => 'No changes to save';

  @override
  String get executeTooltip => 'Execute the exam';

  @override
  String get addTooltip => 'Add a new question';

  @override
  String get backSemanticLabel => 'Back button';

  @override
  String get createFileTooltip => 'Create a new Quiz file';

  @override
  String get loadFileTooltip => 'Load an existing Quiz file';

  @override
  String questionNumber(int number) {
    return 'Question $number';
  }

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get finishQuiz => 'Finish Quiz';

  @override
  String get finishQuizConfirmation =>
      'Are you sure you want to finish the quiz? You won\'t be able to change your answers afterwards.';

  @override
  String get cancel => 'Cancel';

  @override
  String get abandonQuiz => 'Abandon Quiz';

  @override
  String get abandonQuizConfirmation =>
      'Are you sure you want to abandon the quiz? All progress will be lost.';

  @override
  String get abandon => 'Abandon';

  @override
  String get quizCompleted => 'Quiz Completed!';

  @override
  String score(String score) {
    return 'Score: $score%';
  }

  @override
  String correctAnswers(int correct, int total) {
    return '$correct of $total correct answers';
  }

  @override
  String get retry => 'Retry';

  @override
  String get goBack => 'Go Back';

  @override
  String question(String question) {
    return 'Question: $question';
  }
}
