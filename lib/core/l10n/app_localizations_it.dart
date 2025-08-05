// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get titleAppBar => 'Quiz - Simulatore d\'Esame';

  @override
  String get create => 'Crea';

  @override
  String get load => 'Carica';

  @override
  String fileLoaded(String filePath) {
    return 'File caricato: $filePath';
  }

  @override
  String fileSaved(String filePath) {
    return 'File salvato: $filePath';
  }

  @override
  String get dropFileHere =>
      'Clicca qui o trascina un file .quiz sullo schermo';

  @override
  String get errorInvalidFile =>
      'Errore: File non valido. Deve essere un file .quiz.';

  @override
  String errorLoadingFile(String error) {
    return 'Errore nel caricamento del file Quiz: $error';
  }

  @override
  String errorExportingFile(String error) {
    return 'Errore nell\'esportazione del file: $error';
  }

  @override
  String get cancelButton => 'Annulla';

  @override
  String get saveButton => 'Salva';

  @override
  String get confirmDeleteTitle => 'Conferma Eliminazione';

  @override
  String confirmDeleteMessage(String processName) {
    return 'Sei sicuro di voler eliminare il processo `$processName`?';
  }

  @override
  String get deleteButton => 'Elimina';

  @override
  String get confirmExitTitle => 'Conferma Uscita';

  @override
  String get confirmExitMessage => 'Sei sicuro di voler uscire senza salvare?';

  @override
  String get exitButton => 'Esci';

  @override
  String get saveDialogTitle => 'Seleziona un file di output:';

  @override
  String get createQuizFileTitle => 'Crea File Quiz';

  @override
  String get fileNameLabel => 'Nome File';

  @override
  String get fileDescriptionLabel => 'Descrizione File';

  @override
  String get createButton => 'Crea';

  @override
  String get fileNameRequiredError => 'Il nome del file è obbligatorio.';

  @override
  String get fileDescriptionRequiredError =>
      'La descrizione del file è obbligatoria.';

  @override
  String get versionLabel => 'Versione';

  @override
  String get authorLabel => 'Autore';

  @override
  String get authorRequiredError => 'L\'autore è obbligatorio.';

  @override
  String get requiredFieldsError =>
      'Tutti i campi obbligatori devono essere completati.';

  @override
  String get requestFileNameTitle => 'Inserisci il nome del file Quiz';

  @override
  String get fileNameHint => 'Nome file';

  @override
  String get emptyFileNameMessage => 'Il nome del file non può essere vuoto.';

  @override
  String get acceptButton => 'Accetta';

  @override
  String get saveTooltip => 'Salva il file';

  @override
  String get saveDisabledTooltip => 'Nessuna modifica da salvare';

  @override
  String get executeTooltip => 'Esegui l\'esame';

  @override
  String get addTooltip => 'Aggiungi una nuova domanda';

  @override
  String get backSemanticLabel => 'Pulsante indietro';

  @override
  String get createFileTooltip => 'Crea un nuovo file Quiz';

  @override
  String get loadFileTooltip => 'Carica un file Quiz esistente';

  @override
  String questionNumber(int number) {
    return 'Domanda $number';
  }

  @override
  String get previous => 'Precedente';

  @override
  String get next => 'Successivo';

  @override
  String get finish => 'Termina';

  @override
  String get finishQuiz => 'Termina Quiz';

  @override
  String get finishQuizConfirmation =>
      'Sei sicuro di voler terminare il quiz? Non potrai più modificare le tue risposte dopo.';

  @override
  String get cancel => 'Annulla';

  @override
  String get abandonQuiz => 'Abbandona Quiz';

  @override
  String get abandonQuizConfirmation =>
      'Sei sicuro di voler abbandonare il quiz? Tutti i progressi andranno persi.';

  @override
  String get abandon => 'Abbandona';

  @override
  String get quizCompleted => 'Quiz Completato!';

  @override
  String score(String score) {
    return 'Punteggio: $score%';
  }

  @override
  String correctAnswers(int correct, int total) {
    return '$correct di $total risposte corrette';
  }

  @override
  String get retry => 'Ripeti';

  @override
  String get goBack => 'Termina';

  @override
  String get retryFailedQuestions => 'Riprova Sbagliate';

  @override
  String question(String question) {
    return 'Domanda: $question';
  }

  @override
  String get selectQuestionCountTitle => 'Seleziona Numero di Domande';

  @override
  String get selectQuestionCountMessage =>
      'A quante domande vorresti rispondere in questo quiz?';

  @override
  String allQuestions(int count) {
    return 'Tutte le domande ($count)';
  }

  @override
  String get startQuiz => 'Inizia Quiz';

  @override
  String get customNumberLabel => 'O inserisci un numero personalizzato:';

  @override
  String get numberInputLabel => 'Numero di domande';

  @override
  String customNumberHelper(int total) {
    return 'Inserisci qualsiasi numero (max $total). Se superiore, le domande si ripeteranno.';
  }

  @override
  String get errorInvalidNumber => 'Inserisci un numero valido';

  @override
  String get errorNumberMustBePositive => 'Il numero deve essere maggiore di 0';

  @override
  String get questionOrderConfigTitle => 'Configurazione Ordine Domande';

  @override
  String get questionOrderConfigDescription =>
      'Seleziona l\'ordine in cui vuoi che le domande appaiano durante l\'esame:';

  @override
  String get questionOrderAscending => 'Ordine Crescente';

  @override
  String get questionOrderAscendingDesc =>
      'Le domande appariranno in ordine da 1 alla fine';

  @override
  String get questionOrderDescending => 'Ordine Decrescente';

  @override
  String get questionOrderDescendingDesc =>
      'Le domande appariranno dalla fine a 1';

  @override
  String get questionOrderRandom => 'Casuale';

  @override
  String get questionOrderRandomDesc =>
      'Le domande appariranno in ordine casuale';

  @override
  String get questionOrderConfigTooltip => 'Configurazione ordine domande';

  @override
  String get save => 'Salva';

  @override
  String get examTimeLimitTitle => 'Limite di Tempo Esame';

  @override
  String get examTimeLimitDescription =>
      'Imposta un limite di tempo per l\'esame. Quando abilitato, verrà visualizzato un timer di conto alla rovescia durante il quiz.';

  @override
  String get enableTimeLimit => 'Abilita limite di tempo';

  @override
  String get timeLimitMinutes => 'Limite di tempo (minuti)';

  @override
  String get examTimeExpiredTitle => 'Tempo Scaduto!';

  @override
  String get examTimeExpiredMessage =>
      'Il tempo dell\'esame è scaduto. Le tue risposte sono state automaticamente inviate.';

  @override
  String remainingTime(String hours, String minutes, String seconds) {
    return '$hours:$minutes:$seconds';
  }

  @override
  String get questionTypeMultipleChoice => 'Scelta Multipla';

  @override
  String get questionTypeSingleChoice => 'Scelta Singola';

  @override
  String get questionTypeTrueFalse => 'Vero/Falso';

  @override
  String get questionTypeEssay => 'Saggio';

  @override
  String get questionTypeUnknown => 'Sconosciuto';

  @override
  String optionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opzioni',
      one: '1 opzione',
    );
    return '$_temp0';
  }

  @override
  String get optionsTooltip =>
      'Numero di opzioni di risposta per questa domanda';

  @override
  String get imageTooltip => 'Questa domanda ha un\'immagine associata';

  @override
  String get explanationTooltip => 'Questa domanda ha una spiegazione';

  @override
  String get aiPrompt =>
      'Sei un tutor esperto e amichevole specializzato nell\'aiutare gli studenti a comprendere meglio le domande d\'esame e gli argomenti correlati. Il tuo obiettivo è facilitare l\'apprendimento profondo e la comprensione concettuale.\n\nPuoi aiutare con:\n- Spiegare concetti relativi alla domanda\n- Chiarire dubbi sulle opzioni di risposta\n- Fornire contesto aggiuntivo sull\'argomento\n- Suggerire risorse di studio complementari\n- Spiegare perché certe risposte sono corrette o errate\n- Collegare l\'argomento ad altri concetti importanti\n- Rispondere a domande di approfondimento sul materiale\n\nRispondi sempre nella stessa lingua in cui ti viene posta la domanda. Sii pedagogico, chiaro e motivante nelle tue spiegazioni.';

  @override
  String get questionLabel => 'Domanda';

  @override
  String get optionsLabel => 'Opzioni';

  @override
  String get explanationLabel => 'Spiegazione (opzionale)';

  @override
  String get studentComment => 'Commento studente';

  @override
  String get aiAssistantTitle => 'Assistente di Studio IA';

  @override
  String get questionContext => 'Contesto Domanda';

  @override
  String get aiAssistant => 'Assistente IA';

  @override
  String get aiThinking => 'L\'IA sta pensando...';

  @override
  String get askAIHint => 'Fai la tua domanda su questo argomento...';

  @override
  String get aiPlaceholderResponse =>
      'Questa è una risposta segnaposto. In un\'implementazione reale, questo si connetterebbe a un servizio IA per fornire spiegazioni utili sulla domanda.';

  @override
  String get aiErrorResponse =>
      'Scusa, si è verificato un errore nell\'elaborazione della tua domanda. Riprova.';

  @override
  String get configureApiKeyMessage =>
      'Configura la tua chiave API IA nelle Impostazioni.';

  @override
  String get errorLabel => 'Errore:';

  @override
  String get noResponseReceived => 'Nessuna risposta ricevuta';

  @override
  String get invalidApiKeyError =>
      'Chiave API non valida. Controlla la tua chiave API OpenAI nelle impostazioni.';

  @override
  String get rateLimitError =>
      'Limite di velocità superato. Riprova più tardi.';

  @override
  String get modelNotFoundError =>
      'Modello non trovato. Controlla il tuo accesso API.';

  @override
  String get unknownError => 'Errore sconosciuto';

  @override
  String get networkError =>
      'Errore di rete: Impossibile connettersi a OpenAI. Controlla la tua connessione internet.';

  @override
  String get openaiApiKeyNotConfigured => 'Chiave API OpenAI non configurata';

  @override
  String get geminiApiKeyNotConfigured => 'Chiave API Gemini non configurata';

  @override
  String get geminiApiKeyLabel => 'Chiave API Google Gemini';

  @override
  String get geminiApiKeyHint => 'Inserisci la tua chiave API Gemini';

  @override
  String get geminiApiKeyDescription =>
      'Richiesta per la funzionalità IA Gemini. La tua chiave è memorizzata in sicurezza.';

  @override
  String get getGeminiApiKeyTooltip =>
      'Ottieni la chiave API da Google AI Studio';

  @override
  String get aiRequiresAtLeastOneApiKeyError =>
      'L\'Assistente di Studio IA richiede almeno una chiave API (OpenAI o Gemini). Inserisci una chiave API o disabilita l\'Assistente IA.';

  @override
  String get minutesAbbreviation => 'min';

  @override
  String get aiButtonTooltip => 'Assistente di Studio IA';

  @override
  String get aiButtonText => 'IA';

  @override
  String get aiAssistantSettingsTitle => 'Assistente di Studio IA (Anteprima)';

  @override
  String get aiAssistantSettingsDescription =>
      'Abilita o disabilita l\'assistente di studio IA per le domande';

  @override
  String get openaiApiKeyLabel => 'Chiave API OpenAI';

  @override
  String get openaiApiKeyHint => 'Inserisci la tua chiave API OpenAI (sk-...)';

  @override
  String get openaiApiKeyDescription =>
      'Richiesta per la funzionalità IA. La tua chiave è memorizzata in sicurezza.';

  @override
  String get aiAssistantRequiresApiKeyError =>
      'L\'Assistente di Studio IA richiede una chiave API OpenAI. Inserisci la tua chiave API o disabilita l\'Assistente IA.';

  @override
  String get getApiKeyTooltip => 'Ottieni la chiave API da OpenAI';

  @override
  String get deleteAction => 'Elimina';

  @override
  String get explanationHint =>
      'Inserisci una spiegazione per la/e risposta/e corretta/e';

  @override
  String get explanationTitle => 'Spiegazione';

  @override
  String get imageLabel => 'Immagine';

  @override
  String get changeImage => 'Cambia immagine';

  @override
  String get removeImage => 'Rimuovi immagine';

  @override
  String get addImageTap => 'Tocca per aggiungere immagine';

  @override
  String get imageFormats => 'Formati: JPG, PNG, GIF';

  @override
  String get imageLoadError => 'Errore nel caricamento dell\'immagine';

  @override
  String imagePickError(String error) {
    return 'Errore nel caricamento dell\'immagine: $error';
  }

  @override
  String get tapToZoom => 'Tocca per ingrandire';

  @override
  String get trueLabel => 'Vero';

  @override
  String get falseLabel => 'Falso';

  @override
  String get addQuestion => 'Aggiungi Domanda';

  @override
  String get editQuestion => 'Modifica Domanda';

  @override
  String get questionText => 'Testo Domanda';

  @override
  String get questionType => 'Tipo Domanda';

  @override
  String get addOption => 'Aggiungi Opzione';

  @override
  String get optionLabel => 'Opzione';

  @override
  String get questionTextRequired => 'Il testo della domanda è obbligatorio';

  @override
  String get atLeastOneOptionRequired =>
      'Almeno un\'opzione deve avere del testo';

  @override
  String get atLeastOneCorrectAnswerRequired =>
      'Almeno una risposta corretta deve essere selezionata';

  @override
  String get onlyOneCorrectAnswerAllowed =>
      'È consentita solo una risposta corretta per questo tipo di domanda';

  @override
  String get removeOption => 'Rimuovi opzione';

  @override
  String get selectCorrectAnswer => 'Seleziona risposta corretta';

  @override
  String get selectCorrectAnswers => 'Seleziona risposte corrette';

  @override
  String emptyOptionsError(String optionNumbers) {
    return 'Le opzioni $optionNumbers sono vuote. Aggiungi del testo o rimuovile.';
  }

  @override
  String emptyOptionError(String optionNumber) {
    return 'L\'opzione $optionNumber è vuota. Aggiungi del testo o rimuovila.';
  }

  @override
  String get optionEmptyError => 'Questa opzione non può essere vuota';

  @override
  String get hasImage => 'Immagine';

  @override
  String get hasExplanation => 'Spiegazione';

  @override
  String errorLoadingSettings(String error) {
    return 'Errore nel caricamento delle impostazioni: $error';
  }

  @override
  String couldNotOpenUrl(String url) {
    return 'Impossibile aprire $url';
  }

  @override
  String get loadingAiServices => 'Caricamento servizi IA...';

  @override
  String usingAiService(String serviceName) {
    return 'Usando: $serviceName';
  }

  @override
  String get aiServiceLabel => 'Servizio IA:';

  @override
  String get importQuestionsTitle => 'Importa Domande';

  @override
  String importQuestionsMessage(int count, String fileName) {
    return 'Trovate $count domande in \"$fileName\". Dove vuoi importarle?';
  }

  @override
  String get importQuestionsPositionQuestion =>
      'Dove vuoi aggiungere queste domande?';

  @override
  String get importAtBeginning => 'All\'Inizio';

  @override
  String get importAtEnd => 'Alla Fine';

  @override
  String questionsImportedSuccess(int count) {
    return 'Importate con successo $count domande';
  }

  @override
  String get importQuestionsTooltip => 'Importa domande da un altro file quiz';

  @override
  String get dragDropHintText =>
      'Puoi anche trascinare e rilasciare file .quiz qui per importare domande';

  @override
  String get randomizeAnswersTitle => 'Randomizza Opzioni di Risposta';

  @override
  String get randomizeAnswersDescription =>
      'Mescola l\'ordine delle opzioni di risposta durante l\'esecuzione del quiz';

  @override
  String get showCorrectAnswerCountTitle => 'Mostra Numero Risposte Corrette';

  @override
  String get showCorrectAnswerCountDescription =>
      'Visualizza il numero di risposte corrette nelle domande a scelta multipla';

  @override
  String correctAnswersCount(int count) {
    return 'Seleziona $count risposte corrette';
  }

  @override
  String get correctSelectedLabel => 'Corretto';

  @override
  String get correctMissedLabel => 'Corretto';

  @override
  String get incorrectSelectedLabel => 'Errato';

  @override
  String get generateQuestionsWithAI => 'Genera domande con IA';

  @override
  String get aiGenerateDialogTitle => 'Genera Domande con IA';

  @override
  String get aiQuestionCountLabel => 'Numero di Domande (Opzionale)';

  @override
  String get aiQuestionCountHint => 'Lascia vuoto per far decidere all\'IA';

  @override
  String get aiQuestionCountValidation => 'Deve essere un numero tra 1 e 50';

  @override
  String get aiQuestionTypeLabel => 'Tipo di Domanda';

  @override
  String get aiQuestionTypeRandom => 'Casuale (Misto)';

  @override
  String get aiLanguageLabel => 'Lingua Domande';

  @override
  String get aiContentLabel => 'Contenuto per generare domande';

  @override
  String aiWordCount(int current, int max) {
    return '$current / $max parole';
  }

  @override
  String get aiContentHint =>
      'Inserisci il testo, argomento, o contenuto da cui vuoi generare domande...';

  @override
  String get aiContentHelperText =>
      'L\'IA creerà domande basate su questo contenuto';

  @override
  String aiWordLimitError(int max) {
    return 'Hai superato il limite di $max parole';
  }

  @override
  String get aiContentRequiredError =>
      'Devi fornire contenuto per generare domande';

  @override
  String aiContentLimitError(int max) {
    return 'Il contenuto supera il limite di $max parole';
  }

  @override
  String get aiMinWordsError =>
      'Fornisci almeno 10 parole per generare domande di qualità';

  @override
  String get aiInfoTitle => 'Informazioni';

  @override
  String get aiInfoDescription =>
      '• L\'IA analizzerà il contenuto e genererà domande pertinenti\n• Puoi includere testo, definizioni, spiegazioni, o qualsiasi materiale educativo\n• Le domande includeranno opzioni di risposta e spiegazioni\n• Il processo può richiedere alcuni secondi';

  @override
  String get aiGenerateButton => 'Genera Domande';

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
  String get aiServicesLoading => 'Caricamento servizi IA...';

  @override
  String get aiServicesNotConfigured => 'Nessun servizio IA configurato';

  @override
  String get aiGeneratedQuestions => 'Generato da IA';

  @override
  String get aiApiKeyRequired =>
      'Configura almeno una chiave API IA nelle Impostazioni per usare la generazione IA.';

  @override
  String get aiGenerationFailed =>
      'Impossibile generare domande. Prova con contenuto diverso.';

  @override
  String aiGenerationError(String error) {
    return 'Errore nella generazione domande: $error';
  }

  @override
  String get noQuestionsInFile => 'Nessuna domanda trovata nel file importato';

  @override
  String get couldNotAccessFile => 'Impossibile accedere al file selezionato';

  @override
  String get defaultOutputFileName => 'file-output.quiz';

  @override
  String aiServiceLimitsWithChars(int words, int chars) {
    return 'Limite: $words parole o $chars caratteri';
  }

  @override
  String aiServiceLimitsWordsOnly(int words) {
    return 'Limite: $words parole';
  }
}
