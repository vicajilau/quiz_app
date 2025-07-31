import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/service_locator.dart';
import '../../core/l10n/app_localizations.dart';
import '../../data/services/configuration_service.dart';
import '../../domain/models/quiz/question.dart';
import '../../domain/models/quiz/quiz_file.dart';
import '../../domain/services/quiz_service.dart';
import '../blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import '../blocs/quiz_execution_bloc/quiz_execution_event.dart';
import '../blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'quiz_execution/quiz_in_progress_view.dart';
import 'quiz_execution/quiz_completed_view.dart';
import 'dialogs/back_press_handler.dart';

class QuizFileExecutionScreen extends StatefulWidget {
  final QuizFile quizFile;

  const QuizFileExecutionScreen({super.key, required this.quizFile});

  @override
  State<QuizFileExecutionScreen> createState() =>
      _QuizFileExecutionScreenState();
}

class _QuizFileExecutionScreenState extends State<QuizFileExecutionScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _prepareQuizQuestions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.quizFile.metadata.title)),
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

        return BlocProvider(
          create: (context) =>
              QuizExecutionBloc()..add(QuizExecutionStarted(questionsToUse)),
          child: Builder(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text(widget.quizFile.metadata.title),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => BackPressHandler.handle(
                    context,
                    context.read<QuizExecutionBloc>(),
                  ),
                ),
              ),
              body: BlocConsumer<QuizExecutionBloc, QuizExecutionState>(
                listener: (context, state) {
                  // Handle any side effects if needed
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
        );
      },
    );
  }

  Future<List<Question>> _prepareQuizQuestions() async {
    // Get the configured question count from service locator
    final questionCount =
        ServiceLocator.instance.getQuestionCount() ??
        widget.quizFile.questions.length;

    // Get the configured question order
    final questionOrder = await ConfigurationService.instance
        .getQuestionOrder();

    // Select the questions to use for the quiz with the configured order
    return QuizService.selectQuestions(
      widget.quizFile.questions,
      questionCount,
      order: questionOrder,
    );
  }
}
