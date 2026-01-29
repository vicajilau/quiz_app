import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/quiz_file.dart';
import 'package:quiz_app/presentation/screens/dialogs/add_edit_question_dialog.dart';
import 'package:quiz_app/presentation/screens/dialogs/ai_question_dialog.dart';
import 'package:quiz_app/data/services/configuration_service.dart';
import 'package:platform_detail/platform_detail.dart';
import '../../widgets/latex_text.dart';

import '../../../../../core/l10n/app_localizations.dart';

class QuestionListWidget extends StatefulWidget {
  final QuizFile quizFile;
  final VoidCallback onFileChange;
  const QuestionListWidget({
    super.key,
    required this.quizFile,
    required this.onFileChange,
  });

  @override
  State<QuestionListWidget> createState() => _QuestionListWidgetState();
}

class _QuestionListWidgetState extends State<QuestionListWidget> {
  bool _aiAssistantEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadAISettings();
  }

  Future<void> _loadAISettings() async {
    final aiEnabled = await ConfigurationService.instance
        .getAIAssistantEnabled();
    setState(() {
      _aiAssistantEnabled = aiEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      onReorder: _onReorder,
      padding: const EdgeInsets.all(8.0).copyWith(bottom: 80),
      children: List.generate(widget.quizFile.questions.length, (index) {
        final question = widget.quizFile.questions[index];
        return _buildDismissible(
          question,
          index,
          _buildQuestionCard(question, index),
        );
      }),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar configuración cuando el widget se actualiza
    _loadAISettings();
  }

  Widget _buildQuestionCard(Question question, int index) {
    final isDisabled = !question.isEnabled;

    return Card(
      key: ValueKey('${question.text}_${question.type}_$index'),
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1.0,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final updatedQuestion = await showDialog<Question>(
              context: context,
              builder: (context) => AddEditQuestionDialog(
                question: question,
                quizFile: widget.quizFile,
                questionPosition: index,
                onDelete: () {
                  setState(() {
                    widget.quizFile.questions.remove(question);
                    widget.onFileChange();
                  });
                },
              ),
            );
            if (updatedQuestion != null) {
              setState(() {
                widget.quizFile.questions[index] = updatedQuestion;
                widget.onFileChange();
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isDisabled
                  ? Border.all(
                      color: Colors.orange.withValues(alpha: 0.5),
                      width: 2,
                    )
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Tooltip(
                        message: isDisabled
                            ? AppLocalizations.of(context)!.enableQuestion
                            : AppLocalizations.of(context)!.disableQuestion,
                        child: GestureDetector(
                          onTap: () => _toggleQuestionEnabled(index),
                          child: Column(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isDisabled
                                      ? Colors.orange.withValues(alpha: 0.1)
                                      : Theme.of(
                                          context,
                                        ).primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDisabled
                                        ? Colors.orange.withValues(alpha: 0.3)
                                        : Theme.of(
                                            context,
                                          ).primaryColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: isDisabled
                                      ? Icon(
                                          Icons.pause_circle_outline,
                                          color: Colors.orange,
                                          size: 16,
                                        )
                                      : Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                ),
                              ),
                              if (isDisabled) ...[
                                const SizedBox(height: 2),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.questionDisabled,
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LaTeXText(
                              question.text,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                decoration: isDisabled
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isDisabled ? Colors.grey : null,
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Tooltip(
                                  message: question.type.getQuestionTypeLabel(
                                    context,
                                  ),
                                  child: Icon(
                                    question.type.getQuestionTypeIcon(),
                                    size: 16,
                                    color: isDisabled
                                        ? Colors.grey
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (question.options.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Tooltip(
                                    message: AppLocalizations.of(
                                      context,
                                    )!.optionsTooltip,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.optionsCount(
                                          question.options.length,
                                        ),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: isDisabled
                                              ? Colors.grey
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                if (question.explanation.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Tooltip(
                                    message: AppLocalizations.of(
                                      context,
                                    )!.explanationTooltip,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.lightbulb,
                                        size: 12,
                                        color: isDisabled
                                            ? Colors.grey
                                            : Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                                if (question.image != null) ...[
                                  const SizedBox(width: 8),
                                  Tooltip(
                                    message: AppLocalizations.of(
                                      context,
                                    )!.imageTooltip,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.image,
                                        size: 12,
                                        color: isDisabled
                                            ? Colors.grey
                                            : Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(width: 8),
                                if (_aiAssistantEnabled && !isDisabled)
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => AIQuestionDialog(
                                          question: question,
                                        ),
                                      );
                                    },
                                    child: Tooltip(
                                      message: AppLocalizations.of(
                                        context,
                                      )!.aiButtonTooltip,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.aiButtonText,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimaryContainer,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.auto_awesome,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onPrimaryContainer,
                                              size: 12,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (!PlatformDetail.isMobile)
                        IconButton(
                          onPressed: () => _deleteQuestion(index),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: AppLocalizations.of(context)!.deleteAction,
                        ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Deletes a question after user confirmation.
  ///
  /// This method is called when the delete button in the question card is pressed.
  /// It reuses [_confirmDismiss] to ask for confirmation before removing the
  /// question from the list.
  Future<void> _deleteQuestion(int index) async {
    final question = widget.quizFile.questions[index];
    final confirmed = await _confirmDismiss(context, question);
    if (confirmed && mounted) {
      setState(() {
        widget.quizFile.questions.removeAt(index);
        widget.onFileChange();
      });
    }
  }

  /// Toggles the enabled state of a question at the given [index].
  ///
  /// This updates the question in the list and notifies the parent widget
  /// about the file change.
  void _toggleQuestionEnabled(int index) {
    setState(() {
      final question = widget.quizFile.questions[index];
      widget.quizFile.questions[index] = question.copyWith(
        isEnabled: !question.isEnabled,
      );
      widget.onFileChange();
    });
  }

  /// Shows a confirmation dialog before deleting a [question].
  ///
  /// Returns `true` if the user confirms the deletion, `false` otherwise.
  Future<bool> _confirmDismiss(BuildContext context, Question question) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.confirmDeleteTitle),
            content: Text(
              AppLocalizations.of(context)!.confirmDeleteMessage(question.text),
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(false),
                child: Text(AppLocalizations.of(context)!.cancelButton),
              ),
              ElevatedButton(
                onPressed: () => context.pop(true),
                child: Text(AppLocalizations.of(context)!.deleteButton),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      // Adjust newIndex if dragging down
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      // Remove the item from old position and insert at new position
      final question = widget.quizFile.questions.removeAt(oldIndex);
      widget.quizFile.questions.insert(newIndex, question);

      // Notify parent that file has changed
      widget.onFileChange();
    });
  }

  Widget _buildDismissible(Question question, int index, Widget child) {
    return Dismissible(
      key: ValueKey('dismissible_${question.text}_${question.type}_$index'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) => _confirmDismiss(context, question),
      onDismissed: (direction) {
        setState(() {
          widget.quizFile.questions.removeAt(index);
          widget.onFileChange();
        });
      },
      background: _buildDismissBackground(alignment: Alignment.centerLeft),
      secondaryBackground: _buildDismissBackground(
        alignment: Alignment.centerRight,
      ),
      child: child,
    );
  }

  Widget _buildDismissBackground({required Alignment alignment}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_forever, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.deleteAction,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
