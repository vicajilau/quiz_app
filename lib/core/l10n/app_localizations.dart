import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Title of the application displayed in the AppBar.
  ///
  /// In en, this message translates to:
  /// **'Quiz - Exam Simulator'**
  String get titleAppBar;

  /// Label for the Create Quiz file button in the AppBar.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Label for the Load Quiz file button in the AppBar.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get load;

  /// Message displayed when a file is successfully loaded.
  ///
  /// In en, this message translates to:
  /// **'File loaded: {filePath}'**
  String fileLoaded(String filePath);

  /// Message displayed when a file is successfully saved.
  ///
  /// In en, this message translates to:
  /// **'File saved: {filePath}'**
  String fileSaved(String filePath);

  /// Message displayed when there is an error loading or saving a file.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String fileError(String message);

  /// Text displayed inside the drop area for dragging files.
  ///
  /// In en, this message translates to:
  /// **'Drag a .quiz file here'**
  String get dropFileHere;

  /// Message displayed when the dropped file is not a .quiz file.
  ///
  /// In en, this message translates to:
  /// **'Error: Invalid file. Must be a .quiz file.'**
  String get errorInvalidFile;

  /// Message displayed when there is an error while loading a Quiz file.
  ///
  /// In en, this message translates to:
  /// **'Error loading the Quiz file: {error}'**
  String errorLoadingFile(String error);

  /// Message displayed when there is an error while exporting a file.
  ///
  /// In en, this message translates to:
  /// **'Error exporting the file: {error}'**
  String errorExportingFile(String error);

  /// Message displayed when there is an error while saving a file.
  ///
  /// In en, this message translates to:
  /// **'Error saving file: {error}'**
  String errorSavingFile(String error);

  /// Label for displaying the arrival time of a process.
  ///
  /// In en, this message translates to:
  /// **'Arrival Time: {arrivalTime}'**
  String arrivalTimeLabel(String arrivalTime);

  /// Label for displaying the service time of a process.
  ///
  /// In en, this message translates to:
  /// **'Service Time: {serviceTime}'**
  String serviceTimeLabel(String serviceTime);

  /// Title of the screen for editing a process.
  ///
  /// In en, this message translates to:
  /// **'Edit Process'**
  String get editProcessTitle;

  /// Title of the screen for creating a regular process.
  ///
  /// In en, this message translates to:
  /// **'Create Regular Process'**
  String get createRegularProcessTitle;

  /// Title of the screen for creating a burst process.
  ///
  /// In en, this message translates to:
  /// **'Create Burst Process'**
  String get createBurstProcessTitle;

  /// Label for the process name input field.
  ///
  /// In en, this message translates to:
  /// **'Process Name'**
  String get processNameLabel;

  /// Label for the arrival time input field.
  ///
  /// In en, this message translates to:
  /// **'Arrival Time'**
  String get arrivalTimeDialogLabel;

  /// Label for the service time input field.
  ///
  /// In en, this message translates to:
  /// **'Service Time'**
  String get serviceTimeDialogLabel;

  /// Cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// Save button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// Title for the confirmation dialog when deleting a process.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeleteTitle;

  /// Message in the confirmation dialog for deletion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete `{processName}` process?'**
  String confirmDeleteMessage(Object processName);

  /// Button text for confirming deletion.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @enabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabledLabel;

  /// No description provided for @disabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabledLabel;

  /// No description provided for @confirmExitTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Exit'**
  String get confirmExitTitle;

  /// No description provided for @confirmExitMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave without saving?'**
  String get confirmExitMessage;

  /// No description provided for @exitButton.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitButton;

  /// No description provided for @saveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Please select an output file:'**
  String get saveDialogTitle;

  /// No description provided for @fillAllFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all the fields.'**
  String get fillAllFieldsError;

  /// No description provided for @createQuizFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Quiz File'**
  String get createQuizFileTitle;

  /// No description provided for @fileNameLabel.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get fileNameLabel;

  /// No description provided for @fileDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'File Description'**
  String get fileDescriptionLabel;

  /// No description provided for @createButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createButton;

  /// No description provided for @emptyNameError.
  ///
  /// In en, this message translates to:
  /// **'The name cannot be empty.'**
  String get emptyNameError;

  /// No description provided for @duplicateNameError.
  ///
  /// In en, this message translates to:
  /// **'A process with this name already exists.'**
  String get duplicateNameError;

  /// No description provided for @invalidArrivalTimeError.
  ///
  /// In en, this message translates to:
  /// **'Arrival time must be a positive integer.'**
  String get invalidArrivalTimeError;

  /// No description provided for @invalidServiceTimeError.
  ///
  /// In en, this message translates to:
  /// **'Service time must be a positive integer.'**
  String get invalidServiceTimeError;

  /// No description provided for @invalidTimeDifferenceError.
  ///
  /// In en, this message translates to:
  /// **'Service time must be greater than arrival time.'**
  String get invalidTimeDifferenceError;

  /// No description provided for @timeDifferenceTooSmallError.
  ///
  /// In en, this message translates to:
  /// **'Service time must be at least 1 unit greater than arrival time.'**
  String get timeDifferenceTooSmallError;

  /// No description provided for @requestFileNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the Quiz file name'**
  String get requestFileNameTitle;

  /// No description provided for @fileNameHint.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get fileNameHint;

  /// No description provided for @acceptButton.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptButton;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorTitle;

  /// No description provided for @emptyFileNameMessage.
  ///
  /// In en, this message translates to:
  /// **'The file name cannot be empty.'**
  String get emptyFileNameMessage;

  /// No description provided for @fileNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'The file name is required.'**
  String get fileNameRequiredError;

  /// No description provided for @fileDescriptionRequiredError.
  ///
  /// In en, this message translates to:
  /// **'The file description is required.'**
  String get fileDescriptionRequiredError;

  /// No description provided for @executionSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Execution Setup'**
  String get executionSetupTitle;

  /// No description provided for @selectAlgorithmLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Algorithm'**
  String get selectAlgorithmLabel;

  /// No description provided for @algorithmLabel.
  ///
  /// In en, this message translates to:
  /// **'{algorithm, select, firstComeFirstServed {First Come First Served} shortestJobFirst {Shortest Job First} shortestRemainingTimeFirst {Shortest Remaining Time First} roundRobin {Round Robin} priorityBased {Priority Based} multiplePriorityQueues {Multiple Priority Queues} multiplePriorityQueuesWithFeedback {Multiple Priority Queues with Feedback} timeLimit {Time Limit} other {Unknown}}'**
  String algorithmLabel(String algorithm);

  /// No description provided for @saveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save the file'**
  String get saveTooltip;

  /// No description provided for @saveDisabledTooltip.
  ///
  /// In en, this message translates to:
  /// **'No changes to save'**
  String get saveDisabledTooltip;

  /// No description provided for @executeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Execute the exam'**
  String get executeTooltip;

  /// No description provided for @addTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add a new question'**
  String get addTooltip;

  /// No description provided for @backSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Back button'**
  String get backSemanticLabel;

  /// No description provided for @createFileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create a new Quiz file'**
  String get createFileTooltip;

  /// No description provided for @loadFileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Load an existing Quiz file'**
  String get loadFileTooltip;

  /// No description provided for @executionScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Execution Overview'**
  String get executionScreenTitle;

  /// No description provided for @executionTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Execution Timeline'**
  String get executionTimelineTitle;

  /// No description provided for @failedToCaptureImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to capture image: {error}'**
  String failedToCaptureImage(Object error);

  /// No description provided for @imageCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Image copied to clipboard'**
  String get imageCopiedToClipboard;

  /// No description provided for @exportTimelineImage.
  ///
  /// In en, this message translates to:
  /// **'Export as Image'**
  String get exportTimelineImage;

  /// No description provided for @exportTimelinePdf.
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get exportTimelinePdf;

  /// No description provided for @clipboardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get clipboardTooltip;

  /// No description provided for @exportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export execution timeline'**
  String get exportTooltip;

  /// No description provided for @timelineProcessDescription.
  ///
  /// In en, this message translates to:
  /// **'{processName} (Arrival: {arrivalTime}, Service: {serviceTime})'**
  String timelineProcessDescription(
    Object arrivalTime,
    Object processName,
    Object serviceTime,
  );

  /// No description provided for @executionTimeDescription.
  ///
  /// In en, this message translates to:
  /// **'Execution Time: {executionTime}'**
  String executionTimeDescription(Object executionTime);

  /// No description provided for @executionTimeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get executionTimeUnavailable;

  /// No description provided for @imageExported.
  ///
  /// In en, this message translates to:
  /// **'Image exported'**
  String get imageExported;

  /// No description provided for @pdfExported.
  ///
  /// In en, this message translates to:
  /// **'PDF exported'**
  String get pdfExported;

  /// No description provided for @metadataBadContent.
  ///
  /// In en, this message translates to:
  /// **'The file metadata is invalid or corrupted.'**
  String get metadataBadContent;

  /// No description provided for @processesBadContent.
  ///
  /// In en, this message translates to:
  /// **'The process list contains invalid data.'**
  String get processesBadContent;

  /// No description provided for @unsupportedVersion.
  ///
  /// In en, this message translates to:
  /// **'The file version is not supported by the current application.'**
  String get unsupportedVersion;

  /// No description provided for @invalidExtension.
  ///
  /// In en, this message translates to:
  /// **'The file does not have a valid .quiz extension.'**
  String get invalidExtension;

  /// No description provided for @settingsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsDialogTitle;

  /// No description provided for @settingsDialogWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get settingsDialogWarningTitle;

  /// No description provided for @settingsDialogWarningContent.
  ///
  /// In en, this message translates to:
  /// **'Changing the mode will erase all processes from the quiz file. Do you want to proceed?'**
  String get settingsDialogWarningContent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @settingsDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'The type of processes configured'**
  String get settingsDialogDescription;

  /// No description provided for @processModeRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get processModeRegular;

  /// No description provided for @processModeBurst.
  ///
  /// In en, this message translates to:
  /// **'Burst'**
  String get processModeBurst;

  /// No description provided for @processIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Process ID'**
  String get processIdLabel;

  /// No description provided for @burstDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Burst Duration'**
  String get burstDurationLabel;

  /// No description provided for @addBurstButton.
  ///
  /// In en, this message translates to:
  /// **'Add Burst'**
  String get addBurstButton;

  /// No description provided for @addThreadButton.
  ///
  /// In en, this message translates to:
  /// **'Add Thread'**
  String get addThreadButton;

  /// No description provided for @deleteThreadTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Thread'**
  String get deleteThreadTitle;

  /// No description provided for @deleteThreadConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the thread \"{threadId}\"?'**
  String deleteThreadConfirmation(Object threadId);

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// No description provided for @arrivalTimeLabelDecorator.
  ///
  /// In en, this message translates to:
  /// **'Arrival Time'**
  String get arrivalTimeLabelDecorator;

  /// No description provided for @deleteBurstTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Burst'**
  String get deleteBurstTitle;

  /// No description provided for @deleteBurstConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {type} burst with {duration} ut duration?'**
  String deleteBurstConfirmation(Object duration, Object type);

  /// No description provided for @invalidBurstSequenceError.
  ///
  /// In en, this message translates to:
  /// **'The burst sequence of thread ({thread}) cannot contain two consecutive I/O bursts.'**
  String invalidBurstSequenceError(Object thread);

  /// No description provided for @selectBurstType.
  ///
  /// In en, this message translates to:
  /// **'Select burst type'**
  String get selectBurstType;

  /// No description provided for @burstCpuType.
  ///
  /// In en, this message translates to:
  /// **'CPU'**
  String get burstCpuType;

  /// No description provided for @burstIoType.
  ///
  /// In en, this message translates to:
  /// **'I/O'**
  String get burstIoType;

  /// No description provided for @burstTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Burst type'**
  String get burstTypeLabel;

  /// No description provided for @burstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Burst {name}'**
  String burstNameLabel(Object name);

  /// No description provided for @burstTypeListLabel.
  ///
  /// In en, this message translates to:
  /// **'Burst Type: {type}'**
  String burstTypeListLabel(Object type);

  /// No description provided for @threadIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Thread: {id}'**
  String threadIdLabel(Object id);

  /// No description provided for @contextSwitchTime.
  ///
  /// In en, this message translates to:
  /// **'Context Switch Time'**
  String get contextSwitchTime;

  /// No description provided for @ioChannels.
  ///
  /// In en, this message translates to:
  /// **'I/O Channels'**
  String get ioChannels;

  /// No description provided for @cpuCount.
  ///
  /// In en, this message translates to:
  /// **'CPU Count'**
  String get cpuCount;

  /// No description provided for @quantumLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantum'**
  String get quantumLabel;

  /// No description provided for @invalidQuantumError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantum (greater than 0).'**
  String get invalidQuantumError;

  /// No description provided for @queueQuantaLabel.
  ///
  /// In en, this message translates to:
  /// **'Quanta List'**
  String get queueQuantaLabel;

  /// No description provided for @invalidQueueQuantaError.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid quantum values (greater than 0) separated with commas.'**
  String get invalidQueueQuantaError;

  /// No description provided for @timeLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Time Limit'**
  String get timeLimitLabel;

  /// No description provided for @invalidTimeLimitError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid time limit (greater than 0).'**
  String get invalidTimeLimitError;

  /// No description provided for @emptyNameProcessBadContent.
  ///
  /// In en, this message translates to:
  /// **'The process with index ({index}) needs a name (id)'**
  String emptyNameProcessBadContent(Object index);

  /// No description provided for @duplicatedNameProcessBadContent.
  ///
  /// In en, this message translates to:
  /// **'There are two or more processes with the same name'**
  String get duplicatedNameProcessBadContent;

  /// No description provided for @invalidArrivalTimeBadContent.
  ///
  /// In en, this message translates to:
  /// **'The process ({process}) has the property arrival_time set to null or <= 0'**
  String invalidArrivalTimeBadContent(Object process);

  /// No description provided for @invalidServiceTimeBadContent.
  ///
  /// In en, this message translates to:
  /// **'The process ({process}) has the property service_time set to null or <= 0'**
  String invalidServiceTimeBadContent(Object process);

  /// No description provided for @emptyThreadError.
  ///
  /// In en, this message translates to:
  /// **'Process ({process}) has no associated threads'**
  String emptyThreadError(Object process);

  /// No description provided for @emptyBurstError.
  ///
  /// In en, this message translates to:
  /// **'Thread ({thread}) of the process ({process}) has no associated bursts'**
  String emptyBurstError(Object process, Object thread);

  /// No description provided for @startAndEndCpuSequenceError.
  ///
  /// In en, this message translates to:
  /// **'The burst sequence of thread ({thread}) must start and end with a CPU burst.'**
  String startAndEndCpuSequenceError(Object thread);

  /// No description provided for @startAndEndCpuSequenceBadContent.
  ///
  /// In en, this message translates to:
  /// **'The burst sequence of thread ({thread}) in process ({process}) must start and end with a CPU burst.'**
  String startAndEndCpuSequenceBadContent(Object process, Object thread);

  /// No description provided for @invalidBurstSequenceBadContent.
  ///
  /// In en, this message translates to:
  /// **'The burst sequence of thread ({thread}) in process ({process}) cannot contain two consecutive I/O bursts.'**
  String invalidBurstSequenceBadContent(Object process, Object thread);

  /// No description provided for @invalidBurstDuration.
  ///
  /// In en, this message translates to:
  /// **'The burst ({burst}) of thread ({thread}) in process ({process}) cannot contain is null or <= 0.'**
  String invalidBurstDuration(Object burst, Object process, Object thread);

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
