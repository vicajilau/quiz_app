// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get titleAppBar => 'Quiz - Simulador de Exámenes';

  @override
  String get create => 'Crear';

  @override
  String get load => 'Cargar';

  @override
  String fileLoaded(String filePath) {
    return 'Archivo cargado: $filePath';
  }

  @override
  String fileSaved(String filePath) {
    return 'Archivo guardado: $filePath';
  }

  @override
  String get dropFileHere =>
      'Haz clic aquí o arrastra un archivo .quiz a la pantalla';

  @override
  String get errorInvalidFile =>
      'Error: archivo no válido. Debe ser un archivo .quiz.';

  @override
  String errorLoadingFile(String error) {
    return 'Error al cargar el archivo: $error';
  }

  @override
  String errorExportingFile(String error) {
    return 'Error al exportar el archivo: $error';
  }

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get saveButton => 'Guardar';

  @override
  String get confirmDeleteTitle => 'Confirmar Eliminación';

  @override
  String confirmDeleteMessage(String processName) {
    return '¿Estás seguro de que quieres eliminar `$processName`?';
  }

  @override
  String get deleteButton => 'Eliminar';

  @override
  String get confirmExitTitle => 'Confirmar Salida';

  @override
  String get confirmExitMessage =>
      '¿Estás seguro de que quieres salir sin guardar?';

  @override
  String get exitButton => 'Salir';

  @override
  String get saveDialogTitle => 'Por favor selecciona un archivo de salida:';

  @override
  String get createQuizFileTitle => 'Crear Archivo Quiz';

  @override
  String get fileNameLabel => 'Nombre del Archivo';

  @override
  String get fileDescriptionLabel => 'Descripción del Archivo';

  @override
  String get createButton => 'Crear';

  @override
  String get fileNameRequiredError => 'El nombre del archivo es requerido.';

  @override
  String get fileDescriptionRequiredError =>
      'La descripción del archivo es requerida.';

  @override
  String get versionLabel => 'Versión';

  @override
  String get authorLabel => 'Autor';

  @override
  String get authorRequiredError => 'El autor es requerido.';

  @override
  String get requiredFieldsError =>
      'Todos los campos requeridos deben ser completados.';

  @override
  String get requestFileNameTitle => 'Ingresa el nombre del archivo Quiz';

  @override
  String get fileNameHint => 'Nombre del archivo (opcional)';

  @override
  String get emptyFileNameMessage => 'Por favor, ingresa un nombre de archivo';

  @override
  String get acceptButton => 'Aceptar';

  @override
  String get saveTooltip => 'Guardar el archivo';

  @override
  String get saveDisabledTooltip => 'No hay cambios que guardar';

  @override
  String get executeTooltip => 'Ejecutar el examen';

  @override
  String get addTooltip => 'Agregar una nueva pregunta';

  @override
  String get backSemanticLabel => 'Botón volver';

  @override
  String get createFileTooltip => 'Crear un nuevo archivo Quiz';

  @override
  String get loadFileTooltip => 'Cargar un archivo Quiz existente';

  @override
  String questionNumber(int number) {
    return 'Pregunta $number';
  }

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Siguiente';

  @override
  String get finish => 'Finalizar';

  @override
  String get finishQuiz => 'Finalizar Quiz';

  @override
  String get finishQuizConfirmation =>
      '¿Estás seguro de que quieres finalizar el quiz? No podrás cambiar tus respuestas después.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get abandonQuiz => 'Abandonar Quiz';

  @override
  String get abandonQuizConfirmation =>
      '¿Estás seguro de que quieres abandonar el quiz? Se perderá todo el progreso.';

  @override
  String get abandon => 'Abandonar';

  @override
  String get quizCompleted => '¡Quiz Completado!';

  @override
  String score(String score) {
    return 'Puntuación';
  }

  @override
  String correctAnswers(int correct, int total) {
    return '$correct de $total respuestas correctas';
  }

  @override
  String get retry => 'Repetir';

  @override
  String get goBack => 'Finalizar';

  @override
  String get retryFailedQuestions => 'Reintentar errores';

  @override
  String question(String question) {
    return 'Pregunta: $question';
  }

  @override
  String get selectQuestionCountTitle => 'Seleccionar Número de Preguntas';

  @override
  String get selectQuestionCountMessage =>
      '¿Cuántas preguntas te gustaría responder en este quiz?';

  @override
  String allQuestions(int count) {
    return 'Todas las preguntas ($count)';
  }

  @override
  String get startQuiz => 'Iniciar Quiz';

  @override
  String get customNumberLabel => 'O introduce un número personalizado:';

  @override
  String get numberInputLabel => 'Número de preguntas';

  @override
  String customNumberHelper(int total) {
    return 'Si es mayor que $total, las preguntas se repetirán';
  }

  @override
  String get errorInvalidNumber => 'Por favor ingresa un número válido';

  @override
  String get errorNumberMustBePositive => 'El número debe ser mayor que 0';

  @override
  String get questionOrderConfigTitle => 'Configuración del Orden de Preguntas';

  @override
  String get questionOrderConfigDescription =>
      'Selecciona el orden en que deseas que aparezcan las preguntas durante el examen:';

  @override
  String get questionOrderAscending => 'Orden Ascendente';

  @override
  String get questionOrderAscendingDesc =>
      'Las preguntas aparecerán en orden del 1 al final';

  @override
  String get questionOrderDescending => 'Orden Descendente';

  @override
  String get questionOrderDescendingDesc =>
      'Las preguntas aparecerán del final al 1';

  @override
  String get questionOrderRandom => 'Aleatorio';

  @override
  String get questionOrderRandomDesc =>
      'Las preguntas aparecerán en orden aleatorio';

  @override
  String get questionOrderConfigTooltip =>
      'Configuración del orden de preguntas';

  @override
  String get save => 'Guardar';

  @override
  String get examTimeLimitTitle => 'Límite de Tiempo del Examen';

  @override
  String get examTimeLimitDescription =>
      'Establece un límite de tiempo para el examen. Cuando esté habilitado, se mostrará un cronómetro durante el quiz.';

  @override
  String get enableTimeLimit => 'Habilitar límite de tiempo';

  @override
  String get timeLimitMinutes => 'Límite de tiempo (minutos)';

  @override
  String get examTimeExpiredTitle => '¡Se acabó el tiempo!';

  @override
  String get examTimeExpiredMessage =>
      'El tiempo del examen ha expirado. Tus respuestas han sido enviadas automáticamente.';

  @override
  String remainingTime(String hours, String minutes, String seconds) {
    return '$hours:$minutes:$seconds';
  }

  @override
  String get questionTypeMultipleChoice => 'Opción múltiple';

  @override
  String get questionTypeSingleChoice => 'Opción única';

  @override
  String get questionTypeTrueFalse => 'Verdadero/Falso';

  @override
  String get questionTypeEssay => 'Ensayo';

  @override
  String get questionTypeUnknown => 'Desconocido';

  @override
  String optionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opciones',
      one: '1 opción',
    );
    return '$_temp0';
  }

  @override
  String get optionsTooltip =>
      'Número de opciones de respuesta para esta pregunta';

  @override
  String get imageTooltip => 'Esta pregunta tiene una imagen asociada';

  @override
  String get explanationTooltip => 'Esta pregunta tiene una explicación';

  @override
  String get aiPrompt =>
      'Eres un tutor experto y amigable especializado en ayudar a estudiantes a comprender mejor las preguntas de examen y los temas relacionados. Tu objetivo es facilitar el aprendizaje profundo y la comprensión conceptual.\n\nPuedes ayudar con:\n- Explicar conceptos relacionados con la pregunta\n- Aclarar dudas sobre las opciones de respuesta\n- Proporcionar contexto adicional sobre el tema\n- Sugerir recursos de estudio complementarios\n- Explicar por qué ciertas respuestas son correctas o incorrectas\n- Relacionar el tema con otros conceptos importantes\n- Responder preguntas de seguimiento sobre el material\n\nSiempre responde en el mismo idioma que te pregunten. Sé pedagógico, claro y motivador en tus explicaciones.';

  @override
  String get questionLabel => 'Pregunta';

  @override
  String get optionsLabel => 'Opciones';

  @override
  String get explanationLabel => 'Explicación (opcional)';

  @override
  String get studentComment => 'Comentario del estudiante';

  @override
  String get aiAssistantTitle => 'Asistente de Estudio IA';

  @override
  String get questionContext => 'Contexto de la Pregunta';

  @override
  String get aiAssistant => 'Asistente IA';

  @override
  String get aiThinking => 'La IA está pensando...';

  @override
  String get askAIHint => 'Haz tu pregunta sobre este tema...';

  @override
  String get aiPlaceholderResponse =>
      'Esta es una respuesta de ejemplo. En una implementación real, esto se conectaría a un servicio de IA para proporcionar explicaciones útiles sobre la pregunta.';

  @override
  String get aiErrorResponse =>
      'Lo siento, hubo un error al procesar tu pregunta. Por favor, inténtalo de nuevo.';

  @override
  String get configureApiKeyMessage =>
      'Por favor, configura tu clave API de IA en Ajustes.';

  @override
  String get errorLabel => 'Error:';

  @override
  String get noResponseReceived => 'No se recibió respuesta';

  @override
  String get invalidApiKeyError =>
      'Clave API inválida. Por favor, verifica tu clave API de OpenAI en ajustes.';

  @override
  String get rateLimitError =>
      'Se ha superado el límite de uso. Por favor, inténtalo de nuevo más tarde.';

  @override
  String get modelNotFoundError =>
      'Modelo no encontrado. Por favor, verifica tu acceso a la API.';

  @override
  String get unknownError => 'Error desconocido';

  @override
  String get networkError =>
      'Error de red: No se puede conectar a OpenAI. Por favor, verifica tu conexión a internet.';

  @override
  String get openaiApiKeyNotConfigured => 'Clave API de OpenAI no configurada';

  @override
  String get geminiApiKeyNotConfigured => 'Clave API de Gemini no configurada';

  @override
  String get geminiApiKeyLabel => 'Clave API de Google Gemini';

  @override
  String get geminiApiKeyHint => 'Ingresa tu clave API de Gemini';

  @override
  String get geminiApiKeyDescription =>
      'Requerida para la funcionalidad de IA Gemini. Tu clave se guarda de forma segura.';

  @override
  String get getGeminiApiKeyTooltip => 'Obtener clave API de Google AI Studio';

  @override
  String get aiRequiresAtLeastOneApiKeyError =>
      'El Asistente de Estudio IA requiere al menos una clave API (OpenAI o Gemini). Por favor, ingresa una clave API o deshabilita el Asistente de IA.';

  @override
  String get minutesAbbreviation => 'min';

  @override
  String get aiButtonTooltip => 'Asistente de Estudio IA';

  @override
  String get aiButtonText => 'IA';

  @override
  String get aiAssistantSettingsTitle => 'Asistente de Estudio IA (Preview)';

  @override
  String get aiAssistantSettingsDescription =>
      'Habilitar o deshabilitar el asistente de IA para las preguntas';

  @override
  String get openaiApiKeyLabel => 'Clave API de OpenAI';

  @override
  String get openaiApiKeyHint => 'Ingresa tu clave API de OpenAI (sk-...)';

  @override
  String get openaiApiKeyDescription =>
      'Requerido para la funcionalidad de IA. Tu clave se almacena de forma segura.';

  @override
  String get aiAssistantRequiresApiKeyError =>
      'El Asistente de Estudio IA requiere una clave API de OpenAI. Por favor, ingresa tu clave API o desactiva el Asistente de IA.';

  @override
  String get getApiKeyTooltip => 'Obtener clave API de OpenAI';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get explanationHint =>
      'Ingresa una explicación para la(s) respuesta(s) correcta(s)';

  @override
  String get explanationTitle => 'Explicación';

  @override
  String get imageLabel => 'Imagen';

  @override
  String get changeImage => 'Cambiar imagen';

  @override
  String get removeImage => 'Quitar imagen';

  @override
  String get addImageTap => 'Toca para agregar imagen';

  @override
  String get imageFormats => 'Formatos: JPG, PNG, GIF';

  @override
  String get imageLoadError => 'Error al cargar la imagen';

  @override
  String imagePickError(String error) {
    return 'Error al cargar la imagen: $error';
  }

  @override
  String get tapToZoom => 'Toca para ampliar';

  @override
  String get trueLabel => 'Verdadero';

  @override
  String get falseLabel => 'Falso';

  @override
  String get addQuestion => 'Agregar Pregunta';

  @override
  String get editQuestion => 'Editar Pregunta';

  @override
  String get questionText => 'Texto de la Pregunta';

  @override
  String get questionType => 'Tipo de Pregunta';

  @override
  String get addOption => 'Agregar Opción';

  @override
  String get optionLabel => 'Opción';

  @override
  String get questionTextRequired => 'El texto de la pregunta es obligatorio';

  @override
  String get atLeastOneOptionRequired => 'Al menos una opción debe tener texto';

  @override
  String get atLeastOneCorrectAnswerRequired =>
      'Debe seleccionar al menos una respuesta correcta';

  @override
  String get onlyOneCorrectAnswerAllowed =>
      'Solo se permite una respuesta correcta para este tipo de pregunta';

  @override
  String get removeOption => 'Eliminar opción';

  @override
  String get selectCorrectAnswer => 'Seleccionar respuesta correcta';

  @override
  String get selectCorrectAnswers => 'Seleccionar respuestas correctas';

  @override
  String emptyOptionsError(String optionNumbers) {
    return 'Las opciones $optionNumbers están vacías. Por favor añade texto o elimínalas.';
  }

  @override
  String emptyOptionError(String optionNumber) {
    return 'La opción $optionNumber está vacía. Por favor añade texto o elimínala.';
  }

  @override
  String get optionEmptyError => 'Esta opción no puede estar vacía';

  @override
  String get hasImage => 'Imagen';

  @override
  String get hasExplanation => 'Explicación';

  @override
  String errorLoadingSettings(String error) {
    return 'Error al cargar configuraciones: $error';
  }

  @override
  String couldNotOpenUrl(String url) {
    return 'No se pudo abrir $url';
  }

  @override
  String get loadingAiServices => 'Cargando servicios de IA...';

  @override
  String usingAiService(String serviceName) {
    return 'Usando: $serviceName';
  }

  @override
  String get aiServiceLabel => 'Servicio de IA:';

  @override
  String get importQuestionsTitle => 'Importar Preguntas';

  @override
  String importQuestionsMessage(int count, String fileName) {
    return 'Se encontraron $count preguntas en \"$fileName\". ¿Dónde te gustaría importarlas?';
  }

  @override
  String get importQuestionsPositionQuestion =>
      '¿Dónde te gustaría añadir estas preguntas?';

  @override
  String get importAtBeginning => 'Al Inicio';

  @override
  String get importAtEnd => 'Al Final';

  @override
  String questionsImportedSuccess(int count) {
    return 'Se importaron exitosamente $count preguntas';
  }

  @override
  String get importQuestionsTooltip =>
      'Importar preguntas desde otro archivo de quiz';

  @override
  String get dragDropHintText =>
      'También puedes arrastrar y soltar archivos .quiz aquí para importar preguntas';

  @override
  String get randomizeAnswersTitle => 'Aleatorizar Opciones de Respuesta';

  @override
  String get randomizeAnswersDescription =>
      'Mezclar el orden de las opciones de respuesta durante la ejecución del quiz';

  @override
  String get showCorrectAnswerCountTitle =>
      'Mostrar Número de Respuestas Correctas';

  @override
  String get showCorrectAnswerCountDescription =>
      'Mostrar el número de respuestas correctas en preguntas de opción múltiple';

  @override
  String correctAnswersCount(int count) {
    return 'Selecciona $count respuestas correctas';
  }

  @override
  String get correctSelectedLabel => 'Correcta';

  @override
  String get correctMissedLabel => 'Correcta';

  @override
  String get incorrectSelectedLabel => 'Incorrecta';

  @override
  String get generateQuestionsWithAI => 'Generar preguntas con IA';

  @override
  String get aiGenerateDialogTitle => 'Generar Preguntas con IA';

  @override
  String get aiQuestionCountLabel => 'Número de Preguntas (Opcional)';

  @override
  String get aiQuestionCountHint => 'Déjalo vacío para que la IA decida';

  @override
  String get aiQuestionCountValidation => 'Debe ser un número entre 1 y 50';

  @override
  String get aiQuestionTypeLabel => 'Tipo de Preguntas';

  @override
  String get aiQuestionTypeRandom => 'Aleatorio (Mezcla)';

  @override
  String get aiLanguageLabel => 'Idioma de las Preguntas';

  @override
  String get aiContentLabel => 'Contenido para generar preguntas';

  @override
  String aiWordCount(int current, int max) {
    return '$current / $max palabras';
  }

  @override
  String get aiContentHint =>
      'Introduce el texto, tema o contenido del cual quieres generar preguntas...';

  @override
  String get aiContentHelperText =>
      'La IA creará preguntas basadas en este contenido';

  @override
  String aiWordLimitError(int max) {
    return 'Has superado el límite de $max palabras';
  }

  @override
  String get aiContentRequiredError =>
      'Debes proporcionar contenido para generar las preguntas';

  @override
  String aiContentLimitError(int max) {
    return 'El contenido supera el límite de $max palabras';
  }

  @override
  String get aiMinWordsError =>
      'Proporciona al menos 10 palabras para generar preguntas de calidad';

  @override
  String get aiInfoTitle => 'Información';

  @override
  String get aiInfoDescription =>
      '• La IA analizará el contenido y generará preguntas relevantes\n• Puedes incluir texto, definiciones, explicaciones o cualquier material educativo\n• Las preguntas incluirán opciones de respuesta y explicaciones\n• El proceso puede tardar unos segundos';

  @override
  String get aiGenerateButton => 'Generar Preguntas';

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
  String get aiServicesLoading => 'Cargando servicios de IA...';

  @override
  String get aiServicesNotConfigured => 'No hay servicios de IA configurados';

  @override
  String get aiGeneratedQuestions => 'IA Generadas';

  @override
  String get aiApiKeyRequired =>
      'Por favor, configura al menos una clave API de IA en Ajustes para usar la generación con IA.';

  @override
  String get aiGenerationFailed =>
      'No se pudieron generar preguntas. Intenta con un contenido diferente.';

  @override
  String aiGenerationError(String error) {
    return 'Error al generar preguntas: $error';
  }

  @override
  String get noQuestionsInFile =>
      'No se encontraron preguntas en el archivo importado';

  @override
  String get couldNotAccessFile => 'No se pudo acceder al archivo seleccionado';

  @override
  String get defaultOutputFileName => 'archivo-salida.quiz';

  @override
  String aiServiceLimitsWithChars(int words, int chars) {
    return 'Límite: $words palabras o $chars caracteres';
  }

  @override
  String aiServiceLimitsWordsOnly(int words) {
    return 'Límite: $words palabras';
  }

  @override
  String get aiAssistantDisabled => 'Asistente de IA Deshabilitado';

  @override
  String get enableAiAssistant =>
      'El asistente de IA está deshabilitado. Por favor, actívalo en la configuración para usar las funciones de IA.';

  @override
  String aiMinWordsRequired(int minWords) {
    return 'Mínimo $minWords palabras requeridas';
  }

  @override
  String aiWordsReadyToGenerate(int wordCount) {
    return '$wordCount palabras ✓ Listo para generar';
  }

  @override
  String aiWordsProgress(int currentWords, int minWords, int moreNeeded) {
    return '$currentWords/$minWords palabras ($moreNeeded más necesarias)';
  }

  @override
  String aiValidationMinWords(int minWords, int moreNeeded) {
    return 'Mínimo $minWords palabras requeridas ($moreNeeded más necesarias)';
  }
}
