import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../core/service_locator.dart';
import '../../core/l10n/app_localizations.dart';
import '../../data/services/configuration_service.dart';
import '../../domain/models/quiz/question.dart';
import '../../domain/models/quiz/quiz_file.dart';
import '../../data/services/quiz_service.dart';
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
  bool _randomizeAnswers = false;

  @override
  void initState() {
    super.initState();
    _loadExamTimeSettings();
    _loadQuizSettings();
  }

  Future<void> _loadExamTimeSettings() async {
    final examTimeEnabled = await ConfigurationService.instance
        .getExamTimeEnabled();
    final examTimeMinutes = await ConfigurationService.instance
        .getExamTimeMinutes();

    // Get Study Mode setting from ServiceLocator
    final quizConfig = ServiceLocator.instance.getQuizConfig();
    final isStudyMode = quizConfig?.isStudyMode ?? false;

    if (mounted) {
      setState(() {
        // In Study Mode, force disable the timer
        _examTimeEnabled = isStudyMode ? false : examTimeEnabled;
        _examTimeMinutes = examTimeMinutes;
      });
    }
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

        return BlocProvider<QuizExecutionBloc>(
          create: (_) {
            final quizConfig = ServiceLocator.instance.getQuizConfig();
            final isStudyMode = quizConfig?.isStudyMode ?? false;

            return ServiceLocator.instance.getIt<QuizExecutionBloc>()..add(
              QuizExecutionStarted(questionsToUse, isStudyMode: isStudyMode),
            );
          },
          child: Builder(
            builder: (context) => SafeArea(
              child: Scaffold(
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
                          child:
                              BlocBuilder<
                                QuizExecutionBloc,
                                QuizExecutionState
                              >(
                                builder: (context, state) {
                                  return ExamTimerWidget(
                                    initialDurationMinutes: _examTimeMinutes,
                                    isQuizCompleted:
                                        state is QuizExecutionCompleted,
                                    onTimeExpired: () {
                                      // Force complete the quiz
                                      final bloc = context
                                          .read<QuizExecutionBloc>();
                                      bloc.add(QuizSubmitted());
                                    },
                                  );
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

// Separate widget for the exam timer to avoid rebuilding the entire screen
class ExamTimerWidget extends StatefulWidget {
  final int initialDurationMinutes;
  final VoidCallback onTimeExpired;
  final bool isQuizCompleted;

  const ExamTimerWidget({
    super.key,
    required this.initialDurationMinutes,
    required this.onTimeExpired,
    this.isQuizCompleted = false,
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
    if (!widget.isQuizCompleted) {
      _startExamTimer();
    }
  }

  @override
  void didUpdateWidget(ExamTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Stop timer when quiz is completed
    if (!oldWidget.isQuizCompleted && widget.isQuizCompleted) {
      _stopTimer();
    }
  }

  @override
  void dispose() {
    _examTimer?.cancel();
    _timerAnimationController.dispose();
    super.dispose();
  }

  void _stopTimer() {
    _examTimer?.cancel();
    _timerAnimationController.stop();
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
    _stopTimer();

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
              context.pop();
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
            turns: widget.isQuizCompleted
                ? const AlwaysStoppedAnimation(0)
                : _timerAnimationController,
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
