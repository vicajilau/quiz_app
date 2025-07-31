import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
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
  bool _examTimeEnabled = false;
  int _examTimeMinutes = 60;

  @override
  void initState() {
    super.initState();
    _loadExamTimeSettings();
  }

  Future<void> _loadExamTimeSettings() async {
    final examTimeEnabled = await ConfigurationService.instance
        .getExamTimeEnabled();
    final examTimeMinutes = await ConfigurationService.instance
        .getExamTimeMinutes();

    if (mounted) {
      setState(() {
        _examTimeEnabled = examTimeEnabled;
        _examTimeMinutes = examTimeMinutes;
      });
    }
  }

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
                actions: [
                  if (_examTimeEnabled)
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Center(
                        child: ExamTimerWidget(
                          initialDurationMinutes: _examTimeMinutes,
                          onTimeExpired: () {
                            // Force complete the quiz
                            final bloc = context.read<QuizExecutionBloc>();
                            bloc.add(QuizSubmitted());
                          },
                        ),
                      ),
                    ),
                ],
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

// Separate widget for the exam timer to avoid rebuilding the entire screen
class ExamTimerWidget extends StatefulWidget {
  final int initialDurationMinutes;
  final VoidCallback onTimeExpired;

  const ExamTimerWidget({
    super.key,
    required this.initialDurationMinutes,
    required this.onTimeExpired,
  });

  @override
  State<ExamTimerWidget> createState() => _ExamTimerWidgetState();
}

class _ExamTimerWidgetState extends State<ExamTimerWidget>
    with TickerProviderStateMixin {
  Timer? _examTimer;
  Duration? _remainingTime;
  late AnimationController _timerAnimationController;

  @override
  void initState() {
    super.initState();
    _timerAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _remainingTime = Duration(minutes: widget.initialDurationMinutes);
    _startExamTimer();
  }

  @override
  void dispose() {
    _examTimer?.cancel();
    _timerAnimationController.dispose();
    super.dispose();
  }

  void _startExamTimer() {
    if (_remainingTime == null) return;

    _timerAnimationController.repeat();

    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingTime!.inSeconds <= 0) {
        _handleTimeExpired();
        return;
      }

      setState(() {
        _remainingTime = _remainingTime! - const Duration(seconds: 1);
      });
    });
  }

  void _handleTimeExpired() {
    _examTimer?.cancel();
    _timerAnimationController.stop();

    if (!mounted) return;

    // Show time expired dialog
    _showTimeExpiredDialog();
  }

  void _showTimeExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.examTimeExpiredTitle),
        content: Text(AppLocalizations.of(context)!.examTimeExpiredMessage),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onTimeExpired();
            },
            child: Text(AppLocalizations.of(context)!.finish),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_remainingTime == null) {
      return const SizedBox.shrink();
    }

    final hours = _remainingTime!.inHours.toString().padLeft(2, '0');
    final minutes = (_remainingTime!.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remainingTime!.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _remainingTime!.inMinutes < 5
            ? Colors.red.withValues(alpha: 0.1)
            : Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _remainingTime!.inMinutes < 5
              ? Colors.red
              : Theme.of(context).primaryColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RotationTransition(
            turns: _timerAnimationController,
            child: Icon(
              Icons.hourglass_empty,
              size: 16,
              color: _remainingTime!.inMinutes < 5
                  ? Colors.red
                  : Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(
              context,
            )!.remainingTime(hours, minutes, seconds),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: _remainingTime!.inMinutes < 5
                  ? Colors.red
                  : Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
