import 'package:flutter/material.dart';
import 'package:quiz_app/domain/models/quiz/question_type.dart';
import '../../../../../core/l10n/app_localizations.dart';

/// Separate widget for each option row to optimize rendering
class QuestionOptionRow extends StatefulWidget {
  final int index;
  final TextEditingController controller;
  final bool isCorrect;
  final QuestionType questionType;
  final String? optionsError;
  final bool canRemove;
  final ValueChanged<bool?> onCorrectChanged;
  final VoidCallback onTextChanged;
  final VoidCallback onRemove;

  const QuestionOptionRow({
    super.key,
    required this.index,
    required this.controller,
    required this.isCorrect,
    required this.questionType,
    required this.optionsError,
    required this.canRemove,
    required this.onCorrectChanged,
    required this.onTextChanged,
    required this.onRemove,
  });

  @override
  State<QuestionOptionRow> createState() => _QuestionOptionRowState();
}

class _QuestionOptionRowState extends State<QuestionOptionRow>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          // Use different input types based on question type
          if (widget.questionType == QuestionType.multipleChoice)
            Tooltip(
              message: localizations.selectCorrectAnswers,
              child: Checkbox(
                value: widget.isCorrect,
                activeColor: Colors.green,
                onChanged: widget.onCorrectChanged,
              ),
            )
          else if (widget.questionType == QuestionType.singleChoice ||
              widget.questionType == QuestionType.trueFalse)
            Tooltip(
              message: localizations.selectCorrectAnswer,
              child: Radio<int>(
                value: widget.index,
                activeColor: Colors.green,
                groupValue: widget.isCorrect ? widget.index : -1,
                onChanged: (value) =>
                    widget.onCorrectChanged(value == widget.index),
              ),
            ),
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              decoration: InputDecoration(
                labelText: "${localizations.optionLabel} ${widget.index + 1}",
                border: const OutlineInputBorder(),
                errorText:
                    widget.optionsError != null &&
                        widget.controller.text.trim().isEmpty &&
                        widget.questionType != QuestionType.trueFalse
                    ? localizations.optionEmptyError
                    : null,
              ),
              onChanged: (value) => widget.onTextChanged(),
              readOnly: widget.questionType == QuestionType.trueFalse,
            ),
          ),
          if (widget.questionType != QuestionType.trueFalse)
            IconButton(
              icon: Icon(
                Icons.remove_circle_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              tooltip: localizations.removeOption,
              onPressed: widget.canRemove ? widget.onRemove : null,
            ),
        ],
      ),
    );
  }
}
