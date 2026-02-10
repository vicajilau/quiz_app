import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:async';
import 'package:quiz_app/core/service_locator.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/data/services/configuration_service.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/quiz_file.dart';
import 'package:quiz_app/data/services/quiz_service.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_event.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/quiz_in_progress_view.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/quiz_completed_view.dart';
import 'package:quiz_app/core/theme/app_theme.dart';

class QuizFileExecutionScreen extends StatefulWidget {
  final QuizFile quizFile;

  const QuizFileExecutionScreen({super.key, required this.quizFile});

  @override
  State<QuizFileExecutionScreen> createState() =>
      _QuizFileExecutionScreenState();
}

class _QuizFileExecutionScreenState extends State<QuizFileExecutionScreen> {
  bool _randomizeAnswers = false;
  @override
  void initState() {
    super.initState();
    _loadQuizSettings();
  }

  Future<void> _loadQuizSettings() async {
    final randomizeAnswers = await ConfigurationService.instance
        .getRandomizeAnswers();

    if (mounted) {
      setState(() {
        _randomizeAnswers = randomizeAnswers;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder(
      future: _prepareQuizQuestions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: isDark ? AppTheme.zinc900 : AppTheme.zinc50,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: isDark ? AppTheme.zinc900 : AppTheme.zinc50,
            body: Center(
              child: Text(
                AppLocalizations.of(
                  context,
                )!.errorLoadingFile(snapshot.error.toString()),
              ),
            ),
          );
        }

        final questionsToUse = snapshot.data as List<Question>;

        return BlocProvider<QuizExecutionBloc>(
          create: (_) {
            final quizConfig = ServiceLocator.instance.getQuizConfig();
            final isStudyMode = quizConfig?.isStudyMode ?? false;

            return ServiceLocator.instance.getIt<QuizExecutionBloc>()..add(
              QuizExecutionStarted(questionsToUse, isStudyMode: isStudyMode),
            );
          },
          child: Builder(
            builder: (context) => Scaffold(
              backgroundColor: isDark ? AppTheme.zinc900 : AppTheme.zinc50,
              body: SafeArea(
                child: BlocConsumer<QuizExecutionBloc, QuizExecutionState>(
                  listener: (context, state) {
                    if (state is QuizExecutionCompleted) {
                      // Handled by view
                    }
                  },
                  builder: (context, state) {
                    if (state is QuizExecutionInitial) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is QuizExecutionInProgress) {
                      return QuizInProgressView(state: state);
                    } else if (state is QuizExecutionCompleted) {
                      return QuizCompletedView(state: state);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<List<Question>> _prepareQuizQuestions() async {
    // Get the configured question count from service locator
    final quizConfig = ServiceLocator.instance.getQuizConfig();
    final questionCount =
        quizConfig?.questionCount ?? widget.quizFile.questions.length;

    // Get the configured question order
    final questionOrder = await ConfigurationService.instance
        .getQuestionOrder();

    // Filter out disabled questions first
    final enabledQuestions = widget.quizFile.questions
        .where((question) => question.isEnabled)
        .toList();

    // Select the questions to use for the quiz with the configured order
    List<Question> selectedQuestions = QuizService.selectQuestions(
      enabledQuestions,
      questionCount,
      order: questionOrder,
    );

    // Apply answer randomization if enabled
    if (_randomizeAnswers) {
      selectedQuestions = QuizService.randomizeQuestionsAnswers(
        selectedQuestions,
      );
    }

    return selectedQuestions;
  }
}
