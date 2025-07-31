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
  String fileError(String message) {
    return 'Error: $message';
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
  String errorSavingFile(String error) {
    return 'Error saving file: $error';
  }

  @override
  String arrivalTimeLabel(String arrivalTime) {
    return 'Arrival Time: $arrivalTime';
  }

  @override
  String serviceTimeLabel(String serviceTime) {
    return 'Service Time: $serviceTime';
  }

  @override
  String get editProcessTitle => 'Edit Process';

  @override
  String get createRegularProcessTitle => 'Create Regular Process';

  @override
  String get createBurstProcessTitle => 'Create Burst Process';

  @override
  String get processNameLabel => 'Process Name';

  @override
  String get arrivalTimeDialogLabel => 'Arrival Time';

  @override
  String get serviceTimeDialogLabel => 'Service Time';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String get confirmDeleteTitle => 'Confirm Deletion';

  @override
  String confirmDeleteMessage(Object processName) {
    return 'Are you sure you want to delete `$processName` process?';
  }

  @override
  String get deleteButton => 'Delete';

  @override
  String get enabledLabel => 'Enabled';

  @override
  String get disabledLabel => 'Disabled';

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
  String get fillAllFieldsError => 'Please fill in all the fields.';

  @override
  String get createQuizFileTitle => 'Create Quiz File';

  @override
  String get fileNameLabel => 'File Name';

  @override
  String get fileDescriptionLabel => 'File Description';

  @override
  String get createButton => 'Create';

  @override
  String get emptyNameError => 'The name cannot be empty.';

  @override
  String get duplicateNameError => 'A process with this name already exists.';

  @override
  String get invalidArrivalTimeError =>
      'Arrival time must be a positive integer.';

  @override
  String get invalidServiceTimeError =>
      'Service time must be a positive integer.';

  @override
  String get invalidTimeDifferenceError =>
      'Service time must be greater than arrival time.';

  @override
  String get timeDifferenceTooSmallError =>
      'Service time must be at least 1 unit greater than arrival time.';

  @override
  String get requestFileNameTitle => 'Enter the Quiz file name';

  @override
  String get fileNameHint => 'File name';

  @override
  String get acceptButton => 'Accept';

  @override
  String get errorTitle => 'Error';

  @override
  String get emptyFileNameMessage => 'The file name cannot be empty.';

  @override
  String get fileNameRequiredError => 'The file name is required.';

  @override
  String get fileDescriptionRequiredError =>
      'The file description is required.';

  @override
  String get executionSetupTitle => 'Execution Setup';

  @override
  String get selectAlgorithmLabel => 'Select Algorithm';

  @override
  String algorithmLabel(String algorithm) {
    String _temp0 = intl.Intl.selectLogic(algorithm, {
      'firstComeFirstServed': 'First Come First Served',
      'shortestJobFirst': 'Shortest Job First',
      'shortestRemainingTimeFirst': 'Shortest Remaining Time First',
      'roundRobin': 'Round Robin',
      'priorityBased': 'Priority Based',
      'multiplePriorityQueues': 'Multiple Priority Queues',
      'multiplePriorityQueuesWithFeedback':
          'Multiple Priority Queues with Feedback',
      'timeLimit': 'Time Limit',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

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
  String get executionScreenTitle => 'Execution Overview';

  @override
  String get executionTimelineTitle => 'Execution Timeline';

  @override
  String failedToCaptureImage(Object error) {
    return 'Failed to capture image: $error';
  }

  @override
  String get imageCopiedToClipboard => 'Image copied to clipboard';

  @override
  String get exportTimelineImage => 'Export as Image';

  @override
  String get exportTimelinePdf => 'Export as PDF';

  @override
  String get clipboardTooltip => 'Copy to clipboard';

  @override
  String get exportTooltip => 'Export execution timeline';

  @override
  String timelineProcessDescription(
    Object arrivalTime,
    Object processName,
    Object serviceTime,
  ) {
    return '$processName (Arrival: $arrivalTime, Service: $serviceTime)';
  }

  @override
  String executionTimeDescription(Object executionTime) {
    return 'Execution Time: $executionTime';
  }

  @override
  String get executionTimeUnavailable => 'N/A';

  @override
  String get imageExported => 'Image exported';

  @override
  String get pdfExported => 'PDF exported';

  @override
  String get metadataBadContent => 'The file metadata is invalid or corrupted.';

  @override
  String get processesBadContent => 'The process list contains invalid data.';

  @override
  String get unsupportedVersion =>
      'The file version is not supported by the current application.';

  @override
  String get invalidExtension =>
      'The file does not have a valid .quiz extension.';

  @override
  String get settingsDialogTitle => 'Settings';

  @override
  String get settingsDialogWarningTitle => 'Warning';

  @override
  String get settingsDialogWarningContent =>
      'Changing the mode will erase all processes from the quiz file. Do you want to proceed?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get settingsDialogDescription => 'The type of processes configured';

  @override
  String get processModeRegular => 'Regular';

  @override
  String get processModeBurst => 'Burst';

  @override
  String get processIdLabel => 'Process ID';

  @override
  String get burstDurationLabel => 'Burst Duration';

  @override
  String get addBurstButton => 'Add Burst';

  @override
  String get addThreadButton => 'Add Thread';

  @override
  String get deleteThreadTitle => 'Delete Thread';

  @override
  String deleteThreadConfirmation(Object threadId) {
    return 'Are you sure you want to delete the thread \"$threadId\"?';
  }

  @override
  String get confirmButton => 'Confirm';

  @override
  String get arrivalTimeLabelDecorator => 'Arrival Time';

  @override
  String get deleteBurstTitle => 'Delete Burst';

  @override
  String deleteBurstConfirmation(Object duration, Object type) {
    return 'Are you sure you want to delete $type burst with $duration ut duration?';
  }

  @override
  String invalidBurstSequenceError(Object thread) {
    return 'The burst sequence of thread ($thread) cannot contain two consecutive I/O bursts.';
  }

  @override
  String get selectBurstType => 'Select burst type';

  @override
  String get burstCpuType => 'CPU';

  @override
  String get burstIoType => 'I/O';

  @override
  String get burstTypeLabel => 'Burst type';

  @override
  String burstNameLabel(Object name) {
    return 'Burst $name';
  }

  @override
  String burstTypeListLabel(Object type) {
    return 'Burst Type: $type';
  }

  @override
  String threadIdLabel(Object id) {
    return 'Thread: $id';
  }

  @override
  String get contextSwitchTime => 'Context Switch Time';

  @override
  String get ioChannels => 'I/O Channels';

  @override
  String get cpuCount => 'CPU Count';

  @override
  String get quantumLabel => 'Quantum';

  @override
  String get invalidQuantumError =>
      'Please enter a valid quantum (greater than 0).';

  @override
  String get queueQuantaLabel => 'Quanta List';

  @override
  String get invalidQueueQuantaError =>
      'Please enter valid quantum values (greater than 0) separated with commas.';

  @override
  String get timeLimitLabel => 'Time Limit';

  @override
  String get invalidTimeLimitError =>
      'Please enter a valid time limit (greater than 0).';

  @override
  String emptyNameProcessBadContent(Object index) {
    return 'The process with index ($index) needs a name (id)';
  }

  @override
  String get duplicatedNameProcessBadContent =>
      'There are two or more processes with the same name';

  @override
  String invalidArrivalTimeBadContent(Object process) {
    return 'The process ($process) has the property arrival_time set to null or <= 0';
  }

  @override
  String invalidServiceTimeBadContent(Object process) {
    return 'The process ($process) has the property service_time set to null or <= 0';
  }

  @override
  String emptyThreadError(Object process) {
    return 'Process ($process) has no associated threads';
  }

  @override
  String emptyBurstError(Object process, Object thread) {
    return 'Thread ($thread) of the process ($process) has no associated bursts';
  }

  @override
  String startAndEndCpuSequenceError(Object thread) {
    return 'The burst sequence of thread ($thread) must start and end with a CPU burst.';
  }

  @override
  String startAndEndCpuSequenceBadContent(Object process, Object thread) {
    return 'The burst sequence of thread ($thread) in process ($process) must start and end with a CPU burst.';
  }

  @override
  String invalidBurstSequenceBadContent(Object process, Object thread) {
    return 'The burst sequence of thread ($thread) in process ($process) cannot contain two consecutive I/O bursts.';
  }

  @override
  String invalidBurstDuration(Object burst, Object process, Object thread) {
    return 'The burst ($burst) of thread ($thread) in process ($process) cannot contain is null or <= 0.';
  }

  @override
  String get unknownError => 'Unknown error';

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
