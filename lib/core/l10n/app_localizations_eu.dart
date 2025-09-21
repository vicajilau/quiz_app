// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Basque (`eu`).
class AppLocalizationsEu extends AppLocalizations {
  AppLocalizationsEu([String locale = 'eu']) : super(locale);

  @override
  String get titleAppBar => 'Quiz - Azterketa Simuladorea';

  @override
  String get create => 'Sortu';

  @override
  String get load => 'Kargatu';

  @override
  String fileLoaded(String filePath) {
    return 'Fitxategia kargatuta: $filePath';
  }

  @override
  String fileSaved(String filePath) {
    return 'Fitxategia gordeta: $filePath';
  }

  @override
  String get dropFileHere =>
      'Egin klik hemen edo arrastatu .quiz fitxategi bat pantailara';

  @override
  String get errorInvalidFile =>
      'Errorea: Fitxategi baliogabea. .quiz fitxategia izan behar da.';

  @override
  String errorLoadingFile(String error) {
    return 'Errorea Quiz fitxategia kargatzean: $error';
  }

  @override
  String errorExportingFile(String error) {
    return 'Errorea fitxategia esportatzen: $error';
  }

  @override
  String get cancelButton => 'Utzi';

  @override
  String get saveButton => 'Gorde';

  @override
  String get confirmDeleteTitle => 'Ezabaketa Berretsi';

  @override
  String confirmDeleteMessage(String processName) {
    return 'Ziur zaude `$processName` prozesua ezabatu nahi duzula?';
  }

  @override
  String get deleteButton => 'Ezabatu';

  @override
  String get confirmExitTitle => 'Irteera Berretsi';

  @override
  String get confirmExitMessage => 'Ziur zaude gorde gabe irten nahi duzula?';

  @override
  String get exitButton => 'Irten';

  @override
  String get saveDialogTitle => 'Hautatu irteera fitxategia:';

  @override
  String get createQuizFileTitle => 'Quiz Fitxategia Sortu';

  @override
  String get fileNameLabel => 'Fitxategiaren Izena';

  @override
  String get fileDescriptionLabel => 'Fitxategiaren Deskribapena';

  @override
  String get createButton => 'Sortu';

  @override
  String get fileNameRequiredError => 'Fitxategiaren izena beharrezkoa da.';

  @override
  String get fileDescriptionRequiredError =>
      'Fitxategiaren deskribapena beharrezkoa da.';

  @override
  String get versionLabel => 'Bertsioa';

  @override
  String get authorLabel => 'Egilea';

  @override
  String get authorRequiredError => 'Egilea beharrezkoa da.';

  @override
  String get requiredFieldsError => 'Beharrezko eremu guztiak bete behar dira.';

  @override
  String get requestFileNameTitle => 'Sartu Quiz fitxategiaren izena';

  @override
  String get fileNameHint => 'Fitxategiaren izena';

  @override
  String get emptyFileNameMessage => 'Fitxategiaren izena ezin da hutsik egon.';

  @override
  String get acceptButton => 'Onartu';

  @override
  String get saveTooltip => 'Fitxategia gorde';

  @override
  String get saveDisabledTooltip => 'Ez da aldaketarik gorde behar';

  @override
  String get executeTooltip => 'Azterketa exekutatu';

  @override
  String get addTooltip => 'Galdera berria gehitu';

  @override
  String get backSemanticLabel => 'Itzuli botoia';

  @override
  String get createFileTooltip => 'Quiz fitxategi berria sortu';

  @override
  String get loadFileTooltip => 'Dagoen Quiz fitxategia kargatu';

  @override
  String questionNumber(int number) {
    return 'Galdera $number';
  }

  @override
  String get previous => 'Aurrekoa';

  @override
  String get next => 'Hurrengoa';

  @override
  String get finish => 'Amaitu';

  @override
  String get finishQuiz => 'Quiz Amaitu';

  @override
  String get finishQuizConfirmation =>
      'Ziur zaude quiz-a amaitu nahi duzula? Ezingo dituzu zure erantzunak aldatu gero.';

  @override
  String get cancel => 'Utzi';

  @override
  String get abandonQuiz => 'Quiz Utzi';

  @override
  String get abandonQuizConfirmation =>
      'Ziur zaude quiz-a utzi nahi duzula? Aurrerapen guztia galduko da.';

