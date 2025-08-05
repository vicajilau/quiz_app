// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Galician (`gl`).
class AppLocalizationsGl extends AppLocalizations {
  AppLocalizationsGl([String locale = 'gl']) : super(locale);

  @override
  String get titleAppBar => 'Quiz - Simulador de Exames';

  @override
  String get create => 'Crear';

  @override
  String get load => 'Cargar';

  @override
  String fileLoaded(String filePath) {
    return 'Ficheiro cargado: $filePath';
  }

  @override
  String fileSaved(String filePath) {
    return 'Ficheiro gardado: $filePath';
  }

  @override
  String get dropFileHere =>
      'Preme aquí ou arrastra un ficheiro .quiz á pantalla';

  @override
  String get errorInvalidFile =>
      'Erro: Ficheiro non válido. Debe ser un ficheiro .quiz.';

  @override
  String errorLoadingFile(String error) {
    return 'Erro cargando o ficheiro Quiz: $error';
  }

  @override
  String errorExportingFile(String error) {
    return 'Erro exportando o ficheiro: $error';
  }

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get saveButton => 'Gardar';

  @override
  String get confirmDeleteTitle => 'Confirmar Eliminación';

  @override
  String confirmDeleteMessage(String processName) {
    return 'Estás seguro de que queres eliminar o proceso `$processName`?';
  }

  @override
  String get deleteButton => 'Eliminar';

  @override
  String get confirmExitTitle => 'Confirmar Saída';

  @override
  String get confirmExitMessage =>
      'Estás seguro de que queres saír sen gardar?';

  @override
  String get exitButton => 'Saír';

  @override
  String get saveDialogTitle => 'Selecciona un ficheiro de saída:';

  @override
  String get createQuizFileTitle => 'Crear Ficheiro Quiz';

  @override
  String get fileNameLabel => 'Nome do Ficheiro';

  @override
  String get fileDescriptionLabel => 'Descrición do Ficheiro';

  @override
  String get createButton => 'Crear';

  @override
  String get fileNameRequiredError => 'O nome do ficheiro é obrigatorio.';

  @override
  String get fileDescriptionRequiredError =>
      'A descrición do ficheiro é obrigatoria.';

  @override
  String get versionLabel => 'Versión';

  @override
  String get authorLabel => 'Autor';

  @override
  String get authorRequiredError => 'O autor é obrigatorio.';

  @override
  String get requiredFieldsError =>
      'Todos os campos obrigatorios deben ser completados.';

  @override
  String get requestFileNameTitle => 'Introduce o nome do ficheiro Quiz';

  @override
  String get fileNameHint => 'Nome do ficheiro';

  @override
  String get emptyFileNameMessage =>
      'O nome do ficheiro non pode estar baleiro.';

  @override
  String get acceptButton => 'Aceptar';

  @override
  String get saveTooltip => 'Gardar o ficheiro';

  @override
  String get saveDisabledTooltip => 'Non hai cambios que gardar';

  @override
  String get executeTooltip => 'Executar o exame';

  @override
  String get addTooltip => 'Engadir unha nova pregunta';

  @override
  String get backSemanticLabel => 'Botón volver';

  @override
  String get createFileTooltip => 'Crear un novo ficheiro Quiz';

  @override
  String get loadFileTooltip => 'Cargar un ficheiro Quiz existente';

  @override
  String questionNumber(int number) {
    return 'Pregunta $number';
  }

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Seguinte';

  @override
  String get finish => 'Rematar';

  @override
  String get finishQuiz => 'Rematar Quiz';

  @override
  String get finishQuizConfirmation =>
      'Estás seguro de que queres rematar o quiz? Non poderás cambiar as túas respostas despois.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get abandonQuiz => 'Abandonar Quiz';

  @override
  String get abandonQuizConfirmation =>
      'Estás seguro de que queres abandonar o quiz? Todo o progreso perderase.';

  @override
  String get abandon => 'Abandonar';

  @override
  String get quizCompleted => 'Quiz Completado!';

