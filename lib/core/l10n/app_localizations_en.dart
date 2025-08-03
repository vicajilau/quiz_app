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
  String get dropFileHere => 'Click here or drag a .quiz file to the screen';

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
  String get versionLabel => 'Version';

  @override
  String get authorLabel => 'Author';

  @override
  String get authorRequiredError => 'The author is required.';

  @override
  String get requiredFieldsError => 'All required fields must be completed.';

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
  String get retryFailedQuestions => 'Review Failed Questions';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count options',
      one: '1 option',
    );
    return '$_temp0';
  }

  @override
  String get optionsTooltip => 'Number of answer options for this question';

  @override
  String get imageTooltip => 'This question has an associated image';

  @override
  String get explanationTooltip => 'This question has an explanation';

  @override
  String get aiPrompt =>
      'You are an expert and friendly tutor specialized in helping students better understand exam questions and related topics. Your goal is to facilitate deep learning and conceptual understanding.\n\nYou can help with:\n- Explaining concepts related to the question\n- Clarifying doubts about answer options\n- Providing additional context about the topic\n- Suggesting complementary study resources\n- Explaining why certain answers are correct or incorrect\n- Relating the topic to other important concepts\n- Answering follow-up questions about the material\n\nAlways respond in the same language you are asked in. Be pedagogical, clear, and motivating in your explanations.';

  @override
  String get questionLabel => 'Question';

  @override
  String get optionsLabel => 'Options';

  @override
  String get explanationLabel => 'Explanation (optional)';

  @override
  String get studentComment => 'Student comment';

  @override
  String get aiAssistantTitle => 'AI Study Assistant';

  @override
  String get questionContext => 'Question Context';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get aiThinking => 'AI is thinking...';

  @override
  String get askAIHint => 'Ask your question about this topic...';

  @override
  String get aiPlaceholderResponse =>
      'This is a placeholder response. In a real implementation, this would connect to an AI service to provide helpful explanations about the question.';

  @override
  String get aiErrorResponse =>
      'Sorry, there was an error processing your question. Please try again.';

  @override
  String get configureApiKeyMessage =>
      'Please configure your OpenAI API Key in Settings.';

  @override
  String get errorLabel => 'Error:';

  @override
  String get noResponseReceived => 'No response received';

  @override
  String get invalidApiKeyError =>
      'Invalid API Key. Please check your OpenAI API Key in settings.';

  @override
  String get rateLimitError => 'Rate limit exceeded. Please try again later.';

  @override
  String get modelNotFoundError =>
      'Model not found. Please check your API access.';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get networkError =>
      'Network error: Unable to connect to OpenAI. Please check your internet connection.';

  @override
  String get openaiApiKeyNotConfigured => 'OpenAI API Key not configured';

  @override
  String get geminiApiKeyNotConfigured => 'Gemini API Key not configured';

  @override
  String get geminiApiKeyLabel => 'Google Gemini API Key';

  @override
  String get geminiApiKeyHint => 'Enter your Gemini API Key';

  @override
  String get geminiApiKeyDescription =>
      'Required for Gemini AI functionality. Your key is stored securely.';

  @override
  String get getGeminiApiKeyTooltip => 'Get API Key from Google AI Studio';

  @override
  String get aiRequiresAtLeastOneApiKeyError =>
      'AI Study Assistant requires at least one API Key (OpenAI or Gemini). Please enter an API key or disable the AI Assistant.';

  @override
  String get minutesAbbreviation => 'min';

  @override
  String get aiButtonTooltip => 'AI Study Assistant';

  @override
  String get aiButtonText => 'AI';

  @override
  String get aiAssistantSettingsTitle => 'AI Study Assistant (Preview)';

  @override
  String get aiAssistantSettingsDescription =>
      'Enable or disable the AI study assistant for questions';

  @override
  String get openaiApiKeyLabel => 'OpenAI API Key';

  @override
  String get openaiApiKeyHint => 'Enter your OpenAI API Key (sk-...)';

  @override
  String get openaiApiKeyDescription =>
      'Required for AI functionality. Your key is stored securely.';

  @override
  String get aiAssistantRequiresApiKeyError =>
      'AI Study Assistant requires an OpenAI API Key. Please enter your API key or disable the AI Assistant.';

  @override
  String get getApiKeyTooltip => 'Get API Key from OpenAI';

  @override
  String get deleteAction => 'Delete';

  @override
  String get explanationHint =>
      'Enter an explanation for the correct answer(s)';

  @override
  String get explanationTitle => 'Explanation';

  @override
  String get imageLabel => 'Image';

  @override
  String get changeImage => 'Change image';

  @override
  String get removeImage => 'Remove image';

  @override
  String get addImageTap => 'Tap to add image';

  @override
  String get imageFormats => 'Formats: JPG, PNG, GIF';

  @override
  String get imageLoadError => 'Error loading image';

  @override
  String imagePickError(String error) {
    return 'Error loading image: $error';
  }

  @override
  String get tapToZoom => 'Tap to zoom';

  @override
  String get trueLabel => 'True';

  @override
  String get falseLabel => 'False';

  @override
  String get addQuestion => 'Add Question';

  @override
  String get editQuestion => 'Edit Question';

  @override
  String get questionText => 'Question Text';

  @override
  String get questionType => 'Question Type';

  @override
  String get addOption => 'Add Option';

  @override
  String get optionLabel => 'Option';

  @override
  String get questionTextRequired => 'Question text is required';

  @override
  String get atLeastOneOptionRequired => 'At least one option must have text';

  @override
  String get atLeastOneCorrectAnswerRequired =>
      'At least one correct answer must be selected';

  @override
  String get onlyOneCorrectAnswerAllowed =>
      'Only one correct answer is allowed for this question type';

  @override
  String get removeOption => 'Remove option';

  @override
  String get selectCorrectAnswer => 'Select correct answer';

  @override
  String get selectCorrectAnswers => 'Select correct answers';

  @override
  String emptyOptionsError(String optionNumbers) {
    return 'Options $optionNumbers are empty. Please add text to them or remove them.';
  }

  @override
  String emptyOptionError(String optionNumber) {
    return 'Option $optionNumber is empty. Please add text to it or remove it.';
  }

  @override
  String get optionEmptyError => 'This option cannot be empty';

  @override
  String get hasImage => 'Image';

  @override
  String get hasExplanation => 'Explanation';

  @override
  String errorLoadingSettings(String error) {
    return 'Error loading settings: $error';
  }

  @override
  String couldNotOpenUrl(String url) {
    return 'Could not open $url';
  }

  @override
  String get loadingAiServices => 'Loading AI services...';

  @override
  String usingAiService(String serviceName) {
    return 'Using: $serviceName';
  }

  @override
  String get aiServiceLabel => 'AI Service:';
}
