import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import 'package:quiz_app/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/quiz_progress_indicator.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/quiz_question_header.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/quiz_options_wrapper.dart';
import 'package:quiz_app/presentation/screens/quiz_execution/quiz_navigation_buttons.dart';
import 'package:quiz_app/core/service_locator.dart';

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
        // Only trigger listen logic if we are staying in progress and checking validation change
        if (previous is QuizExecutionInProgress &&
            current is QuizExecutionInProgress) {
          return current.isCurrentQuestionValidated !=
              previous.isCurrentQuestionValidated;
        }
        return false;
      },
      child: Column(
        children: [
          // Progress indicator (fixed)
          QuizProgressIndicator(state: widget.state),

          // Main content area (flexible)
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QuizQuestionHeader(state: widget.state),

                  const SizedBox(height: 16),

                  // Options section
                  QuizOptionsWrapper(state: widget.state),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Navigation buttons (fixed at bottom)
          QuizNavigationButtons(state: widget.state, isStudyMode: isStudyMode),
        ],
      ),
    );
  }
}
