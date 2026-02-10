import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_event.dart';
import 'package:quiz_app/core/theme/app_theme.dart';

class QuizTryAgainButton extends StatelessWidget {
  const QuizTryAgainButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        final bloc = BlocProvider.of<QuizExecutionBloc>(context);
        bloc.add(QuizRestarted());
      },
      icon: const Icon(Icons.refresh, size: 20),
      label: Text(
        AppLocalizations.of(context)!.tryAgain,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 25),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class QuizRetryFailedButton extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onPressed;

  const QuizRetryFailedButton({
    super.key,
    required this.isDarkMode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.quiz_outlined, size: 20),
      label: Text(
        AppLocalizations.of(context)!.retryFailedQuestions,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: isDarkMode ? AppTheme.zinc800 : AppTheme.zinc100,
        foregroundColor: isDarkMode ? AppTheme.zinc400 : AppTheme.zinc500,
        side: BorderSide(
          color: isDarkMode ? AppTheme.zinc700 : AppTheme.zinc200,
          width: 2,
        ),
        padding: const EdgeInsets.symmetric(vertical: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class QuizHomeButton extends StatelessWidget {
  final bool isDarkMode;

  const QuizHomeButton({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => context.pop(),
      icon: const Icon(Icons.home_outlined, size: 20),
      label: Text(
        AppLocalizations.of(context)!.home,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: isDarkMode ? AppTheme.zinc800 : AppTheme.zinc100,
        foregroundColor: isDarkMode ? AppTheme.zinc400 : AppTheme.zinc500,
        side: BorderSide(
          color: isDarkMode ? AppTheme.zinc700 : AppTheme.zinc200,
          width: 2,
        ),
        padding: const EdgeInsets.symmetric(vertical: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
