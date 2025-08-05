// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get titleAppBar => 'Quiz - Simulador d\'Exàmens';

  @override
  String get create => 'Crear';

  @override
  String get load => 'Carregar';

  @override
  String fileLoaded(String filePath) {
    return 'Fitxer carregat: $filePath';
  }

  @override
  String fileSaved(String filePath) {
    return 'Fitxer desat: $filePath';
  }

  @override
  String get dropFileHere =>
      'Feu clic aquí o arrossegueu un fitxer .quiz a la pantalla';

  @override
  String get errorInvalidFile =>
      'Error: Fitxer no vàlid. Ha de ser un fitxer .quiz.';

  @override
  String errorLoadingFile(String error) {
    return 'Error en carregar el fitxer Quiz: $error';
  }

  @override
  String errorExportingFile(String error) {
    return 'Error en exportar el fitxer: $error';
  }

  @override
  String get cancelButton => 'Cancel·lar';

  @override
  String get saveButton => 'Desar';

  @override
  String get confirmDeleteTitle => 'Confirmar Eliminació';

  @override
  String confirmDeleteMessage(String processName) {
    return 'Esteu segur que voleu eliminar el procés `$processName`?';
  }

  @override
  String get deleteButton => 'Eliminar';

  @override
  String get confirmExitTitle => 'Confirmar Sortida';

  @override
  String get confirmExitMessage => 'Esteu segur que voleu sortir sense desar?';

  @override
  String get exitButton => 'Sortir';

  @override
  String get saveDialogTitle => 'Seleccioneu un fitxer de sortida:';

  @override
  String get createQuizFileTitle => 'Crear Fitxer Quiz';

  @override
  String get fileNameLabel => 'Nom del Fitxer';

  @override
  String get fileDescriptionLabel => 'Descripció del Fitxer';

  @override
  String get createButton => 'Crear';

  @override
  String get fileNameRequiredError => 'El nom del fitxer és obligatori.';

  @override
  String get fileDescriptionRequiredError =>
      'La descripció del fitxer és obligatòria.';

  @override
  String get versionLabel => 'Versió';

  @override
  String get authorLabel => 'Autor';

  @override
  String get authorRequiredError => 'L\'autor és obligatori.';

  @override
  String get requiredFieldsError =>
      'Tots els camps obligatoris han de ser completats.';

  @override
  String get requestFileNameTitle => 'Introduïu el nom del fitxer Quiz';

  @override
  String get fileNameHint => 'Nom del fitxer';

  @override
  String get emptyFileNameMessage => 'El nom del fitxer no pot estar buit.';

  @override
  String get acceptButton => 'Acceptar';

  @override
  String get saveTooltip => 'Desar el fitxer';

  @override
  String get saveDisabledTooltip => 'Cap canvi per desar';

  @override
  String get executeTooltip => 'Executar l\'examen';

  @override
  String get addTooltip => 'Afegir una nova pregunta';

  @override
  String get backSemanticLabel => 'Botó tornar';

  @override
  String get createFileTooltip => 'Crear un nou fitxer Quiz';

  @override
  String get loadFileTooltip => 'Carregar un fitxer Quiz existent';

  @override
  String questionNumber(int number) {
    return 'Pregunta $number';
  }

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Següent';

  @override
  String get finish => 'Acabar';

  @override
  String get finishQuiz => 'Acabar Quiz';

  @override
  String get finishQuizConfirmation =>
      'Esteu segur que voleu acabar el quiz? No podreu canviar les vostres respostes després.';

  @override
  String get cancel => 'Cancel·lar';

  @override
  String get abandonQuiz => 'Abandonar Quiz';

  @override
  String get abandonQuizConfirmation =>
      'Esteu segur que voleu abandonar el quiz? Tot el progrés es perdrà.';

  @override
  String get abandon => 'Abandonar';

  @override
  String get quizCompleted => 'Quiz Completat!';

  @override
  String score(String score) {
    return 'Puntuació: $score%';
  }

  @override
  String correctAnswers(int correct, int total) {
    return '$correct de $total respostes correctes';
  }

  @override
  String get retry => 'Repetir';

  @override
  String get goBack => 'Acabar';

  @override
  String get retryFailedQuestions => 'Repetir Fallades';

  @override
  String question(String question) {
    return 'Pregunta: $question';
  }

  @override
  String get selectQuestionCountTitle => 'Seleccionar Nombre de Preguntes';

  @override
  String get selectQuestionCountMessage =>
      'A quantes preguntes us agradaria respondre en aquest quiz?';

  @override
  String allQuestions(int count) {
    return 'Totes les preguntes ($count)';
  }

  @override
  String get startQuiz => 'Començar Quiz';

  @override
  String get customNumberLabel => 'O introduïu un número personalitzat:';

  @override
  String get numberInputLabel => 'Nombre de preguntes';

  @override
  String customNumberHelper(int total) {
    return 'Introduïu qualsevol número (màx $total). Si és més gran, les preguntes es repetiran.';
  }

  @override
  String get errorInvalidNumber => 'Si us plau, introduïu un número vàlid';

  @override
  String get errorNumberMustBePositive => 'El número ha de ser més gran que 0';

  @override
  String get questionOrderConfigTitle =>
      'Configuració de l\'Ordre de les Preguntes';

  @override
  String get questionOrderConfigDescription =>
      'Seleccioneu l\'ordre en què voleu que apareguin les preguntes durant l\'examen:';

  @override
  String get questionOrderAscending => 'Ordre Ascendent';

  @override
  String get questionOrderAscendingDesc =>
      'Les preguntes apareixeran en ordre de 1 al final';

  @override
  String get questionOrderDescending => 'Ordre Descendent';

  @override
  String get questionOrderDescendingDesc =>
      'Les preguntes apareixeran del final a 1';

  @override
  String get questionOrderRandom => 'Aleatori';

  @override
  String get questionOrderRandomDesc =>
      'Les preguntes apareixeran en ordre aleatori';

  @override
  String get questionOrderConfigTooltip =>
      'Configuració de l\'ordre de les preguntes';

  @override
  String get save => 'Desar';

  @override
  String get examTimeLimitTitle => 'Límit de Temps de l\'Examen';

  @override
  String get examTimeLimitDescription =>
      'Establiu un límit de temps per l\'examen. Quan s\'activi, es mostrarà un temporitzador de compte enrere durant el quiz.';

  @override
  String get enableTimeLimit => 'Activar límit de temps';

  @override
  String get timeLimitMinutes => 'Límit de temps (minuts)';

  @override
  String get examTimeExpiredTitle => 'Temps Esgotat!';

  @override
  String get examTimeExpiredMessage =>
      'El temps de l\'examen ha expirat. Les vostres respostes s\'han enviat automàticament.';

  @override
  String remainingTime(String hours, String minutes, String seconds) {
    return '$hours:$minutes:$seconds';
  }

  @override
  String get questionTypeMultipleChoice => 'Elecció Múltiple';

  @override
  String get questionTypeSingleChoice => 'Elecció Única';

  @override
  String get questionTypeTrueFalse => 'Cert/Fals';

  @override
  String get questionTypeEssay => 'Assaig';

  @override
  String get questionTypeUnknown => 'Desconegut';

  @override
  String optionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opcions',
      one: '1 opció',
    );
    return '$_temp0';
  }

  @override
  String get optionsTooltip =>
      'Nombre d\'opcions de resposta per aquesta pregunta';

  @override
  String get imageTooltip => 'Aquesta pregunta té una imatge associada';

  @override
  String get explanationTooltip => 'Aquesta pregunta té una explicació';

  @override
  String get aiPrompt =>
      'Sou un tutor expert i amigable especialitzat en ajudar els estudiants a comprendre millor les preguntes d\'examen i els temes relacionats. El vostre objectiu és facilitar l\'aprenentatge profund i la comprensió conceptual.\n\nPodeu ajudar amb:\n- Explicar conceptes relacionats amb la pregunta\n- Aclarir dubtes sobre les opcions de resposta\n- Proporcionar context addicional sobre el tema\n- Suggerir recursos d\'estudi complementaris\n- Explicar per què certes respostes són correctes o incorrectes\n- Relacionar el tema amb altres conceptes importants\n- Respondre preguntes de seguiment sobre el material\n\nSempre responeu en la mateixa llengua en què se us pregunta. Sigueu pedagògic, clar i motivador en les vostres explicacions.';

  @override
  String get questionLabel => 'Pregunta';

  @override
  String get optionsLabel => 'Opcions';

  @override
  String get explanationLabel => 'Explicació (opcional)';

  @override
  String get studentComment => 'Comentari de l\'estudiant';

  @override
  String get aiAssistantTitle => 'Assistent d\'Estudi IA';

  @override
  String get questionContext => 'Context de la Pregunta';

  @override
  String get aiAssistant => 'Assistent IA';

  @override
  String get aiThinking => 'La IA està pensant...';

  @override
  String get askAIHint => 'Feu la vostra pregunta sobre aquest tema...';

  @override
  String get aiPlaceholderResponse =>
      'Aquesta és una resposta de marcador de posició. En una implementació real, això es connectaria a un servei IA per proporcionar explicacions útils sobre la pregunta.';

  @override
  String get aiErrorResponse =>
      'Ho sento, hi ha hagut un error en processar la vostra pregunta. Torneu-ho a provar.';

  @override
  String get configureApiKeyMessage =>
      'Si us plau, configureu la vostra Clau API IA a la Configuració.';

  @override
  String get errorLabel => 'Error:';

  @override
  String get noResponseReceived => 'Cap resposta rebuda';

  @override
  String get invalidApiKeyError =>
      'Clau API no vàlida. Comproveu la vostra Clau API OpenAI a la configuració.';

  @override
  String get rateLimitError =>
      'Límit de velocitat excedit. Torneu-ho a provar més tard.';

  @override
  String get modelNotFoundError =>
      'Model no trobat. Comproveu el vostre accés a l\'API.';

  @override
  String get unknownError => 'Error desconegut';

  @override
  String get networkError =>
      'Error de xarxa: No es pot connectar a OpenAI. Comproveu la vostra connexió a internet.';

  @override
  String get openaiApiKeyNotConfigured => 'Clau API OpenAI no configurada';

  @override
  String get geminiApiKeyNotConfigured => 'Clau API Gemini no configurada';

  @override
  String get geminiApiKeyLabel => 'Clau API Google Gemini';

  @override
  String get geminiApiKeyHint => 'Introduïu la vostra Clau API Gemini';

  @override
  String get geminiApiKeyDescription =>
      'Requerit per la funcionalitat IA Gemini. La vostra clau s\'emmagatzema de forma segura.';

  @override
  String get getGeminiApiKeyTooltip => 'Obtenir Clau API de Google AI Studio';

  @override
  String get aiRequiresAtLeastOneApiKeyError =>
      'L\'Assistent d\'Estudi IA requereix almenys una Clau API (OpenAI o Gemini). Introduïu una clau API o desactiveu l\'Assistent IA.';

  @override
  String get minutesAbbreviation => 'min';

  @override
  String get aiButtonTooltip => 'Assistent d\'Estudi IA';

  @override
  String get aiButtonText => 'IA';

  @override
  String get aiAssistantSettingsTitle =>
      'Assistent d\'Estudi IA (Vista prèvia)';

  @override
  String get aiAssistantSettingsDescription =>
      'Activar o desactivar l\'assistent d\'estudi IA per les preguntes';

  @override
  String get openaiApiKeyLabel => 'Clau API OpenAI';

  @override
  String get openaiApiKeyHint => 'Introduïu la vostra Clau API OpenAI (sk-...)';

  @override
  String get openaiApiKeyDescription =>
      'Requerit per la funcionalitat IA. La vostra clau s\'emmagatzema de forma segura.';

  @override
  String get aiAssistantRequiresApiKeyError =>
      'L\'Assistent d\'Estudi IA requereix una Clau API OpenAI. Introduïu la vostra clau API o desactiveu l\'Assistent IA.';

  @override
  String get getApiKeyTooltip => 'Obtenir Clau API d\'OpenAI';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get explanationHint =>
      'Introduïu una explicació per la/les resposta/es correcta/es';

  @override
  String get explanationTitle => 'Explicació';

  @override
  String get imageLabel => 'Imatge';

  @override
  String get changeImage => 'Canviar imatge';

  @override
  String get removeImage => 'Eliminar imatge';

  @override
  String get addImageTap => 'Toqueu per afegir imatge';

  @override
  String get imageFormats => 'Formats: JPG, PNG, GIF';

  @override
  String get imageLoadError => 'Error en carregar la imatge';

  @override
  String imagePickError(String error) {
    return 'Error en carregar la imatge: $error';
  }

  @override
  String get tapToZoom => 'Toqueu per ampliar';

  @override
  String get trueLabel => 'Cert';

  @override
  String get falseLabel => 'Fals';

  @override
  String get addQuestion => 'Afegir Pregunta';

  @override
  String get editQuestion => 'Editar Pregunta';

  @override
  String get questionText => 'Text de la Pregunta';

  @override
  String get questionType => 'Tipus de Pregunta';

  @override
  String get addOption => 'Afegir Opció';

  @override
  String get optionLabel => 'Opció';

  @override
  String get questionTextRequired => 'El text de la pregunta és obligatori';

  @override
  String get atLeastOneOptionRequired => 'Almenys una opció ha de tenir text';

  @override
  String get atLeastOneCorrectAnswerRequired =>
      'Almenys una resposta correcta ha de ser seleccionada';

  @override
  String get onlyOneCorrectAnswerAllowed =>
      'Només es permet una resposta correcta per aquest tipus de pregunta';

  @override
  String get removeOption => 'Eliminar opció';

  @override
  String get selectCorrectAnswer => 'Seleccionar resposta correcta';

  @override
  String get selectCorrectAnswers => 'Seleccionar respostes correctes';

  @override
  String emptyOptionsError(String optionNumbers) {
    return 'Les opcions $optionNumbers estan buides. Afegiu-hi text o elimineu-les.';
  }

  @override
  String emptyOptionError(String optionNumber) {
    return 'L\'opció $optionNumber està buida. Afegiu-hi text o elimineu-la.';
  }

  @override
  String get optionEmptyError => 'Aquesta opció no pot estar buida';

  @override
  String get hasImage => 'Imatge';

  @override
  String get hasExplanation => 'Explicació';

  @override
  String errorLoadingSettings(String error) {
    return 'Error en carregar la configuració: $error';
  }

  @override
  String couldNotOpenUrl(String url) {
    return 'No s\'ha pogut obrir $url';
  }

  @override
  String get loadingAiServices => 'Carregant serveis IA...';

  @override
  String usingAiService(String serviceName) {
    return 'Usant: $serviceName';
  }

  @override
  String get aiServiceLabel => 'Servei IA:';

  @override
  String get importQuestionsTitle => 'Importar Preguntes';

  @override
  String importQuestionsMessage(int count, String fileName) {
    return 'Trobades $count preguntes a \"$fileName\". On voleu importar-les?';
  }

  @override
  String get importQuestionsPositionQuestion =>
      'On voleu afegir aquestes preguntes?';

  @override
  String get importAtBeginning => 'Al Principi';

  @override
  String get importAtEnd => 'Al Final';

  @override
  String questionsImportedSuccess(int count) {
    return 'Importades amb èxit $count preguntes';
  }

  @override
  String get importQuestionsTooltip =>
      'Importar preguntes d\'un altre fitxer quiz';

  @override
  String get dragDropHintText =>
      'També podeu arrossegar i deixar anar fitxers .quiz aquí per importar preguntes';

  @override
  String get randomizeAnswersTitle => 'Aleatoritzar Opcions de Resposta';

  @override
  String get randomizeAnswersDescription =>
      'Barrejar l\'ordre de les opcions de resposta durant l\'execució del quiz';

  @override
  String get showCorrectAnswerCountTitle =>
      'Mostrar Nombre de Respostes Correctes';

  @override
  String get showCorrectAnswerCountDescription =>
      'Mostrar el nombre de respostes correctes en preguntes d\'elecció múltiple';

  @override
  String correctAnswersCount(int count) {
    return 'Seleccioneu $count respostes correctes';
  }

  @override
  String get correctSelectedLabel => 'Correcte';

  @override
  String get correctMissedLabel => 'Correcte';

  @override
  String get incorrectSelectedLabel => 'Incorrecte';

  @override
  String get generateQuestionsWithAI => 'Generar preguntes amb IA';

  @override
  String get aiGenerateDialogTitle => 'Generar Preguntes amb IA';

  @override
  String get aiQuestionCountLabel => 'Nombre de Preguntes (Opcional)';

  @override
  String get aiQuestionCountHint => 'Deixeu buit perquè la IA decideixi';

  @override
  String get aiQuestionCountValidation => 'Ha de ser un número entre 1 i 50';

  @override
  String get aiQuestionTypeLabel => 'Tipus de Pregunta';

  @override
  String get aiQuestionTypeRandom => 'Aleatori (Mixt)';

  @override
  String get aiLanguageLabel => 'Idioma de les Preguntes';

  @override
  String get aiContentLabel => 'Contingut per generar preguntes';

  @override
  String aiWordCount(int current, int max) {
    return '$current / $max paraules';
  }

  @override
  String get aiContentHint =>
      'Introduïu el text, tema, o contingut a partir del qual voleu generar preguntes...';

  @override
  String get aiContentHelperText =>
      'La IA crearà preguntes basades en aquest contingut';

  @override
  String aiWordLimitError(int max) {
    return 'Heu excedit el límit de $max paraules';
  }

  @override
  String get aiContentRequiredError =>
      'Heu de proporcionar contingut per generar preguntes';

  @override
  String aiContentLimitError(int max) {
    return 'El contingut supera el límit de $max paraules';
  }

  @override
  String get aiMinWordsError =>
      'Proporcioneu almenys 10 paraules per generar preguntes de qualitat';

  @override
  String get aiInfoTitle => 'Informació';

  @override
  String get aiInfoDescription =>
      '• La IA analitzarà el contingut i generarà preguntes rellevants\n• Podeu incloure text, definicions, explicacions, o qualsevol material educatiu\n• Les preguntes inclouran opcions de resposta i explicacions\n• El procés pot trigar uns segons';

  @override
  String get aiGenerateButton => 'Generar Preguntes';

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
  String get aiServicesLoading => 'Carregant serveis IA...';

  @override
  String get aiServicesNotConfigured => 'Cap servei IA configurat';

  @override
  String get aiGeneratedQuestions => 'Generat per IA';

  @override
  String get aiApiKeyRequired =>
      'Configureu almenys una clau API IA a la Configuració per usar generació IA.';

  @override
  String get aiGenerationFailed =>
      'No s\'han pogut generar preguntes. Proveu amb contingut diferent.';

  @override
  String aiGenerationError(String error) {
    return 'Error en generar preguntes: $error';
  }

  @override
  String get noQuestionsInFile => 'Cap pregunta trobada al fitxer importat';

  @override
  String get couldNotAccessFile =>
      'No s\'ha pogut accedir al fitxer seleccionat';

  @override
  String get defaultOutputFileName => 'fitxer-sortida.quiz';

  @override
  String aiServiceLimitsWithChars(int words, int chars) {
    return 'Límit: $words paraules o $chars caràcters';
  }

  @override
  String aiServiceLimitsWordsOnly(int words) {
    return 'Límit: $words paraules';
  }
}
