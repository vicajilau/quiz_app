import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/service_locator.dart';
import '../../domain/models/quiz/quiz_file.dart';
import '../../domain/services/quiz_service.dart';
import '../blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import '../blocs/quiz_execution_bloc/quiz_execution_event.dart';
import '../blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'quiz_execution/quiz_in_progress_view.dart';
import 'quiz_execution/quiz_completed_view.dart';
import 'dialogs/back_press_handler.dart';

class QuizFileExecutionScreen extends StatelessWidget {
  final QuizFile quizFile;

  const QuizFileExecutionScreen({super.key, required this.quizFile});

  @override
  Widget build(BuildContext context) {
    // Get the configured question count from service locator
    final questionCount =
        ServiceLocator.instance.getQuestionCount() ?? quizFile.questions.length;

    // Select the questions to use for the quiz
    final questionsToUse = QuizService.selectRandomQuestions(
      quizFile.questions,
      questionCount,
    );

    return BlocProvider(
      create: (context) =>
          QuizExecutionBloc()..add(QuizExecutionStarted(questionsToUse)),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(quizFile.metadata.title),
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
  }
}
