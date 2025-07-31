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

  @override
  String get selectQuestionCountTitle => 'Select Number of Questions';

  @override
  String get selectQuestionCountMessage =>
      'How many questions would you like to answer in this quiz?';

  @override
  String allQuestions(int count) {
    return 'All questions ($count)';
  }

  @override
  String get startQuiz => 'Start Quiz';

  @override
  String questionsCount(int count) {
    return '$count questions';
  }

  @override
  String get customNumberLabel => 'Or enter a custom number:';

  @override
  String get numberInputLabel => 'Number of questions';

  @override
  String customNumberHelper(int total) {
    return 'If greater than $total, questions will repeat';
  }

  @override
  String get errorInvalidNumber => 'Please enter a valid number';

  @override
  String get errorNumberMustBePositive => 'Number must be greater than 0';

  @override
  String get questionOrderConfigTitle => 'Question Order Configuration';

  @override
  String get questionOrderConfigDescription =>
      'Select the order in which you want questions to appear during the exam:';

  @override
  String get questionOrderAscending => 'Ascending Order';

  @override
  String get questionOrderAscendingDesc =>
      'Questions will appear in order from 1 to the end';

  @override
  String get questionOrderDescending => 'Descending Order';

  @override
  String get questionOrderDescendingDesc =>
      'Questions will appear from the end to 1';

  @override
  String get questionOrderRandom => 'Random';

  @override
  String get questionOrderRandomDesc => 'Questions will appear in random order';

  @override
  String get questionOrderConfigTooltip => 'Question order configuration';

  @override
  String get save => 'Save';

  @override
  String get examTimeLimitTitle => 'Exam Time Limit';

  @override
  String get examTimeLimitDescription =>
      'Set a time limit for the exam. When enabled, a countdown timer will be displayed during the quiz.';

  @override
  String get enableTimeLimit => 'Enable time limit';

  @override
  String get timeLimitMinutes => 'Time limit (minutes)';

  @override
  String get examTimeExpiredTitle => 'Time\'s Up!';

  @override
  String get examTimeExpiredMessage =>
      'The exam time has expired. Your answers have been automatically submitted.';

  @override
  String remainingTime(String hours, String minutes, String seconds) {
    return '$hours:$minutes:$seconds';
  }

  @override
  String get questionTypeMultipleChoice => 'Multiple Choice';

  @override
  String get questionTypeSingleChoice => 'Single Choice';

  @override
  String get questionTypeTrueFalse => 'True/False';

  @override
  String get questionTypeEssay => 'Essay';

  @override
  String get questionTypeUnknown => 'Unknown';

  @override
  String optionsCount(int count) {
    return '$count options';
  }

  @override
  String get deleteAction => 'Delete';
}
