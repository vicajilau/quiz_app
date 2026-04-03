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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/data/repositories/ai/ai_repository_factory.dart';
import 'package:quizdy/data/services/configuration_service.dart';

/// Registers the minimum services needed for tests that access GetIt.
///
/// Call in setUp() and pair with [tearDownTestServiceLocator] in tearDown().
Future<ConfigurationService> setUpTestServiceLocator() async {
  final getIt = ServiceLocator.getIt;

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final configurationService = ConfigurationService(sharedPreferences: prefs);

  if (!getIt.isRegistered<ConfigurationService>()) {
    getIt.registerSingleton<ConfigurationService>(configurationService);
  }

  return configurationService;
}

/// Creates a real [AiRepositoryFactory] with real (but unconfigured) services.
///
/// Useful for tests that need to instantiate [QuizExecutionBloc].
AiRepositoryFactory createTestAiRepositoryFactory(
  ConfigurationService configurationService,
) {
  return AiRepositoryFactory(
    dioClient: Dio(),
    configurationService: configurationService,
  );
}

/// Unregisters services registered by [setUpTestServiceLocator].
void tearDownTestServiceLocator() {
  final getIt = ServiceLocator.getIt;
  if (getIt.isRegistered<ConfigurationService>()) {
    getIt.unregister<ConfigurationService>();
  }
}
