import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/core/theme/app_theme.dart';
import 'package:quiz_app/core/theme/extensions/confirm_dialog_colors_extension.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_event.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/quiz_progress_indicator.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/quiz_question_header.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/quiz_options_wrapper.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/quiz_navigation_buttons.dart';
import 'package:quiz_app/core/service_locator.dart';
import 'package:quiz_app/presentation/screens/dialogs/back_press_handler.dart';
import 'package:quiz_app/presentation/widgets/exam_timer.dart';

class QuizInProgressView extends StatefulWidget {
  final QuizExecutionInProgress state;

  const QuizInProgressView({super.key, required this.state});

  @override
  State<QuizInProgressView> createState() => _QuizInProgressViewState();
}

class _QuizInProgressViewState extends State<QuizInProgressView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get Study Mode setting
    final quizConfig = ServiceLocator.instance.getQuizConfig();
    final isStudyMode = quizConfig?.isStudyMode ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.appColors;

    // Design Tokens
    final closeBtnBorder = isDark ? Colors.transparent : AppTheme.zinc200;
    final cardBorder = isDark ? Colors.transparent : AppTheme.zinc200;
    final showTimer = !isStudyMode && (quizConfig?.enableTimeLimit ?? false);

    return BlocListener<QuizExecutionBloc, QuizExecutionState>(
      listener: (context, state) {
        if (state is QuizExecutionInProgress && isStudyMode) {
          // If the question was just validated (Answer checked)
          if (state.isCurrentQuestionValidated &&
              !widget.state.isCurrentQuestionValidated) {
            _scrollToBottom();
          }
        }
      },
      listenWhen: (previous, current) {
        if (previous is QuizExecutionInProgress &&
            current is QuizExecutionInProgress) {
          return current.isCurrentQuestionValidated !=
              previous.isCurrentQuestionValidated;
        }
        return false;
      },
      child: Column(
        children: [
          // Custom Header (Close Left + Progress Center)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Progress Indicator (Left)
                Expanded(child: QuizProgressIndicator(state: widget.state)),

                if (showTimer) ...[
                  const SizedBox(width: 8),
                  ExamTimerWidget(
                    initialDurationMinutes: quizConfig?.timeLimitMinutes ?? 0,
                    onTimeExpired: () {
                      context.read<QuizExecutionBloc>().add(QuizSubmitted());
                    },
                  ),
                ],

                const SizedBox(width: 16),

                // Close Button (Right)
                IconButton(
                  onPressed: () => BackPressHandler.handle(
                    context,
                    context.read<QuizExecutionBloc>(),
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: colors.card,
                    fixedSize: const Size(48, 48),
                    padding: EdgeInsets.zero,
                    shape: CircleBorder(
                      side: closeBtnBorder == Colors.transparent
                          ? BorderSide.none
                          : BorderSide(color: closeBtnBorder),
                    ),
                  ),
                  icon: Icon(Icons.close, color: colors.subtitle, size: 24),
                ),
              ],
            ),
          ),

          // Main Content (Centered Question Card)
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Center aligned text
                      children: [
                        // Question Header (Text, Number, Type)
                        // Note: Ensure QuestionHeader text alignment is handled inside that widget or here
                        QuizQuestionHeader(state: widget.state),

                        const SizedBox(height: 32),

                        // Options
                        QuizOptionsWrapper(state: widget.state),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Footer (Navigation Buttons)
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: QuizNavigationButtons(
                state: widget.state,
                isStudyMode: isStudyMode,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
