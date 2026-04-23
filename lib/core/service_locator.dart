// Copyright (C) 2026 Víctor Carreras
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:quizdy/data/interceptors/ai_logging_interceptor.dart';
import 'package:quizdy/data/interceptors/connectivity_interceptor.dart';
import 'package:quizdy/data/repositories/ai/ai_repository_factory.dart';
import 'package:quizdy/data/services/ai/ai_document_chunking_service.dart';
import 'package:quizdy/data/services/ai/ai_jit_processing_service.dart';
import 'package:quizdy/data/services/ai/ai_question_generation_service.dart';
import 'package:quizdy/data/services/app_remote_config_service.dart';
import 'package:quizdy/data/services/configuration_service.dart';
import 'package:quizdy/domain/use_cases/check_file_changes_use_case.dart';

import 'package:quizdy/data/repositories/quiz_file_repository.dart';
import 'package:quizdy/data/services/file_service/mobile_desktop_file_service.dart'
    if (dart.library.js_interop) '../../data/services/file_service/web_file_service.dart';
import 'package:quizdy/data/services/pdf_export_service_io.dart'
    if (dart.library.js_interop) 'package:quizdy/data/services/pdf_export_service.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/domain/models/quiz/quiz_config.dart';

import 'package:quizdy/presentation/blocs/file_bloc/file_bloc.dart';
import 'package:quizdy/presentation/blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import 'package:quizdy/presentation/utils/clipboard_image_helper.dart';
import 'package:quizdy/presentation/utils/dialog_drop_guard.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Singleton class for managing service registrations
class ServiceLocator {
  // Create a single instance of GetIt
  static final GetIt getIt = GetIt.instance;

  // Function to set up the service locator and register dependencies
  static Future<void> setup() async {
    // Dio
    final dioClient = Dio()
      ..interceptors.addAll([
        ConnectivityInterceptor(),
        AiLoggingInterceptor(),
      ]);
    getIt.registerSingleton<Dio>(dioClient);

    // SharedPreferences
    final sharedPreferences = getIt.registerSingleton<SharedPreferences>(
      await SharedPreferences.getInstance(),
    );

    final configurationService = getIt.registerSingleton<ConfigurationService>(
      ConfigurationService(sharedPreferences: sharedPreferences),
    );

    getIt.registerSingleton<AppRemoteConfigService>(
      AppRemoteConfigService(
        sharedPreferences: sharedPreferences,
        dio: dioClient,
      ),
    );

    getIt.registerSingleton<AiRepositoryFactory>(
      AiRepositoryFactory(
        dioClient: dioClient,
        configurationService: configurationService,
      ),
    );

    getIt.registerSingleton<AiQuestionGenerationService>(
      AiQuestionGenerationService(configurationService: configurationService),
    );

    getIt.registerSingleton<AiJitProcessingService>(AiJitProcessingService());

    getIt.registerSingleton<AiDocumentChunkingService>(
      AiDocumentChunkingService(),
    );

    getIt.registerSingleton<ClipboardImageHelper>(ClipboardImageHelper());

    getIt.registerSingleton<DialogDropGuard>(DialogDropGuard());
    getIt.registerLazySingleton<StudyPdfExportService>(
      () => StudyPdfExportService(),
    );

    getIt.registerLazySingleton<QuizFileService>(() => QuizFileService());
    getIt.registerLazySingleton<CheckFileChangesUseCase>(
      () =>
          CheckFileChangesUseCase(fileRepository: getIt<QuizFileRepository>()),
    );
    getIt.registerLazySingleton<QuizFileRepository>(
      () => QuizFileRepository(fileService: getIt<QuizFileService>()),
    );
    getIt.registerLazySingleton<FileBloc>(
      () => FileBloc(fileRepository: getIt<QuizFileRepository>()),
    );
    getIt.registerFactory<QuizExecutionBloc>(
      () => QuizExecutionBloc(
        aiRepositoryFactory: getIt.get<AiRepositoryFactory>(),
      ),
    );
  }

  // Function to register or update QuizFile in GetIt
  static void registerQuizFile(QuizFile quizFile) {
    if (getIt.isRegistered<QuizFile>()) {
      getIt.unregister<QuizFile>();
    }
    getIt.registerLazySingleton<QuizFile>(() => quizFile);
  }

  // Function to register quiz configuration
  static void registerQuizConfig(QuizConfig config) {
    if (getIt.isRegistered<QuizConfig>()) {
      getIt.unregister<QuizConfig>();
    }
    getIt.registerSingleton<QuizConfig>(config);
  }

  // Function to get the registered quiz configuration
  static QuizConfig? getQuizConfig() {
    if (getIt.isRegistered<QuizConfig>()) {
      return getIt<QuizConfig>();
    }
    return null;
  }
}
