import 'package:get_it/get_it.dart';
import 'package:quiz_app/domain/use_cases/check_file_changes_use_case.dart';

import '../data/repositories/quiz_file_repository.dart';
import '../data/services/file_service/mobile_desktop_file_service.dart'
    if (dart.library.html) '../../data/services/file_service/web_file_service.dart';
import '../domain/models/quiz/quiz_file.dart';

import '../presentation/blocs/file_bloc/file_bloc.dart';

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
  void setup() {
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
  }

  // Function to register or update QuizFile in GetIt
  void registerQuizFile(QuizFile quizFile) {
    if (getIt.isRegistered<QuizFile>()) {
      getIt.unregister<QuizFile>();
    }
    getIt.registerLazySingleton<QuizFile>(() => quizFile);
  }

  // Function to register quiz configuration (number of questions)
  void registerQuizConfig({required int questionCount}) {
    if (getIt.isRegistered<int>(instanceName: 'questionCount')) {
      getIt.unregister<int>(instanceName: 'questionCount');
    }
    getIt.registerLazySingleton<int>(
      () => questionCount,
      instanceName: 'questionCount',
    );
  }

  // Function to get the registered question count
  int? getQuestionCount() {
    if (getIt.isRegistered<int>(instanceName: 'questionCount')) {
      return getIt<int>(instanceName: 'questionCount');
    }
    return null;
  }
}
