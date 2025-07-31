import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/quiz/quiz_file.dart';
import '../blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import '../blocs/quiz_execution_bloc/quiz_execution_event.dart';
import '../blocs/quiz_execution_bloc/quiz_execution_state.dart';

class QuizFileExecutionScreen extends StatelessWidget {
  final QuizFile quizFile;

  const QuizFileExecutionScreen({super.key, required this.quizFile});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          QuizExecutionBloc()..add(QuizExecutionStarted(quizFile.questions)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(quizFile.metadata.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _handleBackPress(context, context.read<QuizExecutionBloc>()),
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
              return _buildQuizInProgress(context, state);
            } else if (state is QuizExecutionCompleted) {
              return _buildQuizCompleted(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildQuizInProgress(
    BuildContext context,
    QuizExecutionInProgress state,
  ) {
    return Column(
      children: [
        // Progress indicator
        _buildProgressIndicator(state),

        // Question content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question number and text
                _buildQuestionHeader(context, state),

                const SizedBox(height: 24),

                // Options
                Expanded(child: _buildQuestionOptions(context, state)),

                // Navigation buttons
                _buildNavigationButtons(context, state),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(QuizExecutionInProgress state) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: state.progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.currentQuestionIndex + 1} / ${state.totalQuestions}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(
    BuildContext context,
    QuizExecutionInProgress state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pregunta ${state.currentQuestionIndex + 1}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.currentQuestion.text,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildQuestionOptions(
    BuildContext context,
    QuizExecutionInProgress state,
  ) {
    return ListView.builder(
      itemCount: state.currentQuestion.options.length,
      itemBuilder: (context, index) {
        final option = state.currentQuestion.options[index];
        final isSelected = state.isOptionSelected(index);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Card(
            elevation: isSelected ? 4 : 1,
            child: CheckboxListTile(
              title: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              value: isSelected,
              onChanged: (bool? value) {
                context.read<QuizExecutionBloc>().add(
                  AnswerSelected(index, value ?? false),
                );
              },
              activeColor: Theme.of(context).primaryColor,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    QuizExecutionInProgress state,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          // Previous button
          if (!state.isFirstQuestion)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<QuizExecutionBloc>().add(
                    PreviousQuestionRequested(),
                  );
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Anterior'),
              ),
            ),

          if (!state.isFirstQuestion) const SizedBox(width: 16),

          // Next/Submit button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                if (state.isLastQuestion) {
                  _showSubmitDialog(context, context.read<QuizExecutionBloc>());
                } else {
                  context.read<QuizExecutionBloc>().add(
                    NextQuestionRequested(),
                  );
                }
              },
              icon: Icon(
                state.isLastQuestion ? Icons.check : Icons.arrow_forward,
              ),
              label: Text(state.isLastQuestion ? 'Finalizar' : 'Siguiente'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCompleted(
    BuildContext context,
    QuizExecutionCompleted state,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Results header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    state.score >= 70 ? Icons.celebration : Icons.info,
                    size: 64,
                    color: state.score >= 70 ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¡Quiz Completado!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Puntuación: ${state.score.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: state.score >= 70 ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${state.correctAnswers} de ${state.totalQuestions} respuestas correctas',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Question results
          Expanded(
            child: ListView.builder(
              itemCount: state.questionResults.length,
              itemBuilder: (context, index) {
                final result = state.questionResults[index];
                return _buildQuestionResultCard(context, result, index + 1);
              },
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Get the bloc from the current context since we're inside BlocConsumer
                      final bloc = BlocProvider.of<QuizExecutionBloc>(context);
                      bloc.add(QuizRestarted());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.home),
                    label: const Text('Volver'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionResultCard(
    BuildContext context,
    QuestionResult result,
    int questionNumber,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        leading: Icon(
          result.isCorrect ? Icons.check_circle : Icons.cancel,
          color: result.isCorrect ? Colors.green : Colors.red,
        ),
        title: Text(
          'Pregunta $questionNumber',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          result.question.text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pregunta: ${result.question.text}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                // Show all options with indicators
                ...result.question.options.asMap().entries.map((entry) {
                  final optionIndex = entry.key;
                  final optionText = entry.value;
                  final isCorrect = result.correctAnswers.contains(optionIndex);
                  final wasSelected = result.userAnswers.contains(optionIndex);

                  Color? backgroundColor;
                  IconData? icon;

                  if (isCorrect && wasSelected) {
                    backgroundColor = Colors.green.withValues(alpha: 0.1);
                    icon = Icons.check_circle;
                  } else if (isCorrect && !wasSelected) {
                    backgroundColor = Colors.green.withValues(alpha: 0.1);
                    icon = Icons.check_circle_outline;
                  } else if (!isCorrect && wasSelected) {
                    backgroundColor = Colors.red.withValues(alpha: 0.1);
                    icon = Icons.cancel;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 4.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Row(
                      children: [
                        if (icon != null)
                          Icon(
                            icon,
                            size: 20,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(optionText)),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSubmitDialog(BuildContext context, QuizExecutionBloc bloc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Finalizar Quiz'),
          content: const Text(
            '¿Estás seguro de que quieres finalizar el quiz? No podrás cambiar tus respuestas después.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                bloc.add(QuizSubmitted());
              },
              child: const Text('Finalizar'),
            ),
          ],
        );
      },
    );
  }

  void _handleBackPress(BuildContext context, QuizExecutionBloc bloc) {
    final state = bloc.state;

    if (state is QuizExecutionInProgress) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Abandonar Quiz'),
            content: const Text(
              '¿Estás seguro de que quieres abandonar el quiz? Se perderá todo el progreso.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pop();
                },
                child: const Text('Abandonar'),
              ),
            ],
          );
        },
      );
    } else {
      context.pop();
    }
  }
}
