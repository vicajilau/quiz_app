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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quizdy/core/debug_print.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/domain/models/quiz/quiz_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizdy/presentation/blocs/study_editor_cubit/study_editor_cubit.dart';
import 'package:quizdy/presentation/screens/quiz_file_execution_screen.dart';
import 'package:quizdy/presentation/screens/study_editor/component_editor_screen.dart';

import 'package:quizdy/core/service_locator.dart';

import 'package:quizdy/presentation/screens/home_screen.dart';
import 'package:quizdy/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:quizdy/presentation/screens/privacy_policy/privacy_policy_screen.dart';
import 'package:quizdy/data/services/configuration_service.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String privacyPolicy = '/privacy_policy';
  static const String fileLoadedScreen = '/quiz_loaded_screen';
  static const String quizFileExecutionScreen = '/quiz_file_execution_screen';
  static const String studyScreen = '/study_screen';
  static const String componentEditorScreen = '/component_editor_screen';
  static const String srsStats = '/srs_stats';
}

GoRouter buildAppRouter({required bool showOnboarding}) => GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: showOnboarding ? AppRoutes.onboarding : AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => OnboardingScreen(
        fromSettings: state.uri.queryParameters['from'] == 'settings',
      ),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) =>
          HomeScreen(initialDataUrl: state.uri.queryParameters['data']),
    ),
    GoRoute(
      path: AppRoutes.privacyPolicy,
      builder: (context, state) => PrivacyPolicyScreen(
        fromSettings: state.uri.queryParameters['from'] == 'settings',
        requireAcceptance: state.uri.queryParameters['required'] == 'true',
      ),
    ),
    GoRoute(
      path: AppRoutes.fileLoadedScreen,
      builder: (context, state) => const HomeScreen(initialTabIndex: 2),
    ),
    GoRoute(
      path: AppRoutes.quizFileExecutionScreen,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final quizFile = extra['quizFile'] as QuizFile;
        final quizConfig = extra['quizConfig'] as QuizConfig;
        return QuizFileExecutionScreen(
          quizFile: quizFile,
          quizConfig: quizConfig,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.componentEditorScreen,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final cubit = extra['cubit'] as StudyEditorCubit;
        final chunkIndex = extra['chunkIndex'] as int;
        final pageIndex = extra['pageIndex'] as int;
        return BlocProvider.value(
          value: cubit,
          child: ComponentEditorScreen(
            chunkIndex: chunkIndex,
            pageIndex: pageIndex,
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.studyScreen,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return HomeScreen(
          initialTabIndex: 1,
          studyExtra: extra,
          onExit: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        );
      },
    ),
    GoRoute(
      path: AppRoutes.srsStats,
      builder: (context, state) => const HomeScreen(initialTabIndex: 3),
    ),
  ],

  redirect: (context, state) {
    final uri = state.uri.toString();
    printInDebug('Detected redirection: $uri');

    // If the path is a `content://` scheme, ignore it and return to Home
    if (uri.startsWith('content://')) {
      return AppRoutes.home;
    }

    return null; // Keep regular flow
  },
);

/// Legacy accessor kept for compatibility during migration.
/// Prefer using [buildAppRouter] with the onboarding flag.
late final GoRouter appRouter;

/// Initializes the global [appRouter] by checking the onboarding status.
Future<void> initAppRouter() async {
  final completed = ServiceLocator.getIt<ConfigurationService>()
      .getOnboardingCompleted();
  appRouter = buildAppRouter(showOnboarding: !completed);
}