  @override
  String get abandon => 'Utzi';

  @override
  String get quizCompleted => 'Quiz Osatuta!';

  @override
  String score(String score) {
    return 'Puntuazioa: $score%';
  }

  @override
  String correctAnswers(int correct, int total) {
    return '$correct / $total erantzun zuzen';
  }

  @override
  String get retry => 'Berriro saiatu';

  @override
  String get goBack => 'Amaitu';

  @override
  String get retryFailedQuestions => 'Huts egindakoak Berriro';

  @override
  String question(String question) {
    return 'Galdera: $question';
  }

  @override
  String get selectQuestionCountTitle => 'Galdera Kopurua Hautatu';

  @override
  String get selectQuestionCountMessage =>
      'Zenbat galderari erantzun nahi diezu quiz honetan?';

  @override
  String allQuestions(int count) {
    return 'Galdera guztiak ($count)';
  }

  @override
  String get startQuiz => 'Quiz Hasi';

  @override
  String get customNumberLabel => 'Edo sartu zenbaki pertsonalizatua:';

  @override
  String get numberInputLabel => 'Galdera kopurua';

  @override
  String customNumberHelper(int total) {
    return 'Sartu edozein zenbaki (geh. $total). Handiagoa bada, galderak errepikatu egingo dira.';
  }

  @override
  String get errorInvalidNumber => 'Mesedez, sartu zenbaki baliozkoa';

  @override
  String get errorNumberMustBePositive =>
      'Zenbakia 0 baino handiagoa izan behar da';

  @override
  String get questionOrderConfigTitle => 'Galdera Ordenaren Konfigurazioa';

  @override
  String get questionOrderConfigDescription =>
      'Hautatu galderak azterketaren zehar nola agertu nahi dituzun:';

  @override
  String get questionOrderAscending => 'Orden Gorakorra';

  @override
  String get questionOrderAscendingDesc =>
      'Galderak 1etik azkenera ordenean agertuko dira';

  @override
  String get questionOrderDescending => 'Orden Beherakorra';

  @override
  String get questionOrderDescendingDesc =>
      'Galderak azkenatik 1era ordenean agertuko dira';

  @override
  String get questionOrderRandom => 'Ausazkoa';

  @override
  String get questionOrderRandomDesc =>
      'Galderak orden ausazkoan agertuko dira';

  @override
  String get questionOrderConfigTooltip => 'Galdera ordenaren konfigurazioa';

  @override
  String get save => 'Gorde';

  @override
  String get examTimeLimitTitle => 'Azterketaren Denbora Muga';

  @override
  String get examTimeLimitDescription =>
      'Ezarri azterketarentzako denbora muga. Aktibatutakoan, denbora atzera-kontaketa erakutsiko da quiz-ean zehar.';

  @override
  String get enableTimeLimit => 'Denbora muga gaitu';

  @override
  String get timeLimitMinutes => 'Denbora muga (minutuak)';

  @override
  String get examTimeExpiredTitle => 'Denbora Amaitu da!';

  @override
  String get examTimeExpiredMessage =>
      'Azterketaren denbora amaitu da. Zure erantzunak automatikoki bidali dira.';

  @override
  String remainingTime(String hours, String minutes, String seconds) {
    return '$hours:$minutes:$seconds';
  }

  @override
  String get questionTypeMultipleChoice => 'Aukera Anitza';

  @override
  String get questionTypeSingleChoice => 'Aukera Bakarra';

  @override
  String get questionTypeTrueFalse => 'Egia/Gezurra';

  @override
  String get questionTypeEssay => 'Saiakera';

  @override
  String get questionTypeUnknown => 'Ezezaguna';