  @override
  String score(String score) {
    return 'Puntuación: $score%';
  }

  @override
  String correctAnswers(int correct, int total) {
    return '$correct de $total respostas correctas';
  }

  @override
  String get retry => 'Reintentar';

  @override
  String get goBack => 'Rematar';

  @override
  String get retryFailedQuestions => 'Reintentar Falladas';

  @override
  String question(String question) {
    return 'Pregunta: $question';
  }

  @override
  String get selectQuestionCountTitle => 'Seleccionar Número de Preguntas';

  @override
  String get selectQuestionCountMessage =>
      'A cantas preguntas te gustaría responder neste quiz?';

  @override
  String allQuestions(int count) {
    return 'Todas as preguntas ($count)';
  }

  @override
  String get startQuiz => 'Comezar Quiz';

  @override
  String get customNumberLabel => 'Ou introduce un número personalizado:';

  @override
  String get numberInputLabel => 'Número de preguntas';

  @override
  String customNumberHelper(int total) {
    return 'Introduce calquera número (máx $total). Se é maior, as preguntas repetiránse.';
  }

  @override
  String get errorInvalidNumber => 'Por favor, introduce un número válido';

  @override
  String get errorNumberMustBePositive => 'O número debe ser maior que 0';

  @override
  String get questionOrderConfigTitle => 'Configuración da Orde das Preguntas';

  @override
  String get questionOrderConfigDescription =>
      'Selecciona a orde na que queres que aparezan as preguntas durante o exame:';

  @override
  String get questionOrderAscending => 'Orde Ascendente';

  @override
  String get questionOrderAscendingDesc =>
      'As preguntas aparecerán en orde de 1 ao final';

  @override
  String get questionOrderDescending => 'Orde Descendente';

  @override
  String get questionOrderDescendingDesc =>
      'As preguntas aparecerán do final a 1';

  @override
  String get questionOrderRandom => 'Aleatorio';

  @override
  String get questionOrderRandomDesc =>
      'As preguntas aparecerán en orde aleatorio';

  @override
  String get questionOrderConfigTooltip =>
      'Configuración da orde das preguntas';

  @override
  String get save => 'Gardar';

  @override
  String get examTimeLimitTitle => 'Límite de Tempo do Exame';

  @override
  String get examTimeLimitDescription =>
      'Estabelece un límite de tempo para o exame. Cando se active, mostrarásee un temporizador de conta atrás durante o quiz.';

  @override
  String get enableTimeLimit => 'Activar límite de tempo';

  @override
  String get timeLimitMinutes => 'Límite de tempo (minutos)';

  @override
  String get examTimeExpiredTitle => 'Tempo Esgotado!';

  @override
  String get examTimeExpiredMessage =>
      'O tempo do exame expirou. As túas respostas enviáronse automaticamente.';

  @override
  String remainingTime(String hours, String minutes, String seconds) {
    return '$hours:$minutes:$seconds';
  }

  @override
  String get questionTypeMultipleChoice => 'Elección Múltiple';

  @override
  String get questionTypeSingleChoice => 'Elección Única';

  @override
  String get questionTypeTrueFalse => 'Certo/Falso';

  @override
  String get questionTypeEssay => 'Ensaio';

  @override
  String get questionTypeUnknown => 'Descoñecido';

