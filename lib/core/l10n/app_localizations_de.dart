// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get titleAppBar => 'Quiz - Prüfungssimulator';

  @override
  String get create => 'Erstellen';

  @override
  String get preview => 'Vorschau';

  @override
  String get load => 'Laden';

  @override
  String fileLoaded(String filePath) {
    return 'Datei geladen: $filePath';
  }

  @override
  String fileSaved(String filePath) {
    return 'Datei gespeichert: $filePath';
  }

  @override
  String get dropFileHere =>
      'Hier klicken oder eine .quiz-Datei auf den Bildschirm ziehen';

  @override
  String get errorInvalidFile =>
      'Fehler: Ungültige Datei. Muss eine .quiz-Datei sein.';

  @override
  String errorLoadingFile(String error) {
    return 'Fehler beim Laden der Quiz-Datei: $error';
  }

  @override
  String errorExportingFile(String error) {
    return 'Fehler beim Exportieren der Datei: $error';
  }

  @override
  String get cancelButton => 'Abbrechen';

  @override
  String get saveButton => 'Speichern';

  @override
  String get confirmDeleteTitle => 'Löschung bestätigen';

  @override
  String confirmDeleteMessage(String processName) {
    return 'Sind Sie sicher, dass Sie den Prozess `$processName` löschen möchten?';
  }

  @override
  String get deleteButton => 'Löschen';

  @override
  String get confirmExitTitle => 'Beenden bestätigen';

  @override
  String get confirmExitMessage =>
      'Sind Sie sicher, dass Sie ohne Speichern beenden möchten?';

  @override
  String get exitButton => 'Beenden';

  @override
  String get saveDialogTitle => 'Bitte wählen Sie eine Ausgabedatei:';

  @override
  String get createQuizFileTitle => 'Quiz-Datei erstellen';

  @override
  String get fileNameLabel => 'Dateiname';

  @override
  String get fileDescriptionLabel => 'Dateibeschreibung';

  @override
  String get createButton => 'Erstellen';

  @override
  String get fileNameRequiredError => 'Der Dateiname ist erforderlich.';

  @override
  String get fileDescriptionRequiredError =>
      'Die Dateibeschreibung ist erforderlich.';

  @override
  String get versionLabel => 'Version';

  @override
  String get authorLabel => 'Autor';

  @override
  String get authorRequiredError => 'Der Autor ist erforderlich.';

  @override
  String get requiredFieldsError =>
      'Alle erforderlichen Felder müssen ausgefüllt werden.';

  @override
  String get requestFileNameTitle => 'Geben Sie den Quiz-Dateinamen ein';

  @override
  String get fileNameHint => 'Dateiname';

  @override
  String get emptyFileNameMessage => 'Der Dateiname darf nicht leer sein.';

  @override
  String get acceptButton => 'Akzeptieren';

  @override
  String get saveTooltip => 'Datei speichern';

  @override
  String get saveDisabledTooltip => 'Keine Änderungen zu speichern';

  @override
  String get executeTooltip => 'Prüfung ausführen';

  @override
  String get addTooltip => 'Neue Frage hinzufügen';

  @override
  String get backSemanticLabel => 'Zurück-Schaltfläche';

  @override
  String get createFileTooltip => 'Neue Quiz-Datei erstellen';

  @override
  String get loadFileTooltip => 'Vorhandene Quiz-Datei laden';

  @override
  String questionNumber(int number) {
    return 'Frage $number';
  }

  @override
  String get previous => 'Zurück';

  @override
  String get next => 'Weiter';

  @override
  String get finish => 'Beenden';

  @override
  String get finishQuiz => 'Quiz beenden';

  @override
  String get finishQuizConfirmation =>
      'Sind Sie sicher, dass Sie das Quiz beenden möchten? Sie können Ihre Antworten danach nicht mehr ändern.';

  @override
  String get abandonQuiz => 'Quiz aufgeben';

  @override
  String get abandonQuizConfirmation =>
      'Sind Sie sicher, dass Sie das Quiz aufgeben möchten? Der gesamte Fortschritt geht verloren.';

  @override
  String get abandon => 'Aufgeben';

  @override
  String get quizCompleted => 'Quiz abgeschlossen!';

  @override
  String score(String score) {
    return 'Punktzahl: $score%';
  }

  @override
  String correctAnswers(int correct, int total) {
    return '$correct von $total richtige Antworten';
  }

  @override
  String get retry => 'Wiederholen';

  @override
  String get goBack => 'Beenden';

  @override
  String get retryFailedQuestions => 'Fehlgeschlagene wiederholen';

  @override
  String question(String question) {
    return 'Frage: $question';
  }

  @override
  String get selectQuestionCountTitle => 'Anzahl der Fragen auswählen';

  @override
  String get selectQuestionCountMessage =>
      'Wie viele Fragen möchten Sie in diesem Quiz beantworten?';

  @override
  String allQuestions(int count) {
    return 'Alle Fragen ($count)';
  }

  @override
  String get startQuiz => 'Quiz starten';

  @override
  String get errorInvalidNumber => 'Bitte geben Sie eine gültige Zahl ein';

  @override
  String get errorNumberMustBePositive => 'Die Zahl muss größer als 0 sein';

  @override
  String get customNumberLabel =>
      'Oder geben Sie eine benutzerdefinierte Zahl ein:';

  @override
  String customNumberHelper(int total) {
    return 'Geben Sie eine beliebige Zahl ein (max $total). Bei höherer Zahl wiederholen sich die Fragen.';
  }

  @override
  String get numberInputLabel => 'Anzahl der Fragen';

  @override
  String get questionOrderConfigTitle => 'Fragenreihenfolge-Konfiguration';

  @override
  String get questionOrderConfigDescription =>
      'Wählen Sie die Reihenfolge, in der die Fragen während der Prüfung erscheinen sollen:';

  @override
  String get questionOrderAscending => 'Aufsteigende Reihenfolge';

  @override
  String get questionOrderAscendingDesc =>
      'Fragen erscheinen in der Reihenfolge von 1 bis zum Ende';

  @override
  String get questionOrderDescending => 'Absteigende Reihenfolge';

  @override
  String get questionOrderDescendingDesc => 'Fragen erscheinen vom Ende bis 1';

  @override
  String get questionOrderRandom => 'Zufällig';

  @override
  String get questionOrderRandomDesc =>
      'Fragen erscheinen in zufälliger Reihenfolge';

  @override
  String get questionOrderConfigTooltip => 'Fragenreihenfolge-Konfiguration';

  @override
  String get save => 'Speichern';

  @override
  String get examTimeLimitTitle => 'Prüfungszeit-Limit';

  @override
  String get examTimeLimitDescription =>
      'Setzen Sie ein Zeitlimit für die Prüfung. Wenn aktiviert, wird während des Quiz ein Countdown-Timer angezeigt.';

  @override
  String get enableTimeLimit => 'Zeitlimit aktivieren';

  @override
  String get timeLimitMinutes => 'Zeitlimit (Minuten)';

  @override
  String get examTimeExpiredTitle => 'Zeit abgelaufen!';

  @override
  String get examTimeExpiredMessage =>
      'Die Prüfungszeit ist abgelaufen. Ihre Antworten wurden automatisch übermittelt.';

  @override
  String remainingTime(String hours, String minutes, String seconds) {
    return '$hours:$minutes:$seconds';
  }

  @override
  String get questionTypeMultipleChoice => 'Mehrfachauswahl';

  @override
  String get questionTypeSingleChoice => 'Einfachauswahl';

  @override
  String get questionTypeTrueFalse => 'Wahr/Falsch';

  @override
  String get questionTypeEssay => 'Aufsatz';

  @override
  String get questionTypeUnknown => 'Unbekannt';

  @override
  String optionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Optionen',
      one: '1 Option',
    );
    return '$_temp0';
  }

  @override
  String get optionsTooltip => 'Anzahl der Antwortoptionen für diese Frage';

  @override
  String get imageTooltip => 'Diese Frage hat ein zugehöriges Bild';

  @override
  String get explanationTooltip => 'Diese Frage hat eine Erklärung';

  @override
  String get aiPrompt =>
      'Sie sind ein erfahrener und freundlicher Tutor, der sich darauf spezialisiert hat, Studenten beim besseren Verständnis von Prüfungsfragen und verwandten Themen zu helfen. Ihr Ziel ist es, tiefgreifendes Lernen und konzeptionelles Verständnis zu fördern.\n\nSie können bei folgenden Punkten helfen:\n- Erklärung von Konzepten im Zusammenhang mit der Frage\n- Klärung von Zweifeln bezüglich Antwortoptionen\n- Bereitstellung zusätzlicher Kontextinformationen zum Thema\n- Vorschlag ergänzender Lernressourcen\n- Erklärung, warum bestimmte Antworten richtig oder falsch sind\n- Verknüpfung des Themas mit anderen wichtigen Konzepten\n- Beantwortung von Anschlussfragen zum Material\n\nAntworten Sie immer in derselben Sprache, in der Sie gefragt werden. Seien Sie pädagogisch, klar und motivierend in Ihren Erklärungen.';

  @override
  String get questionLabel => 'Frage';

  @override
  String get studentComment => 'Kommentar des Studenten';

  @override
  String get aiAssistantTitle => 'KI-Lernassistent';

  @override
  String get questionContext => 'Fragenkontext';

  @override
  String get aiAssistant => 'KI-Assistent';

  @override
  String get aiThinking => 'KI denkt nach...';

  @override
  String get askAIHint => 'Stellen Sie Ihre Frage zu diesem Thema...';

  @override
  String get aiPlaceholderResponse =>
      'Dies ist eine Platzhalter-Antwort. In einer echten Implementierung würde dies sich mit einem KI-Service verbinden, um hilfreiche Erklärungen zur Frage zu liefern.';

  @override
  String get aiErrorResponse =>
      'Entschuldigung, bei der Verarbeitung Ihrer Frage ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut.';

  @override
  String get configureApiKeyMessage =>
      'Bitte konfigurieren Sie Ihren KI-API-Schlüssel in den Einstellungen.';

  @override
  String get errorLabel => 'Fehler:';

  @override
  String get noResponseReceived => 'Keine Antwort erhalten';

  @override
  String get invalidApiKeyError =>
      'Ungültiger API-Schlüssel. Bitte überprüfen Sie Ihren OpenAI-API-Schlüssel in den Einstellungen.';

  @override
  String get rateLimitError =>
      'Rate-Limit überschritten. Bitte versuchen Sie es später erneut.';

  @override
  String get modelNotFoundError =>
      'Modell nicht gefunden. Bitte überprüfen Sie Ihren API-Zugang.';

  @override
  String get unknownError => 'Unbekannter Fehler';

  @override
  String get networkError =>
      'Netzwerkfehler: Verbindung zu OpenAI nicht möglich. Bitte überprüfen Sie Ihre Internetverbindung.';

  @override
  String get openaiApiKeyNotConfigured =>
      'OpenAI-API-Schlüssel nicht konfiguriert';

  @override
  String get geminiApiKeyNotConfigured =>
      'Gemini-API-Schlüssel nicht konfiguriert';

  @override
  String get geminiApiKeyLabel => 'Gemini API-Schlüssel';

  @override
  String get geminiApiKeyHint => 'Geben Sie Ihren Gemini-API-Schlüssel ein';

  @override
  String get geminiApiKeyDescription =>
      'Erforderlich für Gemini-KI-Funktionalität. Ihr Schlüssel wird sicher gespeichert.';

  @override
  String get getGeminiApiKeyTooltip =>
      'API-Schlüssel von Google AI Studio erhalten';

  @override
  String get aiRequiresAtLeastOneApiKeyError =>
      'KI-Lernassistent benötigt mindestens einen API-Schlüssel (OpenAI oder Gemini). Bitte geben Sie einen API-Schlüssel ein oder deaktivieren Sie den KI-Assistenten.';

  @override
  String get minutesAbbreviation => 'min';

  @override
  String get aiButtonTooltip => 'KI-Lernassistent';

  @override
  String get aiButtonText => 'KI';

  @override
  String get aiAssistantSettingsTitle => 'KI-Lernassistent (Vorschau)';

  @override
  String get aiAssistantSettingsDescription =>
      'KI-Lernassistenten für Fragen aktivieren oder deaktivieren';

  @override
  String get openaiApiKeyLabel => 'OpenAI-API-Schlüssel';

  @override
  String get openaiApiKeyHint =>
      'Geben Sie Ihren OpenAI-API-Schlüssel ein (sk-...)';

  @override
  String get openaiApiKeyDescription =>
      'Erforderlich für die Integration mit OpenAI. Ihr OpenAI-Schlüssel wird sicher gespeichert.';

  @override
  String get aiAssistantRequiresApiKeyError =>
      'KI-Lernassistent benötigt einen OpenAI-API-Schlüssel. Bitte geben Sie Ihren API-Schlüssel ein oder deaktivieren Sie den KI-Assistenten.';

  @override
  String get getApiKeyTooltip => 'API-Schlüssel von OpenAI erhalten';

  @override
  String get deleteAction => 'Löschen';

  @override
  String get explanationLabel => 'Erklärung (optional)';

  @override
  String get explanationHint =>
      'Geben Sie eine Erklärung für die richtige(n) Antwort(en) ein';

  @override
  String get explanationTitle => 'Erklärung';

  @override
  String get imageLabel => 'Bild';

  @override
  String get changeImage => 'Bild ändern';

  @override
  String get removeImage => 'Bild entfernen';

  @override
  String get addImageTap => 'Tippen Sie, um ein Bild hinzuzufügen';

  @override
  String get imageFormats => 'Formate: JPG, PNG, GIF';

  @override
  String get imageLoadError => 'Fehler beim Laden des Bildes';

  @override
  String imagePickError(String error) {
    return 'Fehler beim Laden des Bildes: $error';
  }

  @override
  String get tapToZoom => 'Tippen zum Zoomen';

  @override
  String get trueLabel => 'Wahr';

  @override
  String get falseLabel => 'Falsch';

  @override
  String get addQuestion => 'Frage hinzufügen';

  @override
  String get editQuestion => 'Frage bearbeiten';

  @override
  String get questionText => 'Fragentext';

  @override
  String get questionType => 'Fragentyp';

  @override
  String get addOption => 'Option hinzufügen';

  @override
  String get optionsLabel => 'Optionen';

  @override
  String get optionLabel => 'Option';

  @override
  String get questionTextRequired => 'Fragentext ist erforderlich';

  @override
  String get atLeastOneOptionRequired =>
      'Mindestens eine Option muss Text haben';

  @override
  String get atLeastOneCorrectAnswerRequired =>
      'Mindestens eine richtige Antwort muss ausgewählt werden';

  @override
  String get onlyOneCorrectAnswerAllowed =>
      'Nur eine richtige Antwort ist für diesen Fragentyp erlaubt';

  @override
  String get removeOption => 'Option entfernen';

  @override
  String get selectCorrectAnswer => 'Richtige Antwort auswählen';

  @override
  String get selectCorrectAnswers => 'Richtige Antworten auswählen';

  @override
  String emptyOptionsError(String optionNumbers) {
    return 'Optionen $optionNumbers sind leer. Bitte fügen Sie Text hinzu oder entfernen Sie sie.';
  }

  @override
  String emptyOptionError(String optionNumber) {
    return 'Option $optionNumber ist leer. Bitte fügen Sie Text hinzu oder entfernen Sie sie.';
  }

  @override
  String get optionEmptyError => 'Diese Option darf nicht leer sein';

  @override
  String get hasImage => 'Bild';

  @override
  String get hasExplanation => 'Erklärung';

  @override
  String errorLoadingSettings(String error) {
    return 'Fehler beim Laden der Einstellungen: $error';
  }

  @override
  String couldNotOpenUrl(String url) {
    return 'Konnte $url nicht öffnen';
  }

  @override
  String get loadingAiServices => 'KI-Services werden geladen...';

  @override
  String usingAiService(String serviceName) {
    return 'Verwende: $serviceName';
  }

  @override
  String get aiServiceLabel => 'KI-Service:';

  @override
  String get importQuestionsTitle => 'Fragen importieren';

  @override
  String importQuestionsMessage(int count, String fileName) {
    return '$count Fragen in \"$fileName\" gefunden. Wo möchten Sie sie importieren?';
  }

  @override
  String get importQuestionsPositionQuestion =>
      'Wo möchten Sie diese Fragen hinzufügen?';

  @override
  String get importAtBeginning => 'Am Anfang';

  @override
  String get importAtEnd => 'Am Ende';

  @override
  String questionsImportedSuccess(int count) {
    return 'Erfolgreich $count Fragen importiert';
  }

  @override
  String get importQuestionsTooltip =>
      'Fragen aus einer anderen Quiz-Datei importieren';

  @override
  String get dragDropHintText =>
      'Sie können auch .quiz-Dateien hierher ziehen und ablegen, um Fragen zu importieren';

  @override
  String get randomizeAnswersTitle => 'Antwortoptionen randomisieren';

  @override
  String get randomizeAnswersDescription =>
      'Reihenfolge der Antwortoptionen während der Quiz-Ausführung mischen';

  @override
  String get showCorrectAnswerCountTitle =>
      'Anzahl richtiger Antworten anzeigen';

  @override
  String get showCorrectAnswerCountDescription =>
      'Anzahl der richtigen Antworten in Mehrfachauswahl-Fragen anzeigen';

  @override
  String correctAnswersCount(int count) {
    return 'Wählen Sie $count richtige Antworten';
  }

  @override
  String get correctSelectedLabel => 'Richtig';

  @override
  String get correctMissedLabel => 'Richtig';

  @override
  String get incorrectSelectedLabel => 'Falsch';

  @override
  String get aiGenerateDialogTitle => 'Fragen mit KI generieren';

  @override
  String get aiQuestionCountLabel => 'Anzahl der Fragen (Optional)';

  @override
  String get aiQuestionCountHint => 'Leer lassen, damit KI entscheidet';

  @override
  String get aiQuestionCountValidation =>
      'Muss eine Zahl zwischen 1 und 50 sein';

  @override
  String get aiQuestionTypeLabel => 'Fragentyp';

  @override
  String get aiQuestionTypeRandom => 'Zufällig (Gemischt)';

  @override
  String get aiLanguageLabel => 'Fragensprache';

  @override
  String get aiContentLabel => 'Inhalt für die Fragengenerierung';

  @override
  String aiWordCount(int current, int max) {
    return '$current / $max Wörter';
  }

  @override
  String get aiContentHint =>
      'Geben Sie den Text, das Thema oder den Inhalt ein, aus dem Sie Fragen generieren möchten...';

  @override
  String get aiContentHelperText =>
      'KI wird basierend auf diesem Inhalt Fragen erstellen';

  @override
  String aiWordLimitError(int max) {
    return 'Sie haben das Limit von $max Wörtern überschritten';
  }

  @override
  String get aiContentRequiredError =>
      'Sie müssen Inhalt bereitstellen, um Fragen zu generieren';

  @override
  String aiContentLimitError(int max) {
    return 'Inhalt überschreitet das Limit von $max Wörtern';
  }

  @override
  String get aiMinWordsError =>
      'Geben Sie mindestens 10 Wörter an, um qualitativ hochwertige Fragen zu generieren';

  @override
  String get aiInfoTitle => 'Information';

  @override
  String get aiInfoDescription =>
      '• KI wird den Inhalt analysieren und relevante Fragen generieren\n• Sie können Text, Definitionen, Erklärungen oder beliebiges Lernmaterial einschließen\n• Fragen werden Antwortoptionen und Erklärungen beinhalten\n• Der Vorgang kann einige Sekunden dauern';

  @override
  String get aiGenerateButton => 'Fragen generieren';

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
  String get aiServicesLoading => 'KI-Services werden geladen...';

  @override
  String get aiServicesNotConfigured => 'Keine KI-Services konfiguriert';

  @override
  String get aiGeneratedQuestions => 'KI-generiert';

  @override
  String get aiApiKeyRequired =>
      'Bitte konfigurieren Sie mindestens einen KI-API-Schlüssel in den Einstellungen, um KI-Generierung zu verwenden.';

  @override
  String get aiGenerationFailed =>
      'Fragen konnten nicht generiert werden. Versuchen Sie es mit anderem Inhalt.';

  @override
  String aiGenerationError(String error) {
    return 'Fehler beim Generieren von Fragen: $error';
  }

  @override
  String get noQuestionsInFile =>
      'Keine Fragen in der importierten Datei gefunden';

  @override
  String get couldNotAccessFile =>
      'Zugriff auf die ausgewählte Datei nicht möglich';

  @override
  String get defaultOutputFileName => 'ausgabe-datei.quiz';

  @override
  String get generateQuestionsWithAI => 'Fragen mit KI generieren';

  @override
  String aiServiceLimitsWithChars(int words, int chars) {
    return 'Limit: $words Wörter oder $chars Zeichen';
  }

  @override
  String aiServiceLimitsWordsOnly(int words) {
    return 'Limit: $words Wörter';
  }

  @override
  String get aiAssistantDisabled => 'KI-Assistent Deaktiviert';

  @override
  String get enableAiAssistant =>
      'KI-Assistent ist deaktiviert. Bitte aktivieren Sie ihn in den Einstellungen, um KI-Funktionen zu nutzen.';

  @override
  String aiMinWordsRequired(int minWords) {
    return 'Mindestens $minWords Wörter erforderlich';
  }

  @override
  String aiWordsReadyToGenerate(int wordCount) {
    return '$wordCount Wörter ✓ Bereit zu generieren';
  }

  @override
  String aiWordsProgress(int currentWords, int minWords, int moreNeeded) {
    return '$currentWords/$minWords Wörter ($moreNeeded weitere benötigt)';
  }

  @override
  String aiValidationMinWords(int minWords, int moreNeeded) {
    return 'Mindestens $minWords Wörter erforderlich ($moreNeeded weitere benötigt)';
  }

  @override
  String get enableQuestion => 'Frage aktivieren';

  @override
  String get disableQuestion => 'Frage deaktivieren';

  @override
  String get questionDisabled => 'Deaktiviert';

  @override
  String get noEnabledQuestionsError =>
      'Keine aktivierten Fragen verfügbar, um das Quiz zu starten';

  @override
  String get evaluateWithAI => 'Mit KI bewerten';

  @override
  String get aiEvaluation => 'KI-Bewertung';

  @override
  String aiEvaluationError(String error) {
    return 'Fehler beim Bewerten der Antwort: $error';
  }

  @override
  String get aiEvaluationPromptSystemRole =>
      'Sie sind ein Experte-Lehrer, der die Antwort eines Studenten auf eine Essay-Frage bewertet. Ihre Aufgabe ist es, eine detaillierte und konstruktive Bewertung zu geben. Bitte antworten Sie auf Deutsch.';

  @override
  String get aiEvaluationPromptQuestion => 'FRAGE:';

  @override
  String get aiEvaluationPromptStudentAnswer => 'ANTWORT DES STUDENTEN:';

  @override
  String get aiEvaluationPromptCriteria =>
      'BEWERTUNGSKRITERIEN (basierend auf der Erklärung des Lehrers):';

  @override
  String get aiEvaluationPromptSpecificInstructions =>
      'SPEZIFISCHE ANWEISUNGEN:\n- Bewerten Sie, wie gut die Antwort des Studenten mit den etablierten Kriterien übereinstimmt\n- Analysieren Sie den Grad der Synthese und Struktur in der Antwort\n- Identifizieren Sie, ob etwas Wichtiges gemäß den Kriterien ausgelassen wurde\n- Berücksichtigen Sie die Tiefe und Genauigkeit der Analyse';

  @override
  String get aiEvaluationPromptGeneralInstructions =>
      'ALLGEMEINE ANWEISUNGEN:\n- Da keine spezifischen Kriterien festgelegt sind, bewerten Sie die Antwort basierend auf allgemeinen akademischen Standards\n- Berücksichtigen Sie Klarheit, Kohärenz und Struktur der Antwort\n- Bewerten Sie, ob die Antwort Verständnis des Themas zeigt\n- Analysieren Sie die Tiefe der Analyse und Qualität der Argumente';

  @override
  String get aiEvaluationPromptResponseFormat =>
      'ANTWORTFORMAT:\n1. BEWERTUNG: [X/10] - Begründen Sie kurz die Note\n2. STÄRKEN: Erwähnen Sie positive Aspekte der Antwort\n3. VERBESSERUNGSBEREICHE: Weisen Sie auf Aspekte hin, die verbessert werden könnten\n4. SPEZIFISCHE KOMMENTARE: Geben Sie detailliertes und konstruktives Feedback\n5. VORSCHLÄGE: Bieten Sie spezifische Empfehlungen zur Verbesserung\n\nSeien Sie konstruktiv, spezifisch und lehrreich in Ihrer Bewertung. Das Ziel ist es, dem Studenten beim Lernen und Verbessern zu helfen. Sprechen Sie ihn in der zweiten Person an und verwenden Sie einen professionellen und freundlichen Ton.';

  @override
  String get raffleTitle => 'Verlosung';

  @override
  String get raffleTooltip => 'Verlosung';

  @override
  String get participantListTitle => 'Teilnehmerliste';

  @override
  String get participantListHint => 'Geben Sie einen Namen pro Zeile ein:';

  @override
  String get participantListPlaceholder =>
      'Max Mustermann\nErika Musterfrau\nHans Schmidt\n...';

  @override
  String get clearList => 'Liste löschen';

  @override
  String get participants => 'Teilnehmer';

  @override
  String get noParticipants => 'Keine Teilnehmer';

  @override
  String get addParticipantsHint => 'Fügen Sie Namen im Textbereich hinzu';

  @override
  String get activeParticipants => 'Aktive Teilnehmer';

  @override
  String get alreadySelected => 'Bereits ausgewählt';

  @override
  String totalParticipants(int count) {
    return 'Gesamt: $count';
  }

  @override
  String activeVsWinners(int active, int winners) {
    return 'Aktiv: $active | Gewinner: $winners';
  }

  @override
  String get startRaffle => 'Verlosung starten';

  @override
  String get raffling => 'Verlosung läuft...';

  @override
  String get selectingWinner => 'Gewinner wird ausgewählt...';

  @override
  String get allParticipantsSelected =>
      'Alle Teilnehmer wurden bereits ausgewählt';

  @override
  String get addParticipantsToStart =>
      'Fügen Sie Teilnehmer hinzu, um die Verlosung zu starten';

  @override
  String participantsReadyCount(int count) {
    return '$count Teilnehmer bereit für Verlosung';
  }

  @override
  String get resetWinners => 'Gewinner zurücksetzen';

  @override
  String get resetWinnersConfirmTitle => 'Gewinner zurücksetzen';

  @override
  String get resetWinnersConfirmMessage =>
      'Sind Sie sicher, dass Sie die Gewinnerliste zurücksetzen möchten? Alle Teilnehmer werden wieder für die Verlosung verfügbar sein.';

  @override
  String get resetRaffleTitle => 'Verlosung zurücksetzen';

  @override
  String get resetRaffleConfirmMessage =>
      'Sind Sie sicher, dass Sie die Verlosung zurücksetzen möchten? Alle Teilnehmer und Gewinner gehen verloren.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get viewWinners => 'Gewinner anzeigen';

  @override
  String get congratulations => '🎉 Herzlichen Glückwunsch! 🎉';

  @override
  String positionLabel(int position) {
    return 'Position: $position°';
  }

  @override
  String remainingParticipants(int count) {
    return 'Verbleibende Teilnehmer: $count';
  }

  @override
  String get continueRaffle => 'Verlosung fortsetzen';

  @override
  String get finishRaffle => 'Verlosung beenden';

  @override
  String get winnersTitle => 'Verlosungsgewinner';

  @override
  String get shareResults => 'Ergebnisse teilen';

  @override
  String get noWinnersYet => 'Noch keine Gewinner';

  @override
  String get performRaffleToSeeWinners =>
      'Führen Sie eine Verlosung durch, um die Gewinner hier zu sehen';

  @override
  String get goToRaffle => 'Zur Verlosung';

  @override
  String get raffleCompleted => 'Verlosung abgeschlossen';

  @override
  String winnersSelectedCount(int count) {
    return '$count Gewinner ausgewählt';
  }

  @override
  String get newRaffle => 'Neue Verlosung';

  @override
  String get shareResultsTitle => 'Ergebnisse teilen';

  @override
  String get raffleResultsLabel => 'Verlosungsergebnisse:';

  @override
  String get close => 'Schließen';

  @override
  String get share => 'Kopieren';

  @override
  String get shareNotImplemented => 'Teilen-Funktion nicht implementiert';

  @override
  String get firstPlace => '1.';

  @override
  String get secondPlace => '2.';

  @override
  String get thirdPlace => '3.';

  @override
  String nthPlace(int position) {
    return '$position.';
  }

  @override
  String placeLabel(String position) {
    return '$position Platz';
  }

  @override
  String get raffleResultsHeader => '🏆 VERLOSUNGSERGEBNISSE 🏆';

  @override
  String totalWinners(int count) {
    return 'Gewinner gesamt: $count';
  }

  @override
  String get noWinnersToShare => 'Keine Gewinner.';

  @override
  String get shareSuccess => 'Ergebnisse erfolgreich kopiert';

  @override
  String get selectLogo => 'Logo auswählen';

  @override
  String get logoUrl => 'Logo-URL';

  @override
  String get logoUrlHint =>
      'Geben Sie die URL eines Bildes ein, das als benutzerdefiniertes Logo für die Verlosung verwendet werden soll';

  @override
  String get invalidLogoUrl =>
      'Ungültige Bild-URL. Muss eine gültige URL sein, die mit .jpg, .png, .gif usw. endet.';

  @override
  String get logoPreview => 'Vorschau';

  @override
  String get removeLogo => 'Logo entfernen';

  @override
  String get logoTooLargeWarning =>
      'Das Bild ist zu groß zum Speichern. Es wird nur während dieser Sitzung verwendet.';
}
