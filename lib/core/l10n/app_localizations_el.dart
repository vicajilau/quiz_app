// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get titleAppBar => 'Κουίζ - Προσομοιωτής Εξετάσεων';

  @override
  String get create => 'Δημιουργία';

  @override
  String get preview => 'Προεπισκόπηση';

  @override
  String get load => 'Φόρτωση';

  @override
  String fileLoaded(String filePath) {
    return 'Το αρχείο φορτώθηκε: $filePath';
  }

  @override
  String fileSaved(String filePath) {
    return 'Το αρχείο αποθηκεύτηκε: $filePath';
  }

  @override
  String get dropFileHere =>
      'Κάντε κλικ στο λογότυπο ή σύρετε ένα αρχείο .quiz στην οθόνη';

  @override
  String get errorInvalidFile =>
      'Σφάλμα: Μη έγκυρο αρχείο. Πρέπει να είναι αρχείο .quiz.';

  @override
  String errorLoadingFile(String error) {
    return 'Σφάλμα κατά τη φόρτωση του αρχείου Quiz: $error';
  }

  @override
  String errorExportingFile(String error) {
    return 'Σφάλμα κατά την εξαγωγή του αρχείου: $error';
  }

  @override
  String get cancelButton => 'Ακύρωση';

  @override
  String get saveButton => 'Αποθήκευση';

  @override
  String get confirmDeleteTitle => 'Επιβεβαίωση Διαγραφής';

  @override
  String confirmDeleteMessage(String processName) {
    return 'Είστε σίγουροι ότι θέλετε να διαγράψετε τη διαδικασία `$processName`;';
  }

  @override
  String get deleteButton => 'Διαγραφή';

  @override
  String get confirmExitTitle => 'Επιβεβαίωση Εξόδου';

  @override
  String get confirmExitMessage =>
      'Είστε σίγουροι ότι θέλετε να φύγετε χωρίς αποθήκευση;';

  @override
  String get exitButton => 'Έξοδος';

  @override
  String get saveDialogTitle => 'Παρακαλώ επιλέξτε αρχείο εξόδου:';

  @override
  String get createQuizFileTitle => 'Δημιουργία Αρχείου Quiz';

  @override
  String get fileNameLabel => 'Όνομα Αρχείου';

  @override
  String get fileDescriptionLabel => 'Περιγραφή Αρχείου';

  @override
  String get createButton => 'Δημιουργία';

  @override
  String get fileNameRequiredError => 'Το όνομα αρχείου είναι υποχρεωτικό.';

  @override
  String get fileDescriptionRequiredError =>
      'Η περιγραφή αρχείου είναι υποχρεωτική.';

  @override
  String get versionLabel => 'Έκδοση';

  @override
  String get authorLabel => 'Συγγραφέας';

  @override
  String get authorRequiredError => 'Ο συγγραφέας είναι υποχρεωτικός.';

  @override
  String get requiredFieldsError =>
      'Όλα τα υποχρεωτικά πεδία πρέπει να συμπληρωθούν.';

  @override
  String get requestFileNameTitle => 'Εισάγετε το όνομα του αρχείου Quiz';

  @override
  String get fileNameHint => 'Όνομα αρχείου';

  @override
  String get emptyFileNameMessage =>
      'Το όνομα αρχείου δεν μπορεί να είναι κενό.';

  @override
  String get acceptButton => 'Αποδοχή';

  @override
  String get saveTooltip => 'Αποθήκευση αρχείου';

  @override
  String get saveDisabledTooltip => 'Δεν υπάρχουν αλλαγές για αποθήκευση';

  @override
  String get executeTooltip => 'Εκτέλεση εξέτασης';

  @override
  String get addTooltip => 'Προσθήκη νέας ερώτησης';

  @override
  String get backSemanticLabel => 'Κουμπί επιστροφής';

  @override
  String get createFileTooltip => 'Δημιουργία νέου αρχείου Quiz';

  @override
  String get loadFileTooltip => 'Φόρτωση υπάρχοντος αρχείου Quiz';

  @override
  String questionNumber(int number) {
    return 'Ερώτηση $number';
  }

  @override
  String get previous => 'Προηγούμενο';

  @override
  String get next => 'Επόμενο';

  @override
  String get finish => 'Τέλος';

  @override
  String get finishQuiz => 'Ολοκλήρωση Κουίζ';

  @override
  String get finishQuizConfirmation =>
      'Είστε σίγουροι ότι θέλετε να ολοκληρώσετε το κουίζ; Δεν θα μπορείτε να αλλάξετε τις απαντήσεις σας μετά.';

  @override
  String get abandonQuiz => 'Εγκατάλειψη Κουίζ';

  @override
  String get abandonQuizConfirmation =>
      'Είστε σίγουροι ότι θέλετε να εγκαταλείψετε το κουίζ; Όλη η πρόοδος θα χαθεί.';

  @override
  String get abandon => 'Εγκατάλειψη';

  @override
  String get quizCompleted => 'Το Κουίζ Ολοκληρώθηκε!';

  @override
  String score(String score) {
    return 'Βαθμολογία: $score%';
  }

  @override
  String correctAnswers(int correct, int total) {
    return '$correct από $total σωστές απαντήσεις';
  }

  @override
  String get retry => 'Επανάληψη';

  @override
  String get goBack => 'Τέλος';

  @override
  String get retryFailedQuestions => 'Επανάληψη Λάθος';

  @override
  String question(String question) {
    return 'Ερώτηση: $question';
  }

  @override
  String get selectQuestionCountTitle => 'Επιλογή Αριθμού Ερωτήσεων';

  @override
  String get selectQuestionCountMessage =>
      'Πόσες ερωτήσεις θα θέλατε να απαντήσετε σε αυτό το κουίζ;';

  @override
  String allQuestions(int count) {
    return 'Όλες οι ερωτήσεις ($count)';
  }

  @override
  String get startQuiz => 'Έναρξη Κουίζ';

  @override
  String get errorInvalidNumber => 'Παρακαλώ εισάγετε έγκυρο αριθμό';

  @override
  String get errorNumberMustBePositive =>
      'Ο αριθμός πρέπει να είναι μεγαλύτερος από 0';

  @override
  String get customNumberLabel => 'Ή εισάγετε προσαρμοσμένο αριθμό:';

  @override
  String customNumberHelper(int total) {
    return 'Αν μεγαλύτερος από $total, οι ερωτήσεις θα επαναληφθούν';
  }

  @override
  String get numberInputLabel => 'Αριθμός ερωτήσεων';

  @override
  String get questionOrderConfigTitle => 'Διαμόρφωση Σειράς Ερωτήσεων';

  @override
  String get questionOrderConfigDescription =>
      'Επιλέξτε τη σειρά εμφάνισης των ερωτήσεων κατά την εξέταση:';

  @override
  String get questionOrderAscending => 'Αύξουσα Σειρά';

  @override
  String get questionOrderAscendingDesc =>
      'Οι ερωτήσεις θα εμφανίζονται με σειρά από 1 έως το τέλος';

  @override
  String get questionOrderDescending => 'Φθίνουσα Σειρά';

  @override
  String get questionOrderDescendingDesc =>
      'Οι ερωτήσεις θα εμφανίζονται από το τέλος προς το 1';

  @override
  String get questionOrderRandom => 'Τυχαία';

  @override
  String get questionOrderRandomDesc =>
      'Οι ερωτήσεις θα εμφανίζονται με τυχαία σειρά';

  @override
  String get questionOrderConfigTooltip => 'Διαμόρφωση σειράς ερωτήσεων';

  @override
  String get save => 'Αποθήκευση';

  @override
  String get examTimeLimitTitle => 'Χρονικό Όριο Εξέτασης';

  @override
  String get examTimeLimitDescription =>
      'Ορίστε χρονικό όριο για την εξέταση. Όταν ενεργοποιηθεί, θα εμφανίζεται χρονόμετρο κατά τη διάρκεια του κουίζ.';

  @override
  String get enableTimeLimit => 'Ενεργοποίηση χρονικού ορίου';

  @override
  String get timeLimitMinutes => 'Χρονικό όριο (λεπτά)';

  @override
  String get examTimeExpiredTitle => 'Τέλος Χρόνου!';

  @override
  String get examTimeExpiredMessage =>
      'Ο χρόνος εξέτασης έληξε. Οι απαντήσεις σας υποβλήθηκαν αυτόματα.';

  @override
  String remainingTime(String hours, String minutes, String seconds) {
    return '$hours:$minutes:$seconds';
  }

  @override
  String get questionTypeMultipleChoice => 'Πολλαπλής Επιλογής';

  @override
  String get questionTypeSingleChoice => 'Μονής Επιλογής';

  @override
  String get questionTypeTrueFalse => 'Σωστό/Λάθος';

  @override
  String get questionTypeEssay => 'Ανάπτυξης';

  @override
  String get questionTypeUnknown => 'Άγνωστο';

  @override
  String optionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count επιλογές',
      one: '1 επιλογή',
    );
    return '$_temp0';
  }

  @override
  String get optionsTooltip =>
      'Αριθμός επιλογών απάντησης για αυτή την ερώτηση';

  @override
  String get imageTooltip => 'Αυτή η ερώτηση έχει συσχετισμένη εικόνα';

  @override
  String get explanationTooltip => 'Αυτή η ερώτηση έχει εξήγηση';

  @override
  String get aiPrompt =>
      'Είστε ένας ειδικός και φιλικός εκπαιδευτής που ειδικεύεται στο να βοηθά μαθητές να κατανοούν καλύτερα τις ερωτήσεις εξετάσεων και τα σχετικά θέματα. Ο στόχος σας είναι να διευκολύνετε τη βαθιά μάθηση και την εννοιολογική κατανόηση.\n\nΜπορείτε να βοηθήσετε με:\n- Εξήγηση εννοιών σχετικών με την ερώτηση\n- Διευκρίνιση αποριών σχετικά με τις επιλογές απάντησης\n- Παροχή πρόσθετου πλαισίου για το θέμα\n- Πρόταση συμπληρωματικών πηγών μελέτης\n- Εξήγηση γιατί συγκεκριμένες απαντήσεις είναι σωστές ή λάθος\n- Συσχέτιση του θέματος με άλλες σημαντικές έννοιες\n- Απάντηση σε επακόλουθες ερωτήσεις για το υλικό\n\nΠάντα να απαντάτε στην ίδια γλώσσα που σας ρωτούν. Να είστε παιδαγωγικός, σαφής και παρακινητικός στις εξηγήσεις σας.';

  @override
  String get questionLabel => 'Ερώτηση';

  @override
  String get studentComment => 'Σχόλιο μαθητή';

  @override
  String get aiAssistantTitle => 'Βοηθός Μελέτης AI';

  @override
  String get questionContext => 'Πλαίσιο Ερώτησης';

  @override
  String get aiAssistant => 'Βοηθός AI';

  @override
  String get aiThinking => 'Η AI σκέφτεται...';

  @override
  String get askAIHint => 'Κάντε την ερώτησή σα γι\' αυτό το θέμα...';

  @override
  String get aiPlaceholderResponse =>
      'Αυτή είναι μια ενδεικτική απάντηση. Σε πραγματική υλοποίηση, αυτό θα συνδεόταν με μια υπηρεσία AI για να παρέχει χρήσιμες εξηγήσεις σχετικά με την ερώτηση.';

  @override
  String get aiErrorResponse =>
      'Λυπούμαστε, υπήρξε σφάλμα κατά την επεξεργασία της ερώτησής σας. Παρακαλώ δοκιμάστε ξανά.';

  @override
  String get configureApiKeyMessage =>
      'Παρακαλώ ρυθμίστε το κλειδί API AI στις Ρυθμίσεις.';

  @override
  String get errorLabel => 'Σφάλμα:';

  @override
  String get noResponseReceived => 'Δεν ελήφθη απάντηση';

  @override
  String get invalidApiKeyError =>
      'Μη έγκυρο κλειδί API. Παρακαλώ ελέγξτε το κλειδί API OpenAI στις ρυθμίσεις.';

  @override
  String get rateLimitError =>
      'Υπέρβαση ορίου χρήσης. Παρακαλώ δοκιμάστε ξανά αργότερα.';

  @override
  String get modelNotFoundError =>
      'Το μοντέλο δεν βρέθηκε. Παρακαλώ ελέγξτε την πρόσβασή σας στο API.';

  @override
  String get unknownError => 'Άγνωστο σφάλμα';

  @override
  String get networkError =>
      'Σφάλμα δικτύου: Αδυναμία σύνδεσης στο OpenAI. Παρακαλώ ελέγξτε τη σύνδεσή σας στο διαδίκτυο.';

  @override
  String get openaiApiKeyNotConfigured =>
      'Το κλειδί API OpenAI δεν έχει ρυθμιστεί';

  @override
  String get geminiApiKeyNotConfigured =>
      'Το κλειδί API Gemini δεν έχει ρυθμιστεί';

  @override
  String get geminiApiKeyLabel => 'Κλειδί API Gemini';

  @override
  String get geminiApiKeyHint => 'Εισάγετε το κλειδί API Gemini';

  @override
  String get geminiApiKeyDescription =>
      'Απαιτείται για τη λειτουργικότητα Gemini AI. Το κλειδί σας αποθηκεύεται με ασφάλεια.';

  @override
  String get getGeminiApiKeyTooltip => 'Λήψη κλειδιού API από Google AI Studio';

  @override
  String get aiRequiresAtLeastOneApiKeyError =>
      'Ο Βοηθός Μελέτης AI απαιτεί τουλάχιστον ένα κλειδί API (OpenAI ή Gemini). Παρακαλώ εισάγετε ένα κλειδί API ή απενεργοποιήστε τον Βοηθό AI.';

  @override
  String get minutesAbbreviation => 'λεπ';

  @override
  String get aiButtonTooltip => 'Βοηθός Μελέτης AI';

  @override
  String get aiButtonText => 'AI';

  @override
  String get aiAssistantSettingsTitle => 'Βοηθός Μελέτης AI (Προεπισκόπηση)';

  @override
  String get aiAssistantSettingsDescription =>
      'Ενεργοποίηση ή απενεργοποίηση του βοηθού μελέτης AI για ερωτήσεις';

  @override
  String get openaiApiKeyLabel => 'Κλειδί API OpenAI';

  @override
  String get openaiApiKeyHint => 'Εισάγετε το κλειδί API OpenAI (sk-...)';

  @override
  String get openaiApiKeyDescription =>
      'Απαιτείται για ενσωμάτωση με OpenAI. Το κλειδί OpenAI αποθηκεύεται με ασφάλεια.';

  @override
  String get aiAssistantRequiresApiKeyError =>
      'Ο Βοηθός Μελέτης AI απαιτεί κλειδί API OpenAI. Παρακαλώ εισάγετε το κλειδί API σας ή απενεργοποιήστε τον Βοηθό AI.';

  @override
  String get getApiKeyTooltip => 'Λήψη κλειδιού API από OpenAI';

  @override
  String get deleteAction => 'Διαγραφή';

  @override
  String get explanationLabel => 'Εξήγηση (προαιρετικό)';

  @override
  String get explanationHint =>
      'Εισάγετε μια εξήγηση για τη/τις σωστή/ές απάντηση/εις';

  @override
  String get explanationTitle => 'Εξήγηση';

  @override
  String get imageLabel => 'Εικόνα';

  @override
  String get changeImage => 'Αλλαγή εικόνας';

  @override
  String get removeImage => 'Αφαίρεση εικόνας';

  @override
  String get addImageTap => 'Πατήστε για προσθήκη εικόνας';

  @override
  String get imageFormats => 'Μορφές: JPG, PNG, GIF';

  @override
  String get imageLoadError => 'Σφάλμα φόρτωσης εικόνας';

  @override
  String imagePickError(String error) {
    return 'Σφάλμα φόρτωσης εικόνας: $error';
  }

  @override
  String get tapToZoom => 'Πατήστε για εστίαση';

  @override
  String get trueLabel => 'Σωστό';

  @override
  String get falseLabel => 'Λάθος';

  @override
  String get addQuestion => 'Προσθήκη Ερώτησης';

  @override
  String get editQuestion => 'Επεξεργασία Ερώτησης';

  @override
  String get questionText => 'Κείμενο Ερώτησης';

  @override
  String get questionType => 'Τύπος Ερώτησης';

  @override
  String get addOption => 'Προσθήκη Επιλογής';

  @override
  String get optionsLabel => 'Επιλογές';

  @override
  String get optionLabel => 'Επιλογή';

  @override
  String get questionTextRequired => 'Το κείμενο ερώτησης είναι υποχρεωτικό';

  @override
  String get atLeastOneOptionRequired =>
      'Τουλάχιστον μία επιλογή πρέπει να έχει κείμενο';

  @override
  String get atLeastOneCorrectAnswerRequired =>
      'Πρέπει να επιλεγεί τουλάχιστον μία σωστή απάντηση';

  @override
  String get onlyOneCorrectAnswerAllowed =>
      'Επιτρέπεται μόνο μία σωστή απάντηση για αυτόν τον τύπο ερώτησης';

  @override
  String get removeOption => 'Αφαίρεση επιλογής';

  @override
  String get selectCorrectAnswer => 'Επιλογή σωστής απάντησης';

  @override
  String get selectCorrectAnswers => 'Επιλογή σωστών απαντήσεων';

  @override
  String emptyOptionsError(String optionNumbers) {
    return 'Οι επιλογές $optionNumbers είναι κενές. Παρακαλώ προσθέστε κείμενο ή αφαιρέστε τις.';
  }

  @override
  String emptyOptionError(String optionNumber) {
    return 'Η επιλογή $optionNumber είναι κενή. Παρακαλώ προσθέστε κείμενο ή αφαιρέστε την.';
  }

  @override
  String get optionEmptyError => 'Αυτή η επιλογή δεν μπορεί να είναι κενή';

  @override
  String get hasImage => 'Εικόνα';

  @override
  String get hasExplanation => 'Εξήγηση';

  @override
  String errorLoadingSettings(String error) {
    return 'Σφάλμα φόρτωσης ρυθμίσεων: $error';
  }

  @override
  String couldNotOpenUrl(String url) {
    return 'Αδυναμία ανοίγματος $url';
  }

  @override
  String get loadingAiServices => 'Φόρτωση υπηρεσιών AI...';

  @override
  String usingAiService(String serviceName) {
    return 'Χρήση: $serviceName';
  }

  @override
  String get aiServiceLabel => 'Υπηρεσία AI:';

  @override
  String get importQuestionsTitle => 'Εισαγωγή Ερωτήσεων';

  @override
  String importQuestionsMessage(int count, String fileName) {
    return 'Βρέθηκαν $count ερωτήσεις στο \"$fileName\". Πού θέλετε να τις εισάγετε;';
  }

  @override
  String get importQuestionsPositionQuestion =>
      'Πού θα θέλατε να προσθέσετε αυτές τις ερωτήσεις;';

  @override
  String get importAtBeginning => 'Στην Αρχή';

  @override
  String get importAtEnd => 'Στο Τέλος';

  @override
  String questionsImportedSuccess(int count) {
    return 'Εισήχθησαν επιτυχώς $count ερωτήσεις';
  }

  @override
  String get importQuestionsTooltip =>
      'Εισαγωγή ερωτήσεων από άλλο αρχείο quiz';

  @override
  String get dragDropHintText =>
      'Μπορείτε επίσης να σύρετε και να αποθέσετε αρχεία .quiz εδώ για εισαγωγή ερωτήσεων';

  @override
  String get randomizeAnswersTitle => 'Τυχαία Σειρά Απαντήσεων';

  @override
  String get randomizeAnswersDescription =>
      'Ανακάτεμα της σειράς των επιλογών απάντησης κατά την εκτέλεση του κουίζ';

  @override
  String get showCorrectAnswerCountTitle =>
      'Εμφάνιση Αριθμού Σωστών Απαντήσεων';

  @override
  String get showCorrectAnswerCountDescription =>
      'Εμφάνιση του αριθμού των σωστών απαντήσεων σε ερωτήσεις πολλαπλής επιλογής';

  @override
  String correctAnswersCount(int count) {
    return 'Select $count correct answers';
  }

  @override
  String get correctSelectedLabel => 'Correct';

  @override
  String get correctMissedLabel => 'Correct';

  @override
  String get incorrectSelectedLabel => 'Incorrect';

  @override
  String get aiGenerateDialogTitle => 'Generate Questions with AI';

  @override
  String get aiQuestionCountLabel => 'Number of Questions (Optional)';

  @override
  String get aiQuestionCountHint => 'Leave empty for AI to decide';

  @override
  String get aiQuestionCountValidation => 'Must be a number between 1 and 50';

  @override
  String get aiQuestionTypeLabel => 'Question Type';

  @override
  String get aiQuestionTypeRandom => 'Random (Mixed)';

  @override
  String get aiLanguageLabel => 'Question Language';

  @override
  String get aiContentLabel => 'Content to generate questions from';

  @override
  String aiWordCount(int current, int max) {
    return '$current / $max words';
  }

  @override
  String get aiContentHint =>
      'Enter the text, topic, or content from which you want to generate questions...';

  @override
  String get aiContentHelperText =>
      'AI will create questions based on this content';

  @override
  String aiWordLimitError(int max) {
    return 'You have exceeded the limit of $max words';
  }

  @override
  String get aiContentRequiredError =>
      'You must provide content to generate questions';

  @override
  String aiContentLimitError(int max) {
    return 'Content exceeds the limit of $max words';
  }

  @override
  String get aiMinWordsError =>
      'Provide at least 10 words to generate quality questions';

  @override
  String get aiInfoTitle => 'Information';

  @override
  String get aiInfoDescription =>
      '• AI will analyze the content and generate relevant questions\n• You can include text, definitions, explanations, or any educational material\\n• Questions will include answer options and explanations\\n• The process may take a few seconds';

  @override
  String get aiGenerateButton => 'Generate Questions';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageCatalan => 'Català';

  @override
  String get languageBasque => 'Euskera';

  @override
  String get languageGalician => 'Galego';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageChinese => '中文';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageJapanese => '日本語';

  @override
  String get aiServicesLoading => 'Loading AI services...';

  @override
  String get aiServicesNotConfigured => 'No AI services configured';

  @override
  String get aiGeneratedQuestions => 'AI Generated';

  @override
  String get aiApiKeyRequired =>
      'Please configure at least one AI API key in Settings to use AI generation.';

  @override
  String get aiGenerationFailed =>
      'Could not generate questions. Try with different content.';

  @override
  String aiGenerationError(String error) {
    return 'Error generating questions: $error';
  }

  @override
  String get noQuestionsInFile => 'No questions found in the imported file';

  @override
  String get couldNotAccessFile => 'Could not access the selected file';

  @override
  String get defaultOutputFileName => 'output-file.quiz';

  @override
  String get generateQuestionsWithAI => 'Generate questions with AI';

  @override
  String aiServiceLimitsWithChars(int words, int chars) {
    return 'Limit: $words words or $chars characters';
  }

  @override
  String aiServiceLimitsWordsOnly(int words) {
    return 'Limit: $words words';
  }

  @override
  String get aiAssistantDisabled => 'AI Assistant Disabled';

  @override
  String get enableAiAssistant =>
      'The AI assistant is disabled. Please enable it in settings to use AI features.';

  @override
  String aiMinWordsRequired(int minWords) {
    return 'Minimum $minWords words required';
  }

  @override
  String aiWordsReadyToGenerate(int wordCount) {
    return '$wordCount words ✓ Ready to generate';
  }

  @override
  String aiWordsProgress(int currentWords, int minWords, int moreNeeded) {
    return '$currentWords/$minWords words ($moreNeeded more needed)';
  }

  @override
  String aiValidationMinWords(int minWords, int moreNeeded) {
    return 'Minimum $minWords words required ($moreNeeded more needed)';
  }

  @override
  String get enableQuestion => 'Enable question';

  @override
  String get disableQuestion => 'Disable question';

  @override
  String get questionDisabled => 'Disabled';

  @override
  String get noEnabledQuestionsError =>
      'No enabled questions available to run the quiz';

  @override
  String get evaluateWithAI => 'Evaluate with AI';

  @override
  String get aiEvaluation => 'AI Evaluation';

  @override
  String aiEvaluationError(String error) {
    return 'Error evaluating response: $error';
  }

  @override
  String get aiEvaluationPromptSystemRole =>
      'You are an expert teacher evaluating a student\'s response to an essay question. Your task is to provide detailed and constructive evaluation. Please respond in English.';

  @override
  String get aiEvaluationPromptQuestion => 'QUESTION:';

  @override
  String get aiEvaluationPromptStudentAnswer => 'STUDENT\'S ANSWER:';

  @override
  String get aiEvaluationPromptCriteria =>
      'EVALUATION CRITERIA (based on teacher\'s explanation):';

  @override
  String get aiEvaluationPromptSpecificInstructions =>
      'SPECIFIC INSTRUCTIONS:\n- Evaluate how well the student\'s response aligns with the established criteria\n- Analyze the degree of synthesis and structure in the response\n- Identify if anything important has been left out according to the criteria\n- Consider the depth and accuracy of the analysis';

  @override
  String get aiEvaluationPromptGeneralInstructions =>
      'GENERAL INSTRUCTIONS:\n- Since there are no specific criteria established, evaluate the response based on general academic standards\n- Consider clarity, coherence, and structure of the response\n- Evaluate if the response demonstrates understanding of the topic\n- Analyze the depth of analysis and quality of arguments';

  @override
  String get aiEvaluationPromptResponseFormat =>
      'RESPONSE FORMAT:\n1. GRADE: [X/10] - Briefly justify the grade\n2. STRENGTHS: Mention positive aspects of the response\n3. AREAS FOR IMPROVEMENT: Point out aspects that could be improved\n4. SPECIFIC COMMENTS: Provide detailed and constructive feedback\n5. SUGGESTIONS: Offer specific recommendations for improvement\n\nBe constructive, specific, and educational in your evaluation. The goal is to help the student learn and improve. Address them in second person and use a professional and friendly tone.';

  @override
  String get raffleTitle => 'Raffle';

  @override
  String get raffleTooltip => 'Raffle';

  @override
  String get participantListTitle => 'Participant List';

  @override
  String get participantListHint => 'Enter one name per line:';

  @override
  String get participantListPlaceholder =>
      'John Doe\nJane Smith\nBob Johnson\n...';

  @override
  String get clearList => 'Clear List';

  @override
  String get participants => 'Participants';

  @override
  String get noParticipants => 'No participants';

  @override
  String get addParticipantsHint => 'Add names in the text area';

  @override
  String get activeParticipants => 'Active Participants';

  @override
  String get alreadySelected => 'Already Selected';

  @override
  String totalParticipants(int count) {
    return 'Total: $count';
  }

  @override
  String activeVsWinners(int active, int winners) {
    return 'Active: $active | Winners: $winners';
  }

  @override
  String get startRaffle => 'Start Raffle';

  @override
  String get raffling => 'Raffling...';

  @override
  String get selectingWinner => 'Selecting winner...';

  @override
  String get allParticipantsSelected =>
      'All participants have already been selected';

  @override
  String get addParticipantsToStart => 'Add participants to start the raffle';

  @override
  String participantsReadyCount(int count) {
    return '$count participant(s) ready for raffle';
  }

  @override
  String get resetWinners => 'Reset Winners';

  @override
  String get resetWinnersConfirmTitle => 'Reset Winners';

  @override
  String get resetWinnersConfirmMessage =>
      'Are you sure you want to reset the winners list? All participants will be available for the raffle again.';

  @override
  String get resetRaffleTitle => 'Reset Raffle';

  @override
  String get resetRaffleConfirmMessage =>
      'Are you sure you want to reset the raffle? All participants and winners will be lost.';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get viewWinners => 'View winners';

  @override
  String get congratulations => '🎉 Congratulations! 🎉';

  @override
  String positionLabel(int position) {
    return 'Position: $position°';
  }

  @override
  String remainingParticipants(int count) {
    return 'Remaining participants: $count';
  }

  @override
  String get continueRaffle => 'Continue Raffle';

  @override
  String get finishRaffle => 'Finish Raffle';

  @override
  String get winnersTitle => 'Raffle Winners';

  @override
  String get shareResults => 'Share results';

  @override
  String get noWinnersYet => 'No winners yet';

  @override
  String get performRaffleToSeeWinners =>
      'Perform a raffle to see the winners here';

  @override
  String get goToRaffle => 'Go to Raffle';

  @override
  String get raffleCompleted => 'Raffle Completed';

  @override
  String winnersSelectedCount(int count) {
    return '$count winner(s) selected';
  }

  @override
  String get newRaffle => 'New Raffle';

  @override
  String get shareResultsTitle => 'Share Results';

  @override
  String get raffleResultsLabel => 'Raffle results:';

  @override
  String get close => 'Close';

  @override
  String get share => 'Copy';

  @override
  String get shareNotImplemented => 'Share functionality not implemented';

  @override
  String get firstPlace => '1st';

  @override
  String get secondPlace => '2nd';

  @override
  String get thirdPlace => '3rd';

  @override
  String nthPlace(int position) {
    return '$position°';
  }

  @override
  String placeLabel(String position) {
    return '$position place';
  }

  @override
  String get raffleResultsHeader => '🏆 RAFFLE RESULTS 🏆';

  @override
  String totalWinners(int count) {
    return 'Total winners: $count';
  }

  @override
  String get noWinnersToShare => 'No winners.';

  @override
  String get shareSuccess => 'Results copied successfully';

  @override
  String get selectLogo => 'Select Logo';

  @override
  String get logoUrl => 'Logo URL';

  @override
  String get logoUrlHint =>
      'Enter the URL of an image to use as a custom logo for the raffle';

  @override
  String get invalidLogoUrl =>
      'Invalid image URL. Must be a valid URL ending in .jpg, .png, .gif, etc.';

  @override
  String get logoPreview => 'Preview';

  @override
  String get removeLogo => 'Remove Logo';

  @override
  String get logoTooLargeWarning =>
      'Η εικόνα είναι πολύ μεγάλη για να αποθηκευτεί. Θα χρησιμοποιηθεί μόνο κατά τη διάρκεια αυτής της συνεδρίας.';
}
