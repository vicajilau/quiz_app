import 'package:get_it/get_it.dart';
import 'package:quiz_app/domain/use_cases/check_file_changes_use_case.dart';

import 'package:quiz_app/data/repositories/quiz_file_repository.dart';
import 'package:quiz_app/data/services/file_service/mobile_desktop_file_service.dart'
    if (dart.library.js_interop) '../../data/services/file_service/web_file_service.dart';
import 'package:quiz_app/data/services/quiz_record/quiz_record_service.dart';
import 'package:quiz_app/data/services/quiz_record/hive_quiz_record_service.dart';
import 'package:quiz_app/domain/models/quiz/quiz_file.dart';
import 'package:quiz_app/domain/models/quiz/quiz_config.dart';

import 'package:quiz_app/presentation/blocs/file_bloc/file_bloc.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_bloc.dart';

// Singleton class for managing service registrations
class ServiceLocator {
  // Create a single instance of GetIt
  final GetIt getIt = GetIt.instance;

  // Private constructor to prevent external instantiation
  ServiceLocator._();

  // The single instance of ServiceLocator
  static final ServiceLocator _instance = ServiceLocator._();

  // Getter for the single instance
  static ServiceLocator get instance => _instance;

  // Function to set up the service locator and register dependencies
  Future<void> setup() async {
    // Register QuizRecordService (Hive-based)
    final quizRecordService = HiveQuizRecordService();
    await quizRecordService.initialize();
    getIt.registerLazySingleton<QuizRecordService>(() => quizRecordService);

    getIt.registerLazySingleton<QuizFileService>(() => QuizFileService());
    getIt.registerLazySingleton<CheckFileChangesUseCase>(
      () =>
          CheckFileChangesUseCase(fileRepository: getIt<QuizFileRepository>()),
    );
    getIt.registerLazySingleton<QuizFileRepository>(
      () => QuizFileRepository(fileService: getIt<QuizFileService>()),
    );
    getIt.registerFactory<FileBloc>(
      () => FileBloc(fileRepository: getIt<QuizFileRepository>()),
    );
    getIt.registerFactory<QuizExecutionBloc>(
      () => QuizExecutionBloc(),
    );
  }

  // Function to register or update QuizFile in GetIt
  void registerQuizFile(QuizFile quizFile) {
    if (getIt.isRegistered<QuizFile>()) {
      getIt.unregister<QuizFile>();
    }
    getIt.registerLazySingleton<QuizFile>(() => quizFile);
  }

  // Function to register quiz configuration
  void registerQuizConfig(QuizConfig config) {
    if (getIt.isRegistered<QuizConfig>()) {
      getIt.unregister<QuizConfig>();
    }
    getIt.registerLazySingleton<QuizConfig>(() => config);
  }

  // Function to get the registered quiz configuration
  QuizConfig? getQuizConfig() {
    if (getIt.isRegistered<QuizConfig>()) {
      return getIt<QuizConfig>();
    }
    return null;
  }

}
