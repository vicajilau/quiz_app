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
  String get dropFileHere => 'Arrastra un archivo .quiz aquí';

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
  String get retry => 'Reintentar';

  @override
  String get goBack => 'Volver';

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
  String questionsCount(int count) {
    return '$count preguntas';
  }

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
}
