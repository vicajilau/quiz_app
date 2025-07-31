// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get titleAppBar => 'Quiz - Simulador de exámenes';

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
  String fileError(String message) {
    return 'Error: $message';
  }

  @override
  String get dropFileHere => 'Arrastra un archivo .quiz aquí';

  @override
  String get errorInvalidFile =>
      'Error: archivo no válido. Debe ser un archivo .quiz.';

  @override
  String errorLoadingFile(String error) {
    return 'Error al cargar el archivo Quiz: $error';
  }

  @override
  String errorExportingFile(String error) {
    return 'Error al exportar : $error';
  }

  @override
  String errorSavingFile(String error) {
    return 'Error al guardar el archivo: $error';
  }

  @override
  String arrivalTimeLabel(String arrivalTime) {
    return 'Tiempo de Llegada: $arrivalTime';
  }

  @override
  String serviceTimeLabel(String serviceTime) {
    return 'Tiempo de Servicio: $serviceTime';
  }

  @override
  String get editProcessTitle => 'Editar Proceso';

  @override
  String get createRegularProcessTitle => 'Crear Proceso Regular';

  @override
  String get createBurstProcessTitle => 'Crear Proceso con Ráfagas';

  @override
  String get processNameLabel => 'Nombre del Proceso';

  @override
  String get arrivalTimeDialogLabel => 'Tiempo de Llegada';

  @override
  String get serviceTimeDialogLabel => 'Tiempo de Servicio';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get saveButton => 'Guardar';

  @override
  String get confirmDeleteTitle => 'Confirmar eliminación';

  @override
  String confirmDeleteMessage(Object processName) {
    return '¿Estás seguro de que deseas eliminar el proceso `$processName`?';
  }

  @override
  String get deleteButton => 'Eliminar';

  @override
  String get enabledLabel => 'Habilitado';

  @override
  String get disabledLabel => 'Deshabilitado';

  @override
  String get confirmExitTitle => 'Confirmar salida';

  @override
  String get confirmExitMessage => '¿Seguro que quieres salir sin guardar?';

  @override
  String get exitButton => 'Salir';

  @override
  String get saveDialogTitle => 'Por favor, seleccione un archivo de salida:';

  @override
  String get fillAllFieldsError => 'Por favor, completa todos los campos.';

  @override
  String get createQuizFileTitle => 'Crear Archivo Quiz';

  @override
  String get fileNameLabel => 'Nombre del Archivo';

  @override
  String get fileDescriptionLabel => 'Descripción del Archivo';

  @override
  String get createButton => 'Crear';

  @override
  String get emptyNameError => 'El nombre no puede estar vacío.';

  @override
  String get duplicateNameError => 'Ya existe un proceso con este nombre.';

  @override
  String get invalidArrivalTimeError =>
      'El tiempo de llegada debe ser un número entero positivo.';

  @override
  String get invalidServiceTimeError =>
      'El tiempo de servicio debe ser un número entero positivo.';

  @override
  String get invalidTimeDifferenceError =>
      'El tiempo de servicio debe ser mayor que el tiempo de llegada.';

  @override
  String get timeDifferenceTooSmallError =>
      'El tiempo de servicio debe ser al menos 1 unidad mayor que el tiempo de llegada.';

  @override
  String get requestFileNameTitle => 'Introduce el nombre del archivo Quiz';

  @override
  String get fileNameHint => 'Nombre del archivo';

  @override
  String get acceptButton => 'Aceptar';

  @override
  String get errorTitle => 'Error';

  @override
  String get emptyFileNameMessage =>
      'El nombre del fichero no puede estar vacío.';

  @override
  String get fileNameRequiredError => 'El nombre del archivo es obligatorio.';

  @override
  String get fileDescriptionRequiredError =>
      'La descripción del archivo es obligatoria.';

  @override
  String get executionSetupTitle => 'Configuración de Ejecución';

  @override
  String get selectAlgorithmLabel => 'Seleccionar Algoritmo';

  @override
  String algorithmLabel(String algorithm) {
    String _temp0 = intl.Intl.selectLogic(algorithm, {
      'firstComeFirstServed': 'Primero en Llegar, Primero en Servir',
      'shortestJobFirst': 'El Trabajo Más Corto Primero',
      'shortestRemainingTimeFirst': 'El Tiempo Restante Más Corto Primero',
      'roundRobin': 'Round Robin',
      'priorityBased': 'Basado en Prioridad',
      'multiplePriorityQueues': 'Colas de Prioridad Múltiples',
      'multiplePriorityQueuesWithFeedback':
          'Colas de Prioridad Múltiples con Retroalimentación',
      'timeLimit': 'Límite de Tiempo',
      'other': 'Desconocido',
    });
    return '$_temp0';
  }

  @override
  String get saveTooltip => 'Guardar el archivo';

  @override
  String get saveDisabledTooltip => 'No hay cambios para guardar';

  @override
  String get executeTooltip => 'Ejecutar el exámen';

  @override
  String get addTooltip => 'Agregar una nueva pregunta';

  @override
  String get backSemanticLabel => 'Botón de volver';

  @override
  String get createFileTooltip => 'Crear un nuevo archivo Quiz';

  @override
  String get loadFileTooltip => 'Cargar un archivo Quiz existente';

  @override
  String get executionScreenTitle => 'Resumen de Ejecución';

  @override
  String get executionTimelineTitle => 'Línea de Tiempo de Ejecución';

  @override
  String failedToCaptureImage(Object error) {
    return 'No se pudo capturar la imagen: $error';
  }

  @override
  String get imageCopiedToClipboard => 'Imagen copiada al portapapeles';

  @override
  String get exportTimelineImage => 'Exportar como Imagen';

  @override
  String get exportTimelinePdf => 'Exportar como PDF';

  @override
  String get clipboardTooltip => 'Copiar al portapapeles';

  @override
  String get exportTooltip => 'Exportar línea de tiempo de ejecución';

  @override
  String timelineProcessDescription(
    Object arrivalTime,
    Object processName,
    Object serviceTime,
  ) {
    return '$processName (Llegada: $arrivalTime, Servicio: $serviceTime)';
  }

  @override
  String executionTimeDescription(Object executionTime) {
    return 'Tiempo de Ejecución: $executionTime';
  }

  @override
  String get executionTimeUnavailable => 'N/D';

  @override
  String get imageExported => 'Imagen exportada';

  @override
  String get pdfExported => 'PDF exportado';

  @override
  String get metadataBadContent =>
      'Los metadatos del archivo son inválidos o están corruptos.';

  @override
  String get processesBadContent =>
      'La lista de procesos contiene datos inválidos.';

  @override
  String get unsupportedVersion =>
      'La versión del archivo no es compatible con la aplicación actual.';

  @override
  String get invalidExtension =>
      'El archivo no tiene una extensión .quiz válida.';

  @override
  String get settingsDialogTitle => 'Configuración';

  @override
  String get settingsDialogWarningTitle => 'Advertencia';

  @override
  String get settingsDialogWarningContent =>
      'Cambiar el modo borrará todos los procesos del archivo quiz. ¿Deseas continuar?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get close => 'Cerrar';

  @override
  String get settingsDialogDescription => 'El tipo de procesos configurado';

  @override
  String get processModeRegular => 'Normales';

  @override
  String get processModeBurst => 'Con ráfagas';

  @override
  String get processIdLabel => 'ID del Proceso';

  @override
  String get burstDurationLabel => 'Duración del Burst';

  @override
  String get addBurstButton => 'Agregar Burst';

  @override
  String get addThreadButton => 'Agregar Hilo';

  @override
  String get deleteThreadTitle => 'Eliminar Hilo';

  @override
  String deleteThreadConfirmation(Object threadId) {
    return '¿Estás seguro de que deseas eliminar el hilo \"$threadId\"?';
  }

  @override
  String get confirmButton => 'Confirmar';

  @override
  String get arrivalTimeLabelDecorator => 'Tiempo de Llegada';

  @override
  String get deleteBurstTitle => 'Borrar Ráfaga';

  @override
  String deleteBurstConfirmation(Object duration, Object type) {
    return '¿Está seguro de que desea eliminar la ráfaga $type con una duración de $duration ut?';
  }

  @override
  String invalidBurstSequenceError(Object thread) {
    return 'La secuencia de ráfagas del hilo ($thread) no puede contener dos ráfagas de E/S consecutivas.';
  }

  @override
  String get selectBurstType => 'Selecciona el tipo de ráfaga';

  @override
  String get burstCpuType => 'CPU';

  @override
  String get burstIoType => 'E/S';

  @override
  String get burstTypeLabel => 'Tipo de ráfaga';

  @override
  String burstNameLabel(Object name) {
    return 'Ráfaga $name';
  }

  @override
  String burstTypeListLabel(Object type) {
    return 'Tipo de ráfaga: $type';
  }

  @override
  String threadIdLabel(Object id) {
    return 'Hilo: $id';
  }

  @override
  String get contextSwitchTime => 'Tiempo de Cambio de Contexto';

  @override
  String get ioChannels => 'Canales de E/S';

  @override
  String get cpuCount => 'Cantidad de CPUs';

  @override
  String get quantumLabel => 'Quantum';

  @override
  String get invalidQuantumError =>
      'Por favor, ingresa un valor de quantum válido (mayor que 0).';

  @override
  String get queueQuantaLabel => 'Lista de Quantums';

  @override
  String get invalidQueueQuantaError =>
      'Por favor, ingresa valores de quantum válidos (mayores que 0) separados con comas.';

  @override
  String get timeLimitLabel => 'Límite de tiempo';

  @override
  String get invalidTimeLimitError =>
      'Por favor, ingresa una duración máxima por turno válida (mayor que 0).';

  @override
  String emptyNameProcessBadContent(Object index) {
    return 'El proceso con el índice ($index necesita un nombre (id))';
  }

  @override
  String get duplicatedNameProcessBadContent =>
      'Hay dos o más procesos con el mismo nombre';

  @override
  String invalidArrivalTimeBadContent(Object process) {
    return 'El preceso ($process) tiene la propiedad arrival_time a null o <= 0';
  }

  @override
  String invalidServiceTimeBadContent(Object process) {
    return 'El preceso ($process) tiene la propiedad service_time a null o <= 0';
  }

  @override
  String emptyThreadError(Object process) {
    return 'El proceso ($process) no tiene hilos asociados';
  }

  @override
  String emptyBurstError(Object process, Object thread) {
    return 'El hilo ($thread) del proceso ($process) no tiene ráfagas asociadas';
  }

  @override
  String startAndEndCpuSequenceError(Object thread) {
    return 'La secuencia de ráfagas del hilo ($thread) debe comenzar y terminar con CPU';
  }

  @override
  String startAndEndCpuSequenceBadContent(Object process, Object thread) {
    return 'La secuencia de ráfagas del hilo ($thread) en el proceso ($process) debe comenzar y terminar con CPU.';
  }

  @override
  String invalidBurstSequenceBadContent(Object process, Object thread) {
    return 'La secuencia de ráfagas del hilo ($thread) en el proceso ($process) no puede contener dos ráfagas de E/S consecutivas.';
  }

  @override
  String invalidBurstDuration(Object burst, Object process, Object thread) {
    return 'La ráfaga ($burst) del hilo ($thread) en el proceso ($process) es nulo o <= 0';
  }

  @override
  String get unknownError => 'Error desconocido';

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
    return 'Puntuación: $score%';
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
}
