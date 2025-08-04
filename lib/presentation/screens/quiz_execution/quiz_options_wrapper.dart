import 'package:flutter/material.dart';
import '../../../data/services/configuration_service.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'quiz_question_options.dart';

/// Wrapper widget that loads quiz configuration and passes it to QuizQuestionOptions
class QuizOptionsWrapper extends StatefulWidget {
  final QuizExecutionInProgress state;

  const QuizOptionsWrapper({super.key, required this.state});

  @override
  State<QuizOptionsWrapper> createState() => _QuizOptionsWrapperState();
}

class _QuizOptionsWrapperState extends State<QuizOptionsWrapper> {
  bool _showCorrectAnswerCount = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    final showCorrectAnswerCount = await ConfigurationService.instance
        .getShowCorrectAnswerCount();

    if (mounted) {
      setState(() {
        _showCorrectAnswerCount = showCorrectAnswerCount;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return QuizQuestionOptions(
      state: widget.state,
      showCorrectAnswerCount: _showCorrectAnswerCount,
    );
  }
}
