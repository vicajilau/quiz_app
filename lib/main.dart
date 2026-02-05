import 'package:flutter/material.dart';
import 'package:quiz_app/routes/app_router.dart';

import 'package:quiz_app/core/constants/theme.dart';
import 'package:quiz_app/core/file_handler.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/core/service_locator.dart';
import 'package:quiz_app/presentation/blocs/file_bloc/file_bloc.dart';
import 'package:quiz_app/presentation/blocs/file_bloc/file_event.dart';

void main() {
  ServiceLocator.instance.setup();
  runApp(const QuizApplication());
}

class QuizApplication extends StatefulWidget {
  const QuizApplication({super.key});

  @override
  State<QuizApplication> createState() => _QuizApplicationState();
}

class _QuizApplicationState extends State<QuizApplication> {
  @override
  void initState() {
    super.initState();

    FileHandler.initialize((filePath) {
      if (mounted) {
        // Load the file when opened from an intent
        final fileBloc = ServiceLocator.instance.getIt<FileBloc>();
        fileBloc.add(FileDropped(filePath));
        appRouter.go(AppRoutes.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
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
      showSemanticsDebugger: false,
      debugShowCheckedModeBanner: false,
    );
  }
}
