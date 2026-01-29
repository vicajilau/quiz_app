import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/question_type.dart';
import 'package:quiz_app/domain/models/quiz/quiz_file.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../utils/question_translation_helper.dart';
import '../widgets/add_edit_question/question_image_section.dart';
import '../widgets/add_edit_question/question_options_section.dart';
import 'mixins/option_management_mixin.dart';
import 'mixins/validation_mixin.dart';
import '../../widgets/latex_text.dart';

/// Dialog widget for creating or editing a Question.
class AddEditQuestionDialog extends StatefulWidget {
  // Optional question for editing.
  final Question? question;
  // The file containing all questions.
  final QuizFile quizFile;
  // Optional index for editing a specific question.
  final int? questionPosition;
  final VoidCallback? onDelete;

  /// Constructor for the dialog.
  const AddEditQuestionDialog({
    super.key,
    this.question,
    required this.quizFile,
    this.questionPosition,
    this.onDelete,
  });

  @override
  State<AddEditQuestionDialog> createState() => _AddEditQuestionDialogState();
}

class _AddEditQuestionDialogState extends State<AddEditQuestionDialog>
    with OptionManagementMixin, ValidationMixin {
  late TextEditingController _questionTextController;
  late TextEditingController _explanationController;

  QuestionType _selectedType = QuestionType.multipleChoice;
  String? _imageData;

  @override
  void initState() {
    super.initState();

    // Initialize the text controllers
    _questionTextController = TextEditingController();
    _explanationController = TextEditingController();

    if (widget.question != null) {
      _questionTextController.text = widget.question!.text;
      _explanationController.text = widget.question!.explanation;
      _imageData = widget.question!.image;
      _selectedType = widget.question!.type;

      // Initialize options using the mixin
      initializeOptions(
        initialOptions: widget.question!.options,
        initialCorrectAnswers: widget.question!.correctAnswers,
      );
    } else {
      _selectedType = QuestionType.multipleChoice;
      // Initialize empty options using the mixin
      initializeDefaultOptions(_selectedType);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Set up true/false options if needed
    if (_selectedType == QuestionType.trueFalse) {
      setupTrueFalseOptions();
    }

    // Translate options after context is available
    if (widget.question != null) {
      final localizations = AppLocalizations.of(context)!;
      for (int i = 0; i < optionControllers.length; i++) {
        final originalOption = widget.question!.options[i];
        final translatedOption = QuestionTranslationHelper.translateOption(
          originalOption,
          localizations,
        );
        optionControllers[i].text = translatedOption;
      }
    }
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    _explanationController.dispose();
    disposeOptions();
    super.dispose();
  }

  /// Handle question type change
  void _onQuestionTypeChanged(QuestionType? type) {
    if (type != null && type != _selectedType) {
      setState(() {
        _selectedType = type;
      });
      updateOptionsForType(type);
    }
  }

  /// Handle image data change
  void _onImageChanged(String imageData) {
    setState(() {
      _imageData = imageData;
    });
  }

  /// Handle image removal
  void _onImageRemoved() {
    setState(() {
      _imageData = null;
    });
  }

  /// Save the question
  void _saveQuestion() {
    final localizations = AppLocalizations.of(context)!;

    if (!validateForm(
      questionText: _questionTextController.text,
      questionType: _selectedType,
      optionControllers: optionControllers,
      correctAnswers: correctAnswers,
      localizations: localizations,
      optionsErrorNotifier: optionsErrorNotifier,
    )) {
      return;
    }

    // Create the question object
    final newQuestion = Question(
      text: _questionTextController.text.trim(),
      type: _selectedType,
      options: _selectedType == QuestionType.essay
          ? <String>[]
          : optionControllers
                .map((controller) => controller.text.trim())
                .toList(),
      correctAnswers: _selectedType == QuestionType.essay
          ? <int>[]
          : getCorrectAnswerIndexes(),
      explanation: _explanationController.text.trim(),
      image: _imageData,
    );

    // Update the question in the quiz file if editing
    if (widget.questionPosition != null) {
      // Editing existing question
      widget.quizFile.questions[widget.questionPosition!] = newQuestion;
    }

    // Close the dialog and return the new/updated question
    context.pop(newQuestion);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.question == null
                ? localizations.addQuestion
                : localizations.editQuestion,
          ),
          if (widget.question != null && widget.onDelete != null)
            IconButton(
              onPressed: _confirmAndDelete,
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: localizations.deleteAction,
            ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Question Type Dropdown with Icon
              Row(
                children: [
                  // Question type icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _selectedType.getQuestionTypeIcon(),
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Question type dropdown
                  Expanded(
                    child: DropdownButtonFormField<QuestionType>(
                      initialValue: _selectedType,
                      onChanged: _onQuestionTypeChanged,
                      decoration: InputDecoration(
                        labelText: localizations.questionType,
                        border: const OutlineInputBorder(),
                      ),
                      items: QuestionType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.getQuestionTypeLabel(context)),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Question Text Field with Live Preview
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if (_questionTextController.text.contains(
                                '\$',
                              )) ...[
                                const SizedBox(width: 12),
                                Text(
                                  '${localizations.preview}: ',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.05),
                                    border: Border.all(
                                      color: Colors.blue.withValues(alpha: 0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                    heightFactor: 1.0,
                                    child: LaTeXText(
                                      _questionTextController.text,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _questionTextController,
                    maxLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    onChanged: (_) {
                      clearQuestionTextError();
                      setState(() {}); // Trigger rebuild for live preview
                    },
                    decoration: InputDecoration(
                      labelText: localizations.questionText,
                      border: const OutlineInputBorder(),
                      errorText: questionTextError,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Image Section
              QuestionImageSection(
                imageData: _imageData,
                onImagePicked: () {}, // Will be handled by onImageChanged
                onImageRemoved: _onImageRemoved,
                onImageChanged: _onImageChanged,
              ),
              const SizedBox(height: 16),

              // Options Section (only for non-essay questions)
              if (_selectedType != QuestionType.essay)
                QuestionOptionsSection(
                  questionType: _selectedType,
                  optionControllers: optionControllers,
                  correctAnswersNotifier: correctAnswersNotifier,
                  optionsErrorNotifier: optionsErrorNotifier,
                  optionKeys: optionKeys,
                  onAddOption: addOption,
                  onRemove: removeOption,
                  onCorrectChanged: (index, value) =>
                      updateCorrectAnswer(index, value, _selectedType),
                  onTextChanged: clearOptionsError,
                ),

              const SizedBox(height: 16),

              // Explanation Field with Live Preview
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if (_explanationController.text.contains(
                                '\$',
                              )) ...[
                                const SizedBox(width: 12),
                                Text(
                                  '${localizations.preview}: ',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.05),
                                    border: Border.all(
                                      color: Colors.blue.withValues(alpha: 0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                    heightFactor: 1.0,
                                    child: LaTeXText(
                                      _explanationController.text,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _explanationController,
                    maxLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    onChanged: (_) {
                      setState(() {}); // Trigger rebuild for live preview
                    },
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.explanationLabel,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(localizations.cancel),
        ),
        ElevatedButton(
          onPressed: _saveQuestion,
          child: Text(localizations.save),
        ),
      ],
    );
  }

  Future<void> _confirmAndDelete() async {
    final localizations = AppLocalizations.of(context)!;
    final confirmed =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(localizations.confirmDeleteTitle),
            content: Text(
              localizations.confirmDeleteMessage(widget.question!.text),
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(false),
                child: Text(localizations.cancelButton),
              ),
              ElevatedButton(
                onPressed: () => context.pop(true),
                child: Text(localizations.deleteButton),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed && mounted) {
      widget.onDelete!();
      context.pop(null);
    }
  }
}
