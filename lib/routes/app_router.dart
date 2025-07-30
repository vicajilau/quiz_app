import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/debug_print.dart';
import 'package:quiz_app/presentation/screens/file_loaded_screen.dart';
import 'package:quiz_app/presentation/screens/maso_file_execution_screen.dart';

import '../core/service_locator.dart';
import '../domain/models/maso/maso_file.dart';
import '../domain/use_cases/check_file_changes_use_case.dart';
import '../presentation/blocs/file_bloc/file_bloc.dart';
import '../presentation/screens/home_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String fileLoadedScreen = '/file_loaded_screen';
  static const String masoFileExecutionScreen = '/maso_file_execution_screen';
}

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.fileLoadedScreen,
      builder: (context, state) => FileLoadedScreen(
        fileBloc: ServiceLocator.instance.getIt<FileBloc>(),
        checkFileChangesUseCase: ServiceLocator.instance
            .getIt<CheckFileChangesUseCase>(),
        masoFile: ServiceLocator.instance.getIt<MasoFile>(),
      ),
    ),
    GoRoute(
      path: AppRoutes.masoFileExecutionScreen,
      builder: (context, state) => const MasoFileExecutionScreen(),
    ),
  ],
  redirect: (context, state) {
    final uri = state.uri.toString();
    printInDebug("Detected redirection: $uri");

    // If the path is a `content://` scheme, ignore it and return to Home
    if (uri.startsWith("content://")) {
      return AppRoutes.home;
    }

    return null; // Keep regular flow
  },
);