  @override
  String optionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aukera',
      one: 'aukera 1',
    );
    return '$_temp0';
  }

  @override
  String get optionsTooltip => 'Galdera honetarako erantzun aukera kopurua';

  @override
  String get imageTooltip => 'Galdera honek lotutako irudia du';

  @override
  String get explanationTooltip => 'Galdera honek azalpena du';

  @override
  String get aiPrompt =>
      'Zu ikasleei azterketa galderak eta erlazionatutako gaiak hobeto ulertzeko laguntzean espezializatutako irakasle aditu eta adiskidetsua zara. Zure helburua ikaskuntza sakona eta kontzeptu ulermena erraztea da.\n\nLagun dezakezu honekin:\n- Galderarekin erlazionatutako kontzeptuak azaltzen\n- Erantzun aukerai buruzko zalantzak argitzen\n- Gaiaren inguruko testuinguru gehigarria eskaintzen\n- Ikasketa baliabide osagarriak iradokitzen\n- Zergatik erantzun batzuk zuzenak edo okerrak diren azaltzen\n- Gaia beste kontzeptu garrantzitsu batzuekin erlazionatzen\n- Materialari buruzko jarraipena galderak erantzuten\n\nBeti erantzun galdetu zaizkizun hizkuntza berean. Izan pedagogikoa, argia eta motibatzailea zure azalpenetan.';

  @override
  String get questionLabel => 'Galdera';

  @override
  String get optionsLabel => 'Aukerak';

  @override
  String get explanationLabel => 'Azalpena (aukerakoa)';

  @override
  String get studentComment => 'Ikaslearen iruzkinak';

  @override
  String get aiAssistantTitle => 'Ikasketa AI Laguntzailea';

  @override
  String get questionContext => 'Galderaren Testuingurua';

  @override
  String get aiAssistant => 'AI Laguntzailea';

  @override
  String get aiThinking => 'AI-a pentsatzen ari da...';

  @override
  String get askAIHint => 'Egin zure galdera gai honi buruz...';

  @override
  String get aiPlaceholderResponse =>
      'Hau leku-markatzaile erantzuna da. Benetako inplementazio batean, honek AI zerbitzu batekin konektatuko litzateke galderari buruzko azalpen baliagarriak eskaintzeko.';

  @override
  String get aiErrorResponse =>
      'Barkatu, errore bat izan da zure galdera prozesatzean. Saiatu berriro.';

  @override
  String get configureApiKeyMessage =>
      'Mesedez, konfigura ezazu zure AI API Gakoa Ezarpenetan.';

  @override
  String get errorLabel => 'Errorea:';

  @override
  String get noResponseReceived => 'Ez da erantzunik jaso';

  @override
  String get invalidApiKeyError =>
      'API gako baliogabea. Egiaztatu zure OpenAI API Gakoa ezarpenetan.';

  @override
  String get rateLimitError =>
      'Abiadura muga gainditua. Saiatu berriro geroago.';

  @override
  String get modelNotFoundError =>
      'Modeloa ez da aurkitu. Egiaztatu zure API sarbidea.';

  @override
  String get unknownError => 'Errore ezezaguna';

  @override
  String get networkError =>
      'Sare errorea: Ezin da OpenAI-ra konektatu. Egiaztatu zure internet konexioa.';

  @override
  String get openaiApiKeyNotConfigured =>
      'OpenAI API Gakoa ez dago konfiguratuta';

  @override
  String get geminiApiKeyNotConfigured =>
      'Gemini API Gakoa ez dago konfiguratuta';

  @override
  String get geminiApiKeyLabel => 'Gemini API Gakoa';

  @override
  String get geminiApiKeyHint => 'Sartu zure Gemini API Gakoa';

  @override
  String get geminiApiKeyDescription =>
      'Gemini AI funtzionalitaterako beharrezkoa. Zure gakoa modu seguruan gordetzen da.';

  @override
  String get getGeminiApiKeyTooltip => 'Google AI Studio-tik API Gakoa lortu';

  @override
  String get aiRequiresAtLeastOneApiKeyError =>
      'Ikasketa AI Laguntzaileak gutxienez API Gako bat behar du (OpenAI edo Gemini). Sartu API gakoa edo desaktibatu AI Laguntzailea.';

  @override
  String get minutesAbbreviation => 'min';

  @override
  String get aiButtonTooltip => 'Ikasketa AI Laguntzailea';

  @override
  String get aiButtonText => 'AI';

  @override
  String get aiAssistantSettingsTitle =>
      'Ikasketa AI Laguntzailea (Aurrebista)';

  @override
  String get aiAssistantSettingsDescription =>
      'Gaitu edo desaktibatu galderetarako ikasketa ai laguntzailea';

  @override
  String get openaiApiKeyLabel => 'OpenAI API Gakoa';

  @override
  String get openaiApiKeyHint => 'Sartu zure OpenAI API Gakoa (sk-...)';

  @override
  String get openaiApiKeyDescription =>
      'Beharrezkoa da OpenAI integratzeko. Zure OpenAI gakoa modu seguruan gordetzen da.';

  @override
  String get aiAssistantRequiresApiKeyError =>
      'Ikasketa AI Laguntzaileak OpenAI API Gako bat behar du. Sartu zure API gakoa edo desaktibatu AI Laguntzailea.';

  @override
  String get getApiKeyTooltip => 'OpenAI-tik API Gakoa lortu';

  @override
  String get deleteAction => 'Ezabatu';

  @override
  String get explanationHint => 'Sartu erantzun zuzen(ar)entzako azalpena';

  @override
  String get explanationTitle => 'Azalpena';

  @override
  String get imageLabel => 'Irudia';

  @override
  String get changeImage => 'Irudia aldatu';

  @override
  String get removeImage => 'Irudia kendu';

  @override
  String get addImageTap => 'Ukitu irudia gehitzeko';

  @override
  String get imageFormats => 'Formatuak: JPG, PNG, GIF';

  @override
  String get imageLoadError => 'Errorea irudia kargatzean';

  @override
  String imagePickError(String error) {
    return 'Errorea irudia kargatzean: $error';
  }

  @override
  String get tapToZoom => 'Ukitu handitzeko';

  @override
  String get trueLabel => 'Egia';

  @override
  String get falseLabel => 'Gezurra';

  @override
  String get addQuestion => 'Galdera Gehitu';

  @override
  String get editQuestion => 'Galdera Editatu';

  @override
  String get questionText => 'Galderaren Testua';

  @override
  String get questionType => 'Galdera Mota';

  @override
  String get addOption => 'Aukera Gehitu';

  @override
  String get optionLabel => 'Aukera';

  @override
  String get questionTextRequired => 'Galdera testua beharrezkoa da';

  @override
  String get atLeastOneOptionRequired =>
      'Gutxienez aukera batek testua izan behar du';

  @override
  String get atLeastOneCorrectAnswerRequired =>
      'Gutxienez erantzun zuzen bat hautatu behar da';

  @override
  String get onlyOneCorrectAnswerAllowed =>
      'Galdera mota honetarako erantzun zuzen bakarra onartzen da';

  @override
  String get removeOption => 'Aukera kendu';

  @override
  String get selectCorrectAnswer => 'Erantzun zuzena hautatu';

  @override
  String get selectCorrectAnswers => 'Erantzun zuzenak hautatu';

  @override
  String emptyOptionsError(String optionNumbers) {
    return '$optionNumbers aukerak hutsik daude. Gehitu testua edo kendu itzazu.';
  }

  @override
  String emptyOptionError(String optionNumber) {
    return '$optionNumber aukera hutsik dago. Gehitu testua edo kendu ezazu.';
  }

  @override
  String get optionEmptyError => 'Aukera hau ezin da hutsik egon';

  @override
  String get hasImage => 'Irudia';

  @override
  String get hasExplanation => 'Azalpena';

  @override
  String errorLoadingSettings(String error) {
    return 'Errorea ezarpenak kargatzean: $error';
  }

  @override
  String couldNotOpenUrl(String url) {
    return 'Ezin izan da $url ireki';
  }

  @override
  String get loadingAiServices => 'AI zerbitzuak kargatzen...';

  @override
  String usingAiService(String serviceName) {
    return 'Erabiltzen: $serviceName';
  }

  @override
  String get aiServiceLabel => 'AI Zerbitzua:';

  @override
  String get importQuestionsTitle => 'Galderak Inportatu';

  @override
  String importQuestionsMessage(int count, String fileName) {
    return '$count galdera aurkitu dira \"$fileName\"-n. Non inportatu nahi dituzu?';
  }

  @override
  String get importQuestionsPositionQuestion =>
      'Non gehitu nahi dituzu galdera hauek?';

  @override
  String get importAtBeginning => 'Hasieran';

  @override
  String get importAtEnd => 'Amaieran';

  @override
  String questionsImportedSuccess(int count) {
    return '$count galdera arrakastaz inportatuta';
  }

  @override
  String get importQuestionsTooltip =>
      'Beste quiz fitxategi batetik galderak inportatu';

  @override
  String get dragDropHintText =>
      'Galderak inportatzeko .quiz fitxategiak hona arrastatu eta utz ditzakezu ere';

  @override
  String get randomizeAnswersTitle => 'Erantzun Aukerak Ausazkotu';

  @override
  String get randomizeAnswersDescription =>
      'Quiz exekuzioan erantzun aukeren ordena nahastu';

  @override
  String get showCorrectAnswerCountTitle => 'Erantzun Zuzen Kopurua Erakutsi';

  @override
  String get showCorrectAnswerCountDescription =>
      'Aukera anitzeko galderetako erantzun zuzen kopurua erakutsi';

  @override
  String correctAnswersCount(int count) {
    return 'Hautatu $count erantzun zuzen';
  }

  @override
  String get correctSelectedLabel => 'Zuzena';

  @override
  String get correctMissedLabel => 'Zuzena';

  @override
  String get incorrectSelectedLabel => 'Okerra';

  @override
  String get generateQuestionsWithAI => 'AI-rekin galderak sortu';

  @override
  String get aiGenerateDialogTitle => 'AI-rekin Galderak Sortu';

  @override
  String get aiQuestionCountLabel => 'Galdera Kopurua (Aukerakoa)';

  @override
  String get aiQuestionCountHint => 'Utzi hutsik AI-ak erabaki dezan';

  @override
  String get aiQuestionCountValidation =>
      '1 eta 50 arteko zenbakia izan behar da';

  @override
  String get aiQuestionTypeLabel => 'Galdera Mota';

  @override
  String get aiQuestionTypeRandom => 'Ausazkoa (Mistoa)';

  @override
  String get aiLanguageLabel => 'Galderen Hizkuntza';

  @override
  String get aiContentLabel => 'Galderak sortzeko edukia';

  @override
  String aiWordCount(int current, int max) {
    return '$current / $max hitz';
  }

  @override
  String get aiContentHint =>
      'Sartu testua, gaia, edo edukia zeinetatik galderak sortu nahi dituzun...';

  @override
  String get aiContentHelperText =>
      'AI-ak eduki honen oinarrian galderak sortuko ditu';

  @override
  String aiWordLimitError(int max) {
    return '$max hitzen muga gainditu duzu';
  }

  @override
  String get aiContentRequiredError =>
      'Galderak sortzeko edukia eman behar duzu';

  @override
  String aiContentLimitError(int max) {
    return 'Edukiak $max hitzen muga gainditzen du';
  }

  @override
  String get aiMinWordsError =>
      'Kalitatezkoak galderak sortzeko gutxienez 10 hitz eman';

  @override
  String get aiInfoTitle => 'Informazioa';

  @override
  String get aiInfoDescription =>
      '• AI-ak edukia aztertuko du eta galdera garrantzitsuak sortuko ditu\n• Testua, definizioak, azalpenak, edo edozein hezkuntza material sar dezakezu\n• Galderek erantzun aukerak eta azalpenak izango dituzte\n• Prozesuak segundo batzuk har ditzake';

  @override
  String get aiGenerateButton => 'Galderak Sortu';

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
  String get aiServicesLoading => 'AI zerbitzuak kargatzen...';

  @override
  String get aiServicesNotConfigured => 'Ez da AI zerbitzurik konfiguratu';

  @override
  String get aiGeneratedQuestions => 'AI-ak sortutakoak';

  @override
  String get aiApiKeyRequired =>
      'Konfiguratu gutxienez AI API gako bat Ezarpenetan AI sorkuntza erabiltzeko.';

  @override
  String get aiGenerationFailed =>
      'Ezin izan dira galderak sortu. Saiatu eduki ezberdinarekin.';

  @override
  String aiGenerationError(String error) {
    return 'Errorea galderak sortzean: $error';
  }

  @override
  String get noQuestionsInFile =>
      'Ez da galderarik aurkitu inportatutako fitxategian';

  @override
  String get couldNotAccessFile => 'Ezin izan da hautatutako fitxategira sartu';

  @override
  String get defaultOutputFileName => 'irteera-fitxategia.quiz';

  @override
  String aiServiceLimitsWithChars(int words, int chars) {
    return 'Muga: $words hitz edo $chars karaktere';
  }

  @override
  String aiServiceLimitsWordsOnly(int words) {
    return 'Muga: $words hitz';
  }

  @override
  String get aiAssistantDisabled => 'AI Laguntzailea Desgaituta';

  @override
  String get enableAiAssistant =>
      'AI laguntzailea desgaituta dago. Mesedez, gaitu ezazu konfigurazioan AI funtzioak erabiltzeko.';

  @override
  String aiMinWordsRequired(int minWords) {
    return 'Gutxienez $minWords hitz behar dira';
  }

  @override
  String aiWordsReadyToGenerate(int wordCount) {
    return '$wordCount hitz ✓ Sortzeko prest';
  }

  @override
  String aiWordsProgress(int currentWords, int minWords, int moreNeeded) {
    return '$currentWords/$minWords hitz ($moreNeeded gehiago behar dira)';
  }

  @override
  String aiValidationMinWords(int minWords, int moreNeeded) {
    return 'Gutxienez $minWords hitz behar dira ($moreNeeded gehiago behar dira)';
  }

  @override
  String get enableQuestion => 'Galdera gaitu';

  @override
  String get disableQuestion => 'Galdera desgaitu';

  @override
  String get questionDisabled => 'Desgaituta';

  @override
  String get noEnabledQuestionsError =>
      'Ez dago gaitutako galderarik eskuragarri galdetegia exekutatzeko';

  @override
  String get evaluateWithAI => 'AIaz ebaluatu';

  @override
  String get aiEvaluation => 'AI Ebaluazioa';

  @override
  String aiEvaluationError(String error) {
    return 'Errorea erantzuna ebaluatzean: $error';
  }

  @override
  String get aiEvaluationPromptSystemRole =>
      'Ikasleen saiakera galderen erantzunak ebaluatzen espezializatutako irakaslea zara. Zure zeregina ebaluazio zehatz eta eraikitzaileak ematea da. Erantzun euskeraz.';

  @override
  String get aiEvaluationPromptQuestion => 'Galdera:';

  @override
  String get aiEvaluationPromptStudentAnswer => 'Ikaslearen erantzuna:';

  @override
  String get aiEvaluationPromptCriteria =>
      'Ebaluazio irizpideak (irakaslearen azalpenean oinarrituta):';

  @override
  String get aiEvaluationPromptSpecificInstructions =>
      'Jarraibide zehatzak:\n- Ebaluatu ikaslearen erantzuna ezarritako irizpideetara zenbateraino egokitzen den\n- Aztertu erantzunean integrazioaren eta egituraren maila\n- Identifikatu irizpideen arabera zerbait garrantzitsua kontuan hartu ez den\n- Kontuan hartu analisiari sakontasuna eta zehaztasuna';

  @override
  String get aiEvaluationPromptGeneralInstructions =>
      'Jarraibide orokorrak:\n- Irizpide zehatzik ezarri ez denez, ebaluatu erantzuna oinarrizko estandar akademikoen arabera\n- Kontuan hartu erantzunaren argitasuna, koherentzia eta egitura\n- Ebaluatu erantzunak gaiaren ulermena erakusten duen\n- Aztertu analisiaren sakontasuna eta argumentazioaren kalitatea';

  @override
  String get aiEvaluationPromptResponseFormat =>
      'Erantzun formatua:\n1. Puntuazioa: [X/10] - Justifikatu labur puntuazioa\n2. Indar puntuak: Adierazi erantzunaren alderdi positiboak\n3. Hobekuntza arloak: Seinalatu hobetu daitezkeen alderdiak\n4. Iruzkin zehatzak: Eman feedback zehatza eta eraikitzailea\n5. Iradokizunak: Eskaini hobetzeko gomendio zehatzak\n\nIzan eraikitzailea, zehatza eta hezigarria zure ebaluazioan. Helburua ikaslea ikastera eta hobetzen laguntzea da. Zuzendu pertsona bigarrenean eta erabili tonu profesionala baina hurbilgarria.';

  @override
  String get raffleTitle => 'Zozketa';

  @override
  String get raffleTooltip => 'Zozketa pantaila ireki';

  @override
  String get participantListTitle => 'Parte-hartzaileen Zerrenda';

  @override
  String get participantListHint => 'Sartu izenak lerro jauziez bereizita';

  @override
  String get participantListPlaceholder =>
      'Sartu parte-hartzaileen izenak hemen...\nIzen bat lerro bakoitzeko';

  @override
  String get clearList => 'Zerrenda Garbitu';

  @override
  String get participants => 'Parte-hartzaileak';

  @override
  String get noParticipants => 'Ez dago parte-hartzailerik';

  @override
  String get addParticipantsHint => 'Gehitu parte-hartzaileak zozketa hasteko';

  @override
  String get activeParticipants => 'Parte-hartzaile Aktiboak';

  @override
  String get alreadySelected => 'Jadanik Hautatuta';

  @override
  String totalParticipants(int count) {
    return 'Parte-hartzaile Guztira';
  }

  @override
  String activeVsWinners(int active, int winners) {
    return '$active aktibo, $winners irabazle';
  }

  @override
  String get startRaffle => 'Zozketa Hasi';

  @override
  String get raffling => 'Zozkatzen...';

  @override
  String get selectingWinner => 'Irabazlea hautatzen...';

  @override
  String get allParticipantsSelected => 'Parte-hartzaile guztiak hautatu dira';

  @override
  String get addParticipantsToStart =>
      'Gehitu parte-hartzaileak zozketa hasteko';

  @override
  String participantsReadyCount(int count) {
    return '$count parte-hartzaile prest zozketarako';
  }

  @override
  String get resetWinners => 'Irabazleak Berrezarri';

  @override
  String get resetWinnersConfirmTitle => 'Irabazleak berrezarri?';

  @override
  String get resetWinnersConfirmMessage =>
      'Honek irabazle guztiak parte-hartzaile aktiboen zerrendara itzuliko ditu.';

  @override
  String get resetRaffleTitle => 'Zozketa berrezarri?';

  @override
  String get resetRaffleConfirmMessage =>
      'Honek irabazle eta parte-hartzaile aktibo guztiak berrezarriko ditu.';

  @override
  String get reset => 'Berrezarri';

  @override
  String get viewWinners => 'Irabazleak Ikusi';

  @override
  String get congratulations => 'Zorionak!';

  @override
  String positionLabel(int position) {
    return '$position. Posizioa';
  }

  @override
  String remainingParticipants(int count) {
    return 'Gainerako parte-hartzaileak: $count';
  }

  @override
  String get continueRaffle => 'Zozketa Jarraitu';

  @override
  String get finishRaffle => 'Zozketa Amaitu';

  @override
  String get winnersTitle => 'Irabazleak';

  @override
  String get shareResults => 'Emaitzak Partekatu';

  @override
  String get noWinnersYet => 'Oraindik ez dago irabazlerik';

  @override
  String get performRaffleToSeeWinners => 'Egin zozketa irabazleak ikusteko';

  @override
  String get goToRaffle => 'Zozketara Joan';

  @override
  String get raffleCompleted => 'Zozketa osatuta!';

  @override
  String winnersSelectedCount(int count) {
    return '$count irabazle hautatu dira';
  }

  @override
  String get newRaffle => 'Zozketa Berria';

  @override
  String get shareResultsTitle => 'Zozketaren Emaitzak';

  @override
  String get raffleResultsLabel => 'Zozketaren emaitzak:';

  @override
  String get close => 'Itxi';

  @override
  String get share => 'Kopiatu';

  @override
  String get shareNotImplemented =>
      'Partekatzea ez dago oraindik inplementatuta';

  @override
  String get firstPlace => 'Lehen Posizioa';

  @override
  String get secondPlace => 'Bigarren Posizioa';

  @override
  String get thirdPlace => 'Hirugarren Posizioa';

  @override
  String nthPlace(int position) {
    return '$position. Posizioa';
  }

  @override
  String placeLabel(String position) {
    return 'Posizioa';
  }

  @override
  String get raffleResultsHeader => 'Zozketaren Emaitzak - null irabazle';

  @override
  String totalWinners(int count) {
    return 'Irabazle guztira: $count';
  }

  @override
  String get noWinnersToShare => 'Ez dago irabazlerik partekatzeko';

  @override
  String get shareSuccess => 'Emaitzak arrakastaz kopiatu dira';
}
