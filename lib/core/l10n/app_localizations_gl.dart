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
  String get preview => 'Previsualizacion';

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
  String get clickOrDragFile =>
      'Preme para cargar ou arrastra un ficheiro .quiz á pantalla';

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
  String get editQuizFileTitle => 'Editar Ficheiro Quiz';

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
  String get errorInvalidNumber => 'Por favor, introduce un número válido';

  @override
  String get errorNumberMustBePositive => 'O número debe ser maior que 0';

  @override
  String get customNumberLabel => 'Ou introduce un número personalizado:';

  @override
  String customNumberHelper(int total) {
    return 'Introduce calquera número (máx $total). Se é maior, as preguntas repetiránse.';
  }

  @override
  String get numberInputLabel => 'Número de preguntas';

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
  String get reorderQuestionsTooltip => 'Reordenar preguntas';

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
  String get missingExplanation => 'Falta explicación';

  @override
  String get missingExplanationTooltip => 'Esta pregunta non ten explicación';

  @override
  String questionTypeTooltip(String type) {
    return 'Tipo de pregunta: $type';
  }

  @override
  String get aiPrompt =>
      'Céntrate na pregunta do estudante, non en responder directamente a pregunta orixinal do exame. Explica cun enfoque pedagóxico, proporcionando argumentos claros sen divagar nin saír do tema. Non estrutures a resposta en seccións. Non te refiras a ti mesmo. Responde na mesma lingua na que se che pregunta.';

  @override
  String get questionLabel => 'Pregunta';

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
      'Cota excedida ou modelo non dispoñible no teu plan.';

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
  String get geminiApiKeyLabel => 'Clave API Gemini';

  @override
  String get geminiApiKeyHint => 'Introduce a túa Clave API Gemini';

  @override
  String get geminiApiKeyDescription =>
      'Requirido para a funcionalidade IA Gemini. A túa clave gárdase de forma segura.';

  @override
  String get getGeminiApiKeyTooltip => 'Obter Clave API de Google AI Studio';

  @override
  String get aiRequiresAtLeastOneApiKeyError =>
      'O Asistente de Estudo IA require polo menos unha clave API (Gemini ou OpenAI). Por favor, introduce unha clave API ou desactiva o Asistente de IA.';

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
  String get aiDefaultModelTitle => 'Modelo IA por defecto';

  @override
  String get aiDefaultModelDescription =>
      'Selecciona o servizo e modelo IA por defecto para a xeración de preguntas';

  @override
  String get openaiApiKeyLabel => 'Clave API OpenAI';

  @override
  String get openaiApiKeyHint => 'Introduce a túa Clave API OpenAI (sk-...)';

  @override
  String get openaiApiKeyDescription =>
      'Requirido para a integración con OpenAI. A túa clave de OpenAI gárdase de forma segura.';

  @override
  String get aiAssistantRequiresApiKeyError =>
      'O Asistente de Estudo IA require unha Clave API OpenAI. Introduce a túa clave API ou desactiva o Asistente IA.';

  @override
  String get getApiKeyTooltip => 'Obter Clave API de OpenAI';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get explanationLabel => 'Explicación (opcional)';

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
  String get optionsLabel => 'Opcións';

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
  String get aiModelLabel => 'Modelo:';

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
      '• A IA analizará o contido e xerará preguntas relevantes\n• Se escribes menos de 10 palabras entrarás no modo Tema onde se farán preguntas sobre eses temas específicos\n• Con máis de 10 palabras entrarás no modo Contido que fará preguntas sobre ese mesmo texto (máis palabras = máis precisión)\n• Podes incluír testo, definicións, explicacións, o calquera material educativo\n• As preguntas incluirán opcións de resposta e explicacións\n• O proceso pode tardar uns segundos';

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
  String get languageGreek => 'Ελληνικά';

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
  String get generateQuestionsWithAI => 'Xerar preguntas con IA';

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

  @override
  String aiMinWordsRequired(int minWords) {
    return 'Mínimo $minWords palabras necesarias';
  }

  @override
  String aiWordsReadyToGenerate(int wordCount) {
    return '$wordCount palabras ✓ Listo para xerar';
  }

  @override
  String aiWordsProgress(int currentWords, int minWords, int moreNeeded) {
    return '$currentWords/$minWords palabras ($moreNeeded máis necesarias)';
  }

  @override
  String aiValidationMinWords(int minWords, int moreNeeded) {
    return 'Mínimo $minWords palabras necesarias ($moreNeeded máis necesarias)';
  }

  @override
  String get enableQuestion => 'Activar pregunta';

  @override
  String get disableQuestion => 'Desactivar pregunta';

  @override
  String get questionDisabled => 'Desactivada';

  @override
  String get noEnabledQuestionsError =>
      'Non hai preguntas activadas dispoñibles para executar o cuestionario';

  @override
  String get evaluateWithAI => 'Avaliar con IA';

  @override
  String get aiEvaluation => 'Avaliación de IA';

  @override
  String aiEvaluationError(String error) {
    return 'Erro ao avaliar a resposta: $error';
  }

  @override
  String get aiEvaluationPromptSystemRole =>
      'Es un profesor especializado en avaliar respostas de estudantes a preguntas de ensaio. A túa tarefa é proporcionar avaliacións detalladas e construtivas. Responde no mesmo idioma que a resposta do estudante.';

  @override
  String get aiEvaluationPromptQuestion => 'Pregunta:';

  @override
  String get aiEvaluationPromptStudentAnswer => 'Resposta do estudante:';

  @override
  String get aiEvaluationPromptCriteria =>
      'Criterios de avaliación (baseados na explicación do profesor):';

  @override
  String get aiEvaluationPromptSpecificInstructions =>
      'Instrucións específicas:\n- Avalía ata que punto a resposta do estudante se axusta aos criterios establecidos\n- Analiza o grao de integración e estrutura na resposta\n- Identifica se non se tivo en conta algo importante segundo os criterios\n- Considera a profundidade e precisión da análise';

  @override
  String get aiEvaluationPromptGeneralInstructions =>
      'Instrucións xerais:\n- Como non se estableceron criterios específicos, avalía a resposta baseándote en estándares académicos xerais\n- Considera a claridade, coherencia e estrutura da resposta\n- Avalía se a resposta demostra comprensión do tema\n- Analiza a profundidade da análise e a calidade da argumentación';

  @override
  String get aiEvaluationPromptResponseFormat =>
      'Formato de resposta:\n1. Puntuación: [X/10] - Xustifica brevemente a puntuación\n2. Puntos fortes: Indica os aspectos positivos da resposta\n3. Áreas de mellora: Sinala os aspectos que se poden mellorar\n4. Comentarios específicos: Proporciona retroalimentación detallada e construtiva\n5. Suxestións: Ofrece recomendacións específicas para mellorar\n\nSé construtivo, específico e educativo na túa avaliación. O obxectivo é axudar ao estudante a aprender e mellorar. Diríxete a el en segunda persoa e utiliza un ton profesional pero accesible.';

  @override
  String get raffleTitle => 'Sorteo';

  @override
  String get raffleTooltip => 'Comezar sorteo';

  @override
  String get participantListTitle => 'Lista de Participantes';

  @override
  String get participantListHint =>
      'Introduce nomes separados por salto de liña';

  @override
  String get participantListPlaceholder =>
      'Introduce os nomes dos participantes aquí...\nUn nome por liña';

  @override
  String get clearList => 'Limpar Lista';

  @override
  String get participants => 'Participantes';

  @override
  String get noParticipants => 'Non hai participantes';

  @override
  String get addParticipantsHint =>
      'Engade participantes para comezar o sorteo';

  @override
  String get activeParticipants => 'Participantes Activos';

  @override
  String get alreadySelected => 'Xa Seleccionados';

  @override
  String totalParticipants(int count) {
    return 'Total de Participantes';
  }

  @override
  String activeVsWinners(int active, int winners) {
    return '$active activos, $winners gañadores';
  }

  @override
  String get startRaffle => 'Comezar Sorteo';

  @override
  String get raffling => 'Sorteando...';

  @override
  String get selectingWinner => 'Seleccionando gañador...';

  @override
  String get allParticipantsSelected =>
      'Todos os participantes foron seleccionados';

  @override
  String get addParticipantsToStart =>
      'Engade participantes para comezar o sorteo';

  @override
  String participantsReadyCount(int count) {
    return '$count participantes listos para o sorteo';
  }

  @override
  String get resetWinners => 'Reiniciar Gañadores';

  @override
  String get resetWinnersConfirmTitle => 'Reiniciar gañadores?';

  @override
  String get resetWinnersConfirmMessage =>
      'Isto devolverá todos os gañadores á lista de participantes activos.';

  @override
  String get resetRaffleTitle => 'Reiniciar sorteo?';

  @override
  String get resetRaffleConfirmMessage =>
      'Isto reiniciará todos os gañadores e participantes activos.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get reset => 'Reiniciar';

  @override
  String get viewWinners => 'Ver Gañadores';

  @override
  String get congratulations => 'Parabéns!';

  @override
  String positionLabel(int position) {
    return 'Posición $position';
  }

  @override
  String remainingParticipants(int count) {
    return 'Participantes restantes: $count';
  }

  @override
  String get continueRaffle => 'Continuar Sorteo';

  @override
  String get finishRaffle => 'Finalizar Sorteo';

  @override
  String get winnersTitle => 'Gañadores';

  @override
  String get shareResults => 'Compartir Resultados';

  @override
  String get noWinnersYet => 'Aínda non hai gañadores';

  @override
  String get performRaffleToSeeWinners =>
      'Realiza un sorteo para ver os gañadores';

  @override
  String get goToRaffle => 'Ir ao Sorteo';

  @override
  String get raffleCompleted => 'Sorteo completado!';

  @override
  String winnersSelectedCount(int count) {
    return '$count gañadores seleccionados';
  }

  @override
  String get newRaffle => 'Novo Sorteo';

  @override
  String get shareResultsTitle => 'Resultados do Sorteo';

  @override
  String get raffleResultsLabel => 'Resultados do sorteo:';

  @override
  String get close => 'Pechar';

  @override
  String get share => 'Copiar';

  @override
  String get shareNotImplemented => 'Compartir aínda non está implementado';

  @override
  String get firstPlace => 'Primeiro Lugar';

  @override
  String get secondPlace => 'Segundo Lugar';

  @override
  String get thirdPlace => 'Terceiro Lugar';

  @override
  String nthPlace(int position) {
    return 'Lugar $position';
  }

  @override
  String placeLabel(String position) {
    return 'Lugar';
  }

  @override
  String get raffleResultsHeader => 'Resultados do Sorteo - null gañadores';

  @override
  String totalWinners(int count) {
    return 'Total de gañadores: $count';
  }

  @override
  String get noWinnersToShare => 'Non hai gañadores para compartir';

  @override
  String get shareSuccess => 'Resultados copiados exitosamente';

  @override
  String get selectLogo => 'Seleccionar Logo';

  @override
  String get logoUrl => 'URL do Logo';

  @override
  String get logoUrlHint =>
      'Introduce a URL dunha imaxe para usar como logo personalizado para o sorteo';

  @override
  String get invalidLogoUrl =>
      'URL de imaxe non válida. Debe ser unha URL válida que remate en .jpg, .png, .gif, etc.';

  @override
  String get logoPreview => 'Vista Previa';

  @override
  String get removeLogo => 'Eliminar Logo';

  @override
  String get logoTooLargeWarning =>
      'A imaxe é demasiado grande para gardarse. Só se usará durante esta sesión.';

  @override
  String get aiModeTopicTitle => 'Modo Tema';

  @override
  String get aiModeTopicDescription => 'Exploración creativa do tema';

  @override
  String get aiModeContentTitle => 'Modo Contido';

  @override
  String get aiModeContentDescription =>
      'Preguntas precisas baseadas na túa entrada';

  @override
  String aiWordCountIndicator(int count) {
    return '$count palabras';
  }

  @override
  String aiPrecisionIndicator(String level) {
    return 'Precisión: $level';
  }

  @override
  String get aiPrecisionLow => 'Baixa';

  @override
  String get aiPrecisionMedium => 'Media';

  @override
  String get aiPrecisionHigh => 'Alta';

  @override
  String get aiMoreWordsMorePrecision => 'Máis palabras = máis precisión';

  @override
  String get aiKeepDraftTitle => 'Manter o borrador da IA';

  @override
  String get aiKeepDraftDescription =>
      'Gardar automaticamente o texto introducido no diálogo de xeración de IA para que non se perda se se pecha o diálogo.';

  @override
  String get aiAttachFile => 'Anexar ficheiro';

  @override
  String get aiRemoveFile => 'Eliminar ficheiro';

  @override
  String get aiFileMode => 'Modo ficheiro';

  @override
  String get aiFileModeDescription =>
      'As preguntas xeraranse a partir do ficheiro anexado';

  @override
  String get aiCommentsLabel => 'Comentarios (Opcional)';

  @override
  String get aiCommentsHint =>
      'Engade instrucións ou comentarios sobre o ficheiro anexado...';

  @override
  String get aiCommentsHelperText =>
      'Opcionalmente, engade instrucións sobre como xerar preguntas a partir do ficheiro';

  @override
  String get aiFilePickerError => 'Non se puido cargar o ficheiro seleccionado';

  @override
  String get studyModeLabel => 'Modo Estudo';

  @override
  String get studyModeDescription =>
      'Retroalimentación instantánea e sen tempo';

  @override
  String get examModeLabel => 'Modo Exame';

  @override
  String get examModeDescription => 'Tempo estándar e resultados ao final';

  @override
  String get checkAnswer => 'Comprobar';

  @override
  String get quizModeTitle => 'Modo Cuestionario';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get skip => 'Saltar';

  @override
  String get askAiAssistant => 'Preguntar ao Asistente de IA';

  @override
  String get sorteosLabel => 'Raffles';

  @override
  String get edit => 'Editar';

  @override
  String get enable => 'Activar';

  @override
  String get disable => 'Desactivar';

  @override
  String get quizPreviewTitle => 'Vista previa do cuestionario';

  @override
  String get select => 'Seleccionar';

  @override
  String get done => 'Feito';

  @override
  String get importButton => 'Importar';

  @override
  String get reorderButton => 'Reordenar';

  @override
  String get startQuizButton => 'Comezar cuestionario';

  @override
  String get deleteConfirmation =>
      'Estás seguro de que queres eliminar este cuestionario?';

  @override
  String get saveSuccess => 'Ficheiro gardado correctamente';

  @override
  String get errorSavingFile => 'Erro ao gardar o ficheiro';

  @override
  String get deleteSingleQuestionConfirmation =>
      'Estás seguro de que queres eliminar esta pregunta?';

  @override
  String deleteMultipleQuestionsConfirmation(int count) {
    return 'Estás seguro de que queres eliminar $count preguntas?';
  }
}
