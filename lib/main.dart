import 'package:flutter/material.dart';
import 'package:quiz_app/routes/app_router.dart';

import 'core/constants/theme.dart';
import 'core/file_handler.dart';
import 'core/l10n/app_localizations.dart';
import 'core/service_locator.dart';
import 'presentation/blocs/file_bloc/file_bloc.dart';
import 'presentation/blocs/file_bloc/file_event.dart';

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
      debugPrint('DEBUG: El path del archivo es: $filePath');
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
        if (locale != null) {
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        return const Locale('en');
      },
      showSemanticsDebugger: false,
      debugShowCheckedModeBanner: false,
    );
  }
}
