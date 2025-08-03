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

  /// Text displayed inside the drop area for dragging files.
  ///
  /// In en, this message translates to:
  /// **'Click here or drag a .quiz file to the screen'**
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
  String confirmDeleteMessage(String processName);

  /// Button text for confirming deletion.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// Title for the confirmation dialog when exiting.
  ///
  /// In en, this message translates to:
  /// **'Confirm Exit'**
  String get confirmExitTitle;

  /// Message in the confirmation dialog for exiting.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave without saving?'**
  String get confirmExitMessage;

  /// Exit button text.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitButton;

  /// Title for the save dialog.
  ///
  /// In en, this message translates to:
  /// **'Please select an output file:'**
  String get saveDialogTitle;

  /// Title for create quiz file dialog.
  ///
  /// In en, this message translates to:
  /// **'Create Quiz File'**
  String get createQuizFileTitle;

  /// Label for file name input.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get fileNameLabel;

  /// Label for file description input.
  ///
  /// In en, this message translates to:
  /// **'File Description'**
  String get fileDescriptionLabel;

  /// Create button text.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createButton;

  /// Error message when file name is empty.
  ///
  /// In en, this message translates to:
  /// **'The file name is required.'**
  String get fileNameRequiredError;

  /// Error message when file description is empty.
  ///
  /// In en, this message translates to:
  /// **'The file description is required.'**
  String get fileDescriptionRequiredError;

  /// Label for quiz version field
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;

  /// Label for quiz author field
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get authorLabel;

  /// Error message when author field is empty
  ///
  /// In en, this message translates to:
  /// **'The author is required.'**
  String get authorRequiredError;

  /// Error message when required fields are missing
  ///
  /// In en, this message translates to:
  /// **'All required fields must be completed.'**
  String get requiredFieldsError;

  /// Title for request file name dialog.
  ///
  /// In en, this message translates to:
  /// **'Enter the Quiz file name'**
  String get requestFileNameTitle;

  /// Hint text for file name input.
  ///
  /// In en, this message translates to:
  /// **'File name'**
  String get fileNameHint;

  /// Error message when file name is empty.
  ///
  /// In en, this message translates to:
  /// **'The file name cannot be empty.'**
  String get emptyFileNameMessage;

  /// Accept button text.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get acceptButton;

  /// Tooltip for save button.
  ///
  /// In en, this message translates to:
  /// **'Save the file'**
  String get saveTooltip;

  /// Tooltip for disabled save button.
  ///
  /// In en, this message translates to:
  /// **'No changes to save'**
  String get saveDisabledTooltip;

  /// Tooltip for execute button.
  ///
  /// In en, this message translates to:
  /// **'Execute the exam'**
  String get executeTooltip;

  /// Tooltip for add button.
  ///
  /// In en, this message translates to:
  /// **'Add a new question'**
  String get addTooltip;

  /// Semantic label for back button.
  ///
  /// In en, this message translates to:
  /// **'Back button'**
  String get backSemanticLabel;

  /// Tooltip for create file button.
  ///
  /// In en, this message translates to:
  /// **'Create a new Quiz file'**
  String get createFileTooltip;

  /// Tooltip for load file button.
  ///
  /// In en, this message translates to:
  /// **'Load an existing Quiz file'**
  String get loadFileTooltip;

  /// Question number label in quiz execution
  ///
  /// In en, this message translates to:
  /// **'Question {number}'**
  String questionNumber(int number);

  /// Previous button text in quiz navigation
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// Next button text in quiz navigation
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Finish button text in quiz navigation
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// Title of finish quiz dialog
  ///
  /// In en, this message translates to:
  /// **'Finish Quiz'**
  String get finishQuiz;

  /// Confirmation message for finishing quiz
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to finish the quiz? You won\'t be able to change your answers afterwards.'**
  String get finishQuizConfirmation;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Title of abandon quiz dialog
  ///
  /// In en, this message translates to:
  /// **'Abandon Quiz'**
  String get abandonQuiz;

  /// Confirmation message for abandoning quiz
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to abandon the quiz? All progress will be lost.'**
  String get abandonQuizConfirmation;

  /// Abandon button text
  ///
  /// In en, this message translates to:
  /// **'Abandon'**
  String get abandon;

  /// Quiz completed message
  ///
  /// In en, this message translates to:
  /// **'Quiz Completed!'**
  String get quizCompleted;

  /// Score display
  ///
  /// In en, this message translates to:
  /// **'Score: {score}%'**
  String score(String score);

  /// Correct answers count
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} correct answers'**
  String correctAnswers(int correct, int total);

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get retry;

  /// Go back button text
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get goBack;

  /// Button text to retry only the questions that were answered incorrectly
  ///
  /// In en, this message translates to:
  /// **'Retry Failed'**
  String get retryFailedQuestions;

  /// Question text in results
  ///
  /// In en, this message translates to:
  /// **'Question: {question}'**
  String question(String question);

  /// Title for the dialog to select number of questions for the quiz
  ///
  /// In en, this message translates to:
  /// **'Select Number of Questions'**
  String get selectQuestionCountTitle;

  /// Message explaining the question count selection
  ///
  /// In en, this message translates to:
  /// **'How many questions would you like to answer in this quiz?'**
  String get selectQuestionCountMessage;

  /// Option to select all available questions
  ///
  /// In en, this message translates to:
  /// **'All questions ({count})'**
  String allQuestions(int count);

  /// Button text to start the quiz
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get startQuiz;

  /// Label for custom number input field
  ///
  /// In en, this message translates to:
  /// **'Or enter a custom number:'**
  String get customNumberLabel;

  /// Label for the number input field
  ///
  /// In en, this message translates to:
  /// **'Number of questions'**
  String get numberInputLabel;

  /// Helper text for custom number input
  ///
  /// In en, this message translates to:
  /// **'If greater than {total}, questions will repeat'**
  String customNumberHelper(int total);

  /// Error message for invalid number input
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get errorInvalidNumber;

  /// Error message when number is zero or negative
  ///
  /// In en, this message translates to:
  /// **'Number must be greater than 0'**
  String get errorNumberMustBePositive;

  /// Title for the question order configuration dialog
  ///
  /// In en, this message translates to:
  /// **'Question Order Configuration'**
  String get questionOrderConfigTitle;

  /// Description text for the question order configuration dialog
  ///
  /// In en, this message translates to:
  /// **'Select the order in which you want questions to appear during the exam:'**
  String get questionOrderConfigDescription;

  /// Label for ascending question order option
  ///
  /// In en, this message translates to:
  /// **'Ascending Order'**
  String get questionOrderAscending;

  /// Description for ascending question order option
  ///
  /// In en, this message translates to:
  /// **'Questions will appear in order from 1 to the end'**
  String get questionOrderAscendingDesc;

  /// Label for descending question order option
  ///
  /// In en, this message translates to:
  /// **'Descending Order'**
  String get questionOrderDescending;

  /// Description for descending question order option
  ///
  /// In en, this message translates to:
  /// **'Questions will appear from the end to 1'**
  String get questionOrderDescendingDesc;

  /// Label for random question order option
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get questionOrderRandom;

  /// Description for random question order option
  ///
  /// In en, this message translates to:
  /// **'Questions will appear in random order'**
  String get questionOrderRandomDesc;

  /// Tooltip for the question order configuration button
  ///
  /// In en, this message translates to:
  /// **'Question order configuration'**
  String get questionOrderConfigTooltip;

  /// Label for the save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Title for exam time limit section
  ///
  /// In en, this message translates to:
  /// **'Exam Time Limit'**
  String get examTimeLimitTitle;

  /// Description for exam time limit feature
  ///
  /// In en, this message translates to:
  /// **'Set a time limit for the exam. When enabled, a countdown timer will be displayed during the quiz.'**
  String get examTimeLimitDescription;

  /// Label for enable exam time limit switch
  ///
  /// In en, this message translates to:
  /// **'Enable time limit'**
  String get enableTimeLimit;

  /// Label for exam time minutes input
  ///
  /// In en, this message translates to:
  /// **'Time limit (minutes)'**
  String get timeLimitMinutes;

  /// Title for exam time expired dialog
  ///
  /// In en, this message translates to:
  /// **'Time\'s Up!'**
  String get examTimeExpiredTitle;

  /// Message for exam time expired dialog
  ///
  /// In en, this message translates to:
  /// **'The exam time has expired. Your answers have been automatically submitted.'**
  String get examTimeExpiredMessage;

  /// Format for remaining time display (hours:minutes:seconds)
  ///
  /// In en, this message translates to:
  /// **'{hours}:{minutes}:{seconds}'**
  String remainingTime(String hours, String minutes, String seconds);

  /// Label for multiple choice question type
  ///
  /// In en, this message translates to:
  /// **'Multiple Choice'**
  String get questionTypeMultipleChoice;

  /// Label for single choice question type
  ///
  /// In en, this message translates to:
  /// **'Single Choice'**
  String get questionTypeSingleChoice;

  /// Label for true/false question type
  ///
  /// In en, this message translates to:
  /// **'True/False'**
  String get questionTypeTrueFalse;

  /// Label for essay question type
  ///
  /// In en, this message translates to:
  /// **'Essay'**
  String get questionTypeEssay;

  /// Label for unknown question type
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get questionTypeUnknown;

  /// Text showing the number of options in a question
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 option} other{{count} options}}'**
  String optionsCount(int count);

  /// Tooltip text for the options count badge
  ///
  /// In en, this message translates to:
  /// **'Number of answer options for this question'**
  String get optionsTooltip;

  /// Tooltip text for the image indicator badge
  ///
  /// In en, this message translates to:
  /// **'This question has an associated image'**
  String get imageTooltip;

  /// Tooltip text for the explanation indicator badge
  ///
  /// In en, this message translates to:
  /// **'This question has an explanation'**
  String get explanationTooltip;

  /// Base prompt for AI assistant
  ///
  /// In en, this message translates to:
  /// **'You are an expert and friendly tutor specialized in helping students better understand exam questions and related topics. Your goal is to facilitate deep learning and conceptual understanding.\n\nYou can help with:\n- Explaining concepts related to the question\n- Clarifying doubts about answer options\n- Providing additional context about the topic\n- Suggesting complementary study resources\n- Explaining why certain answers are correct or incorrect\n- Relating the topic to other important concepts\n- Answering follow-up questions about the material\n\nAlways respond in the same language you are asked in. Be pedagogical, clear, and motivating in your explanations.'**
  String get aiPrompt;

  /// Label for question in AI dialog
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get questionLabel;

  /// Label for options section
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get optionsLabel;

  /// Label for the explanation input field
  ///
  /// In en, this message translates to:
  /// **'Explanation (optional)'**
  String get explanationLabel;

  /// Label for student comment in AI dialog
  ///
  /// In en, this message translates to:
  /// **'Student comment'**
  String get studentComment;

  /// Title for AI assistant dialog
  ///
  /// In en, this message translates to:
  /// **'AI Study Assistant'**
  String get aiAssistantTitle;

  /// Label for question context section
  ///
  /// In en, this message translates to:
  /// **'Question Context'**
  String get questionContext;

  /// AI assistant label in chat
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// Loading message while AI processes
  ///
  /// In en, this message translates to:
  /// **'AI is thinking...'**
  String get aiThinking;

  /// Hint text for AI question input
  ///
  /// In en, this message translates to:
  /// **'Ask your question about this topic...'**
  String get askAIHint;

  /// Placeholder AI response for demo
  ///
  /// In en, this message translates to:
  /// **'This is a placeholder response. In a real implementation, this would connect to an AI service to provide helpful explanations about the question.'**
  String get aiPlaceholderResponse;

  /// Error message when AI request fails
  ///
  /// In en, this message translates to:
  /// **'Sorry, there was an error processing your question. Please try again.'**
  String get aiErrorResponse;

  /// Message to configure API key when not set
  ///
  /// In en, this message translates to:
  /// **'Please configure your OpenAI API Key in Settings.'**
  String get configureApiKeyMessage;

  /// Error label prefix for error messages
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get errorLabel;

  /// Message when no response is received from AI
  ///
  /// In en, this message translates to:
  /// **'No response received'**
  String get noResponseReceived;

  /// Error message for invalid API key
  ///
  /// In en, this message translates to:
  /// **'Invalid API Key. Please check your OpenAI API Key in settings.'**
  String get invalidApiKeyError;

  /// Error message for rate limit exceeded
  ///
  /// In en, this message translates to:
  /// **'Rate limit exceeded. Please try again later.'**
  String get rateLimitError;

  /// Error message for model not found
  ///
  /// In en, this message translates to:
  /// **'Model not found. Please check your API access.'**
  String get modelNotFoundError;

  /// Generic unknown error message
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// Network connectivity error message
  ///
  /// In en, this message translates to:
  /// **'Network error: Unable to connect to OpenAI. Please check your internet connection.'**
  String get networkError;

  /// Error message when API key is not configured
  ///
  /// In en, this message translates to:
  /// **'OpenAI API Key not configured'**
  String get openaiApiKeyNotConfigured;

  /// Error message when Gemini API key is not configured
  ///
  /// In en, this message translates to:
  /// **'Gemini API Key not configured'**
  String get geminiApiKeyNotConfigured;

  /// Label for Gemini API Key field
  ///
  /// In en, this message translates to:
  /// **'Google Gemini API Key'**
  String get geminiApiKeyLabel;

  /// Hint text for Gemini API Key field
  ///
  /// In en, this message translates to:
  /// **'Enter your Gemini API Key'**
  String get geminiApiKeyHint;

  /// Description for Gemini API Key field
  ///
  /// In en, this message translates to:
  /// **'Required for Gemini AI functionality. Your key is stored securely.'**
  String get geminiApiKeyDescription;

  /// Tooltip for the button to get Gemini API key
  ///
  /// In en, this message translates to:
  /// **'Get API Key from Google AI Studio'**
  String get getGeminiApiKeyTooltip;

  /// Error message when AI Assistant is enabled but no API keys are provided
  ///
  /// In en, this message translates to:
  /// **'AI Study Assistant requires at least one API Key (OpenAI or Gemini). Please enter an API key or disable the AI Assistant.'**
  String get aiRequiresAtLeastOneApiKeyError;

  /// Abbreviation for minutes
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesAbbreviation;

  /// Tooltip for AI assistant button
  ///
  /// In en, this message translates to:
  /// **'AI Study Assistant'**
  String get aiButtonTooltip;

  /// Text for AI assistant button
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get aiButtonText;

  /// Title for AI assistant settings section
  ///
  /// In en, this message translates to:
  /// **'AI Study Assistant (Preview)'**
  String get aiAssistantSettingsTitle;

  /// Description for AI assistant settings
  ///
  /// In en, this message translates to:
  /// **'Enable or disable the AI study assistant for questions'**
  String get aiAssistantSettingsDescription;

  /// Label for OpenAI API Key field
  ///
  /// In en, this message translates to:
  /// **'OpenAI API Key'**
  String get openaiApiKeyLabel;

  /// Hint text for OpenAI API Key field
  ///
  /// In en, this message translates to:
  /// **'Enter your OpenAI API Key (sk-...)'**
  String get openaiApiKeyHint;

  /// Description for OpenAI API Key field
  ///
  /// In en, this message translates to:
  /// **'Required for AI functionality. Your key is stored securely.'**
  String get openaiApiKeyDescription;

  /// Error message when AI Assistant is enabled but no API key is provided
  ///
  /// In en, this message translates to:
  /// **'AI Study Assistant requires an OpenAI API Key. Please enter your API key or disable the AI Assistant.'**
  String get aiAssistantRequiresApiKeyError;

  /// Tooltip for the button to get API key from OpenAI
  ///
  /// In en, this message translates to:
  /// **'Get API Key from OpenAI'**
  String get getApiKeyTooltip;

  /// Delete action text shown when swiping to delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// Hint text for the explanation input field
  ///
  /// In en, this message translates to:
  /// **'Enter an explanation for the correct answer(s)'**
  String get explanationHint;

  /// Title for the explanation section in quiz results
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get explanationTitle;

  /// Label for the image section in question editor
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get imageLabel;

  /// Text for button to change current image
  ///
  /// In en, this message translates to:
  /// **'Change image'**
  String get changeImage;

  /// Text for button to remove current image
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get removeImage;

  /// Instructional text for adding an image
  ///
  /// In en, this message translates to:
  /// **'Tap to add image'**
  String get addImageTap;

  /// Text indicating supported image formats
  ///
  /// In en, this message translates to:
  /// **'Formats: JPG, PNG, GIF'**
  String get imageFormats;

  /// Error message when image cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Error loading image'**
  String get imageLoadError;

  /// Error message when image selection fails
  ///
  /// In en, this message translates to:
  /// **'Error loading image: {error}'**
  String imagePickError(String error);

  /// Instructional text to indicate image can be zoomed
  ///
  /// In en, this message translates to:
  /// **'Tap to zoom'**
  String get tapToZoom;

  /// Label for true option in true/false questions
  ///
  /// In en, this message translates to:
  /// **'True'**
  String get trueLabel;

  /// Label for false option in true/false questions
  ///
  /// In en, this message translates to:
  /// **'False'**
  String get falseLabel;

  /// Title for adding a new question dialog
  ///
  /// In en, this message translates to:
  /// **'Add Question'**
  String get addQuestion;

  /// Title for editing an existing question dialog
  ///
  /// In en, this message translates to:
  /// **'Edit Question'**
  String get editQuestion;

  /// Label for question text input field
  ///
  /// In en, this message translates to:
  /// **'Question Text'**
  String get questionText;

  /// Label for question type dropdown
  ///
  /// In en, this message translates to:
  /// **'Question Type'**
  String get questionType;

  /// Label for add option button
  ///
  /// In en, this message translates to:
  /// **'Add Option'**
  String get addOption;

  /// Label for individual option input field
  ///
  /// In en, this message translates to:
  /// **'Option'**
  String get optionLabel;

  /// Error message when question text is empty
  ///
  /// In en, this message translates to:
  /// **'Question text is required'**
  String get questionTextRequired;

  /// Error message when all options are empty
  ///
  /// In en, this message translates to:
  /// **'At least one option must have text'**
  String get atLeastOneOptionRequired;

  /// Error message when no correct answer is selected
  ///
  /// In en, this message translates to:
  /// **'At least one correct answer must be selected'**
  String get atLeastOneCorrectAnswerRequired;

  /// Error message when multiple correct answers are selected for single choice questions
  ///
  /// In en, this message translates to:
  /// **'Only one correct answer is allowed for this question type'**
  String get onlyOneCorrectAnswerAllowed;

  /// Tooltip for remove option button
  ///
  /// In en, this message translates to:
  /// **'Remove option'**
  String get removeOption;

  /// Tooltip for radio button to select correct answer
  ///
  /// In en, this message translates to:
  /// **'Select correct answer'**
  String get selectCorrectAnswer;

  /// Tooltip for checkbox to select correct answers
  ///
  /// In en, this message translates to:
  /// **'Select correct answers'**
  String get selectCorrectAnswers;

  /// Error message when some options are empty
  ///
  /// In en, this message translates to:
  /// **'Options {optionNumbers} are empty. Please add text to them or remove them.'**
  String emptyOptionsError(String optionNumbers);

  /// Error message when one option is empty
  ///
  /// In en, this message translates to:
  /// **'Option {optionNumber} is empty. Please add text to it or remove it.'**
  String emptyOptionError(String optionNumber);

  /// Error message for individual empty option field
  ///
  /// In en, this message translates to:
  /// **'This option cannot be empty'**
  String get optionEmptyError;

  /// Label indicating that a question has an image
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get hasImage;

  /// Label indicating that a question has an explanation
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get hasExplanation;

  /// Message displayed when there is an error while loading application settings.
  ///
  /// In en, this message translates to:
  /// **'Error loading settings: {error}'**
  String errorLoadingSettings(String error);

  /// Message displayed when a URL cannot be opened.
  ///
  /// In en, this message translates to:
  /// **'Could not open {url}'**
  String couldNotOpenUrl(String url);

  /// Message displayed while loading available AI services.
  ///
  /// In en, this message translates to:
  /// **'Loading AI services...'**
  String get loadingAiServices;

  /// Message displayed showing which AI service is being used.
  ///
  /// In en, this message translates to:
  /// **'Using: {serviceName}'**
  String usingAiService(String serviceName);

  /// Label for the AI service selector.
  ///
  /// In en, this message translates to:
  /// **'AI Service:'**
  String get aiServiceLabel;
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
