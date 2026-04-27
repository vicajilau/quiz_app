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

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/core/quizdy_bloc_observer.dart';
import 'package:quizdy/routes/app_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:quizdy/core/deep_link_handler.dart';

import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/core/file_handler.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/domain/use_cases/check_file_changes_use_case.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_bloc.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_event.dart';
import 'package:quizdy/presentation/blocs/locale_cubit/locale_cubit.dart';
import 'package:quizdy/presentation/blocs/locale_cubit/locale_state.dart';
import 'package:quizdy/presentation/screens/dialogs/exit_confirmation_dialog.dart';
import 'package:quizdy/presentation/widgets/quizdy_text_scale_factor_clamper.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUrlStrategy(null);
  await ServiceLocator.setup();
  await initAppRouter();

  Bloc.observer = QuizdyBlocObserver();

  runApp(const QuizApplication());
}

class QuizApplication extends StatefulWidget {
  const QuizApplication({super.key});

  @override
  State<QuizApplication> createState() => _QuizApplicationState();
}

class _QuizApplicationState extends State<QuizApplication>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FileHandler.initialize((filePath) {
      if (mounted) {
        final fileBloc = ServiceLocator.getIt<FileBloc>();
        fileBloc.add(FileDropped(filePath));
      }
    });
    DeepLinkHandler.initialize();
  }

  @override
  void dispose() {
    DeepLinkHandler.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    final fileBloc = ServiceLocator.getIt<FileBloc>();
    final state = fileBloc.state;

    QuizFile? currentFile;
    if (state is FileLoaded) {
      currentFile = state.quizFile;
    } else if (state is FileSaved) {
      currentFile = state.quizFile;
    }

    if (currentFile != null) {
      final checkFileChangesUseCase =
          ServiceLocator.getIt<CheckFileChangesUseCase>();
      final hasChanges = checkFileChangesUseCase.execute(currentFile);

      if (hasChanges) {
        // Find the navigator context to show the dialog
        final context = rootNavigatorKey.currentContext;
        if (context != null) {
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => const ExitConfirmationDialog(),
          );

          if (shouldExit != true) {
            return AppExitResponse.cancel;
          }
        }
      }
    }

    return AppExitResponse.exit;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LocaleCubit()),
        BlocProvider<FileBloc>.value(value: ServiceLocator.getIt<FileBloc>()),
      ],
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, state) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.hideKeyboard(),
            child: MaterialApp.router(
              routerConfig: appRouter,
              builder: (_, child) => QuizdyTextScaleFactorClamper(
                child: child ?? const SizedBox(),
              ),
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              locale: state.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              localeResolutionCallback: (locale, supportedLocales) {
                if (locale == null) {
                  return supportedLocales.first;
                }

                // Check if the current device locale is supported
                for (final supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale.languageCode &&
                      supportedLocale.countryCode == locale.countryCode) {
                    return supportedLocale;
                  }
                }

                // If not supported, check if the language code is supported
                for (final supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale.languageCode) {
                    return supportedLocale;
                  }
                }

                // If the locale is not supported, check if we have a fallback for this language
                // ignoring country code
                try {
                  return supportedLocales.firstWhere(
                    (l) => l.languageCode == locale.languageCode,
                    orElse: () => const Locale('en'),
                  );
                } catch (e) {
                  return const Locale('en');
                }
              },
            ),
          );
        },
      ),
    );
  }
}
