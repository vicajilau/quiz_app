import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_detail/platform_detail.dart';
import 'package:quiz_app/core/debug_print.dart';
import 'package:quiz_app/domain/models/quiz/quiz_file.dart';
import 'package:quiz_app/presentation/screens/file_loaded_screen.dart';
import 'package:quiz_app/presentation/screens/quiz_file_execution_screen.dart';
import 'package:quiz_app/presentation/screens/raffle/raffle_screen.dart';
import 'package:quiz_app/presentation/screens/raffle/winners_screen.dart';
import 'package:quiz_app/presentation/blocs/raffle_bloc/raffle_bloc.dart';
import 'package:quiz_app/presentation/screens/dialogs/exit_confirmation_dialog.dart';
import 'package:quiz_app/presentation/screens/dialogs/abandon_quiz_dialog.dart';

import '../core/service_locator.dart';
import '../domain/use_cases/check_file_changes_use_case.dart';
import '../presentation/blocs/file_bloc/file_bloc.dart';
import '../presentation/screens/home_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String fileLoadedScreen = '/file_loaded_screen';
  static const String quizFileExecutionScreen = '/quiz_file_execution_screen';
  static const String raffle = '/raffle';
  static const String raffleWinners = '/raffle/winners';
}

// Flag to prevent multiple exit dialogs
bool _isExitDialogShowing = false;
// Flag to track if exit was already confirmed
bool _exitConfirmed = false;

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
        quizFile: ServiceLocator.instance.getIt<QuizFile>(),
      ),
      onExit: (context, state) async {
        // Note: Workaround until PopScope issue is resolved: https://github.com/flutter/flutter/issues/138737
        // If exit was already confirmed, allow it
        if (_exitConfirmed) {
          _exitConfirmed = false;
          return true;
        }

        // Prevent multiple dialogs
        if (_isExitDialogShowing) {
          return false;
        }

        if (!ServiceLocator.instance.getIt.isRegistered<QuizFile>()) {
          return true;
        }

        final checkFileChangesUseCase = ServiceLocator.instance
            .getIt<CheckFileChangesUseCase>();
        final quizFile = ServiceLocator.instance.getIt<QuizFile>();

        if (!checkFileChangesUseCase.execute(quizFile)) {
          return true;
        }

        _isExitDialogShowing = true;
        final shouldExit = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => const ExitConfirmationDialog(),
        );
        _isExitDialogShowing = false;

        if (shouldExit == true) {
          _exitConfirmed = true;
          appRouter.go(AppRoutes.home);
          return true;
        }

        return false;
      },
    ),
    GoRoute(
      path: AppRoutes.quizFileExecutionScreen,
      builder: (context, state) => QuizFileExecutionScreen(
        quizFile: ServiceLocator.instance.getIt<QuizFile>(),
      ),
      onExit: (context, state) async {
        // Note: Workaround only needed for web until PopScope issue is resolved:
        // https://github.com/flutter/flutter/issues/138737

        if (!PlatformDetail.isWeb) {
          return true;
        }

        // If exit was already confirmed, allow it
        if (_exitConfirmed) {
          _exitConfirmed = false;
          return true;
        }

        // Prevent multiple dialogs
        if (_isExitDialogShowing) {
          return false;
        }

        _isExitDialogShowing = true;
        final shouldExit = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => const AbandonQuizDialog(),
        );
        _isExitDialogShowing = false;

        if (shouldExit == true) {
          _exitConfirmed = true;
          appRouter.go(AppRoutes.fileLoadedScreen);
          return true;
        }

        return false;
      },
    ),
    ShellRoute(
      builder: (context, state, child) =>
          BlocProvider(create: (context) => RaffleBloc(), child: child),
      routes: [
        GoRoute(
          path: AppRoutes.raffle,
          builder: (context, state) => const RaffleScreen(),
        ),
        GoRoute(
          path: AppRoutes.raffleWinners,
          builder: (context, state) => const WinnersScreen(),
        ),
      ],
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