  @override
  String optionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opcións',
      one: '1 opción',
    );
    return '$_temp0';
  }

  @override
  String get optionsTooltip =>
      'Número de opcións de resposta para esta pregunta';

  @override
  String get imageTooltip => 'Esta pregunta ten unha imaxe asociada';

  @override
  String get explanationTooltip => 'Esta pregunta ten unha explicación';

  @override
  String get aiPrompt =>
      'Es un titor experto e amigable especializado en axudar aos estudantes a comprender mellor as preguntas de exame e os temas relacionados. O teu obxectivo é facilitar a aprendizaxe profunda e a comprensión conceptual.\n\nPodes axudar con:\n- Explicar conceptos relacionados coa pregunta\n- Aclarar dúbidas sobre as opcións de resposta\n- Proporcionar contexto adicional sobre o tema\n- Suxerir recursos de estudo complementarios\n- Explicar por que certas respostas son correctas ou incorrectas\n- Relacionar o tema con outros conceptos importantes\n- Responder preguntas de seguimento sobre o material\n\nSempre responde na mesma lingua na que se che pregunta. Sé pedagóxico, claro e motivador nas túas explicacións.';

  @override
  String get questionLabel => 'Pregunta';

  @override
  String get optionsLabel => 'Opcións';

  @override
  String get explanationLabel => 'Explicación (opcional)';

  @override
  String get studentComment => 'Comentario do estudante';

  @override
  String get aiAssistantTitle => 'Asistente de Estudo IA';

  @override
  String get questionContext => 'Contexto da Pregunta';

  @override
  String get aiAssistant => 'Asistente IA';

  @override
  String get aiThinking => 'A IA está pensando...';

  @override
  String get askAIHint => 'Fai a túa pregunta sobre este tema...';

  @override
  String get aiPlaceholderResponse =>
      'Esta é unha resposta de marcador de posición. Nunha implementación real, isto conectaríase a un servizo IA para proporcionar explicacións útiles sobre a pregunta.';

  @override
  String get aiErrorResponse =>
      'Síntoo, houbo un erro procesando a túa pregunta. Téntao de novo.';

  @override
  String get configureApiKeyMessage =>
      'Por favor, configura a túa Clave API IA na Configuración.';

  @override
  String get errorLabel => 'Erro:';

  @override
  String get noResponseReceived => 'Non se recibiu resposta';

  @override
  String get invalidApiKeyError =>
      'Clave API non válida. Comproba a túa Clave API OpenAI na configuración.';

  @override
  String get rateLimitError =>
      'Límite de velocidade superado. Téntao de novo máis tarde.';

  @override
  String get modelNotFoundError =>
      'Modelo non atopado. Comproba o teu acceso á API.';

  @override
  String get unknownError => 'Erro descoñecido';

  @override
  String get networkError =>
      'Erro de rede: Non se pode conectar a OpenAI. Comproba a túa conexión a internet.';

  @override
  String get openaiApiKeyNotConfigured => 'Clave API OpenAI non configurada';

  @override
  String get geminiApiKeyNotConfigured => 'Clave API Gemini non configurada';

  @override
  String get geminiApiKeyLabel => 'Clave API Google Gemini';

  @override
  String get geminiApiKeyHint => 'Introduce a túa Clave API Gemini';

  @override
  String get geminiApiKeyDescription =>
      'Requirido para a funcionalidade IA Gemini. A túa clave gárdase de forma segura.';

  @override
  String get getGeminiApiKeyTooltip => 'Obter Clave API de Google AI Studio';

  @override
  String get aiRequiresAtLeastOneApiKeyError =>
      'O Asistente de Estudo IA require polo menos unha Clave API (OpenAI ou Gemini). Introduce unha clave API ou desactiva o Asistente IA.';

  @override
  String get minutesAbbreviation => 'min';

  @override
  String get aiButtonTooltip => 'Asistente de Estudo IA';

  @override
  String get aiButtonText => 'IA';

  @override
  String get aiAssistantSettingsTitle =>
      'Asistente de Estudo IA (Vista previa)';

  @override
  String get aiAssistantSettingsDescription =>
      'Activar ou desactivar o asistente de estudo IA para as preguntas';

  @override
  String get openaiApiKeyLabel => 'Clave API OpenAI';

  @override
  String get openaiApiKeyHint => 'Introduce a túa Clave API OpenAI (sk-...)';

  @override
  String get openaiApiKeyDescription =>
      'Requirido para a funcionalidade IA. A túa clave gárdase de forma segura.';

  @override
  String get aiAssistantRequiresApiKeyError =>
      'O Asistente de Estudo IA require unha Clave API OpenAI. Introduce a túa clave API ou desactiva o Asistente IA.';

  @override
  String get getApiKeyTooltip => 'Obter Clave API de OpenAI';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get explanationHint =>
      'Introduce unha explicación para a/as resposta/as correcta/as';

  @override
  String get explanationTitle => 'Explicación';

  @override
  String get imageLabel => 'Imaxe';

  @override
  String get changeImage => 'Cambiar imaxe';

  @override
  String get removeImage => 'Eliminar imaxe';

  @override
  String get addImageTap => 'Toca para engadir imaxe';

  @override
  String get imageFormats => 'Formatos: JPG, PNG, GIF';

  @override
  String get imageLoadError => 'Erro cargando a imaxe';

  @override
  String imagePickError(String error) {
    return 'Erro cargando a imaxe: $error';
  }

  @override
  String get tapToZoom => 'Toca para ampliar';

  @override
  String get trueLabel => 'Certo';

  @override
  String get falseLabel => 'Falso';

  @override
  String get addQuestion => 'Engadir Pregunta';

  @override
  String get editQuestion => 'Editar Pregunta';

  @override
  String get questionText => 'Texto da Pregunta';

  @override
  String get questionType => 'Tipo de Pregunta';

  @override
  String get addOption => 'Engadir Opción';

  @override
  String get optionLabel => 'Opción';

  @override
  String get questionTextRequired => 'O texto da pregunta é obrigatorio';

  @override
  String get atLeastOneOptionRequired =>
      'Polo menos unha opción debe ter texto';

  @override
  String get atLeastOneCorrectAnswerRequired =>
      'Polo menos unha resposta correcta debe ser seleccionada';

  @override
  String get onlyOneCorrectAnswerAllowed =>
      'Só se permite unha resposta correcta para este tipo de pregunta';

  @override
  String get removeOption => 'Eliminar opción';

  @override
  String get selectCorrectAnswer => 'Seleccionar resposta correcta';

  @override
  String get selectCorrectAnswers => 'Seleccionar respostas correctas';

  @override
  String emptyOptionsError(String optionNumbers) {
    return 'As opcións $optionNumbers están baleiras. Engádelles texto ou elimínaas.';
  }

  @override
  String emptyOptionError(String optionNumber) {
    return 'A opción $optionNumber está baleira. Engádelle texto ou elimínaa.';
  }

  @override
  String get optionEmptyError => 'Esta opción non pode estar baleira';

  @override
  String get hasImage => 'Imaxe';

  @override
  String get hasExplanation => 'Explicación';

  @override
  String errorLoadingSettings(String error) {
    return 'Erro cargando a configuración: $error';
  }

  @override
  String couldNotOpenUrl(String url) {
    return 'Non se puido abrir $url';
  }

  @override
  String get loadingAiServices => 'Cargando servizos IA...';

  @override
  String usingAiService(String serviceName) {
    return 'Usando: $serviceName';
  }

  @override
  String get aiServiceLabel => 'Servizo IA:';

  @override
  String get importQuestionsTitle => 'Importar Preguntas';

  @override
  String importQuestionsMessage(int count, String fileName) {
    return 'Atopadas $count preguntas en \"$fileName\". Onde queres importalas?';
  }

  @override
  String get importQuestionsPositionQuestion =>
      'Onde queres engadir estas preguntas?';

  @override
  String get importAtBeginning => 'Ao Principio';

  @override
  String get importAtEnd => 'Ao Final';

  @override
  String questionsImportedSuccess(int count) {
    return 'Importadas con éxito $count preguntas';
  }

  @override
  String get importQuestionsTooltip =>
      'Importar preguntas doutro ficheiro quiz';

  @override
  String get dragDropHintText =>
      'Tamén podes arrastrar e soltar ficheiros .quiz aquí para importar preguntas';

  @override
  String get randomizeAnswersTitle => 'Aleatorizar Opcións de Resposta';

  @override
  String get randomizeAnswersDescription =>
      'Barallar a orde das opcións de resposta durante a execución do quiz';

  @override
  String get showCorrectAnswerCountTitle =>
      'Mostrar Número de Respostas Correctas';

  @override
  String get showCorrectAnswerCountDescription =>
      'Mostrar o número de respostas correctas en preguntas de elección múltiple';

  @override
  String correctAnswersCount(int count) {
    return 'Selecciona $count respostas correctas';
  }

  @override
  String get correctSelectedLabel => 'Correcta';

  @override
  String get correctMissedLabel => 'Correcta';

  @override
  String get incorrectSelectedLabel => 'Incorrecta';

  @override
  String get generateQuestionsWithAI => 'Xerar preguntas con IA';

  @override
  String get aiGenerateDialogTitle => 'Xerar Preguntas con IA';

  @override
  String get aiQuestionCountLabel => 'Número de Preguntas (Opcional)';

  @override
  String get aiQuestionCountHint => 'Deixa baleiro para que a IA decida';

  @override
  String get aiQuestionCountValidation => 'Debe ser un número entre 1 e 50';

  @override
  String get aiQuestionTypeLabel => 'Tipo de Pregunta';

  @override
  String get aiQuestionTypeRandom => 'Aleatorio (Mixto)';

  @override
  String get aiLanguageLabel => 'Idioma das Preguntas';

  @override
  String get aiContentLabel => 'Contido para xerar preguntas';

  @override
  String aiWordCount(int current, int max) {
    return '$current / $max palabras';
  }

  @override
  String get aiContentHint =>
      'Introduce o texto, tema, ou contido a partir do cal queres xerar preguntas...';

  @override
  String get aiContentHelperText =>
      'A IA creará preguntas baseadas neste contido';

  @override
  String aiWordLimitError(int max) {
    return 'Superaches o límite de $max palabras';
  }

  @override
  String get aiContentRequiredError =>
      'Debes proporcionar contido para xerar preguntas';

  @override
  String aiContentLimitError(int max) {
    return 'O contido supera o límite de $max palabras';
  }

  @override
  String get aiMinWordsError =>
      'Proporciona polo menos 10 palabras para xerar preguntas de calidade';

  @override
  String get aiInfoTitle => 'Información';

  @override
  String get aiInfoDescription =>
      '• A IA analizará o contido e xerará preguntas relevantes\n• Podes incluír texto, definicións, explicacións, ou calquera material educativo\n• As preguntas incluirán opcións de resposta e explicacións\n• O proceso pode tardar uns segundos';

  @override
  String get aiGenerateButton => 'Xerar Preguntas';

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
  String get aiServicesLoading => 'Cargando servizos IA...';

  @override
  String get aiServicesNotConfigured => 'Non hai servizos IA configurados';

  @override
  String get aiGeneratedQuestions => 'Xerado por IA';

  @override
  String get aiApiKeyRequired =>
      'Configura polo menos unha clave API IA na Configuración para usar xeración IA.';

  @override
  String get aiGenerationFailed =>
      'Non se puideron xerar preguntas. Proba con contido diferente.';

  @override
  String aiGenerationError(String error) {
    return 'Erro xerando preguntas: $error';
  }

  @override
  String get noQuestionsInFile =>
      'Non se atoparon preguntas no ficheiro importado';

  @override
  String get couldNotAccessFile =>
      'Non se puido acceder ao ficheiro seleccionado';

  @override
  String get defaultOutputFileName => 'ficheiro-saída.quiz';

  @override
  String aiServiceLimitsWithChars(int words, int chars) {
    return 'Límite: $words palabras ou $chars caracteres';
  }

  @override
  String aiServiceLimitsWordsOnly(int words) {
    return 'Límite: $words palabras';
  }

  @override
  String get aiAssistantDisabled => 'Asistente de IA Deshabilitado';

  @override
  String get enableAiAssistant =>
      'O asistente de IA está deshabilitado. Actívao na configuración para usar as funcionalidades de IA.';
}
