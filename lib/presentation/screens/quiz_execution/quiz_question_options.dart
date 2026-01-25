import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/models/quiz/question_type.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_bloc.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_event.dart';
import '../../blocs/quiz_execution_bloc/quiz_execution_state.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../utils/question_translation_helper.dart';
import '../../widgets/latex_text.dart';

class QuizQuestionOptions extends StatefulWidget {
  final QuizExecutionInProgress state;
  final bool showCorrectAnswerCount;

  const QuizQuestionOptions({
    super.key,
    required this.state,
    this.showCorrectAnswerCount = false,
  });

  @override
  State<QuizQuestionOptions> createState() => _QuizQuestionOptionsState();
}

class _QuizQuestionOptionsState extends State<QuizQuestionOptions> {
  late TextEditingController _essayController;

  @override
  void initState() {
    super.initState();
    _essayController = TextEditingController();
    _updateEssayController();
  }

  @override
  void didUpdateWidget(QuizQuestionOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.currentQuestionIndex !=
            widget.state.currentQuestionIndex ||
        oldWidget.state.essayAnswers != widget.state.essayAnswers) {
      _updateEssayController();
    }
  }

  void _updateEssayController() {
    final currentText =
        widget.state.essayAnswers[widget.state.currentQuestionIndex] ?? '';
    if (_essayController.text != currentText) {
      _essayController.text = currentText;
    }
  }

  @override
  void dispose() {
    _essayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionType = widget.state.currentQuestion.type;
    final correctAnswersCount =
        widget.state.currentQuestion.correctAnswers.length;

    // Handle essay questions separately
    if (questionType == QuestionType.essay) {
      return _buildEssayInput(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show correct answer count hint for multiple choice questions
        if (widget.showCorrectAnswerCount &&
            questionType == QuestionType.multipleChoice &&
            correctAnswersCount > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.correctAnswersCount(correctAnswersCount),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Options list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.state.currentQuestion.options.length,
          itemBuilder: (context, index) {
            final option = widget.state.currentQuestion.options[index];
            final isSelected = widget.state.isOptionSelected(index);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Card(
                elevation: isSelected ? 4 : 1,
                child: _buildOptionTile(
                  context,
                  questionType,
                  option,
                  index,
                  isSelected,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    QuestionType questionType,
    String option,
    int index,
    bool isSelected,
  ) {
    final localizations = AppLocalizations.of(context)!;
    final translatedOption = QuestionTranslationHelper.translateOption(
      option,
      localizations,
    );

    final optionTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
    );

    // For multiple choice questions, use CheckboxListTile
    if (questionType == QuestionType.multipleChoice) {
      return CheckboxListTile(
        title: IgnorePointer(
          child: LaTeXText(translatedOption, style: optionTextStyle),
        ),
        value: isSelected,
        onChanged: (bool? value) {
          context.read<QuizExecutionBloc>().add(
            AnswerSelected(index, value ?? false),
          );
        },
        activeColor: Theme.of(context).primaryColor,
        controlAffinity: ListTileControlAffinity.leading,
      );
    }
    // For single choice, true/false, and essay questions, use RadioListTile
    else {
      // Get the currently selected option (if any)
      final currentAnswers = widget.state.currentQuestionAnswers;
      final selectedIndex = currentAnswers.isNotEmpty
          ? currentAnswers.first
          : -1;

      return material.RadioListTile<int>(
        groupValue: selectedIndex >= 0 ? selectedIndex : null,
        onChanged: (int? value) {
          if (value != null) {
            // For single selection, first deselect all, then select the chosen one
            context.read<QuizExecutionBloc>().add(AnswerSelected(value, true));
          }
        },
        title: IgnorePointer(
          child: LaTeXText(translatedOption, style: optionTextStyle),
        ),
        value: index,
        activeColor: Theme.of(context).primaryColor,
        controlAffinity: ListTileControlAffinity.leading,
      );
    }
  }

  Widget _buildEssayInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.questionTypeEssay,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.5),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _essayController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.explanationHint,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                onChanged: (text) {
                  context.read<QuizExecutionBloc>().add(
                    EssayAnswerChanged(text),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
