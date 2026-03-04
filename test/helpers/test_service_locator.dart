import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/data/services/ai/ai_service_selector.dart';
import 'package:quizdy/data/services/ai/gemini_service.dart';
import 'package:quizdy/data/services/ai/openai_service.dart';
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

/// Creates a real [AIServiceSelector] with real (but unconfigured) services.
///
/// Useful for tests that need to instantiate [QuizExecutionBloc].
Future<AIServiceSelector> createTestAIServiceSelector(
  ConfigurationService configurationService,
) async {
  final dio = Dio();
  final gemini = GeminiService(
    dioClient: dio,
    configurationService: configurationService,
  );
  final openAI = OpenAIService(
    dioClient: dio,
    configurationService: configurationService,
  );
  return AIServiceSelector(geminiService: gemini, openAIService: openAI);
}

/// Unregisters services registered by [setUpTestServiceLocator].
void tearDownTestServiceLocator() {
  final getIt = ServiceLocator.getIt;
  if (getIt.isRegistered<ConfigurationService>()) {
    getIt.unregister<ConfigurationService>();
  }
}
