import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/core/context_extension.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/quiz_file.dart';
import 'package:quiz_app/presentation/screens/dialogs/add_edit_question_dialog.dart';
import 'package:quiz_app/presentation/screens/dialogs/ai_question_dialog.dart';
import 'package:quiz_app/data/services/configuration_service.dart';
import 'package:quiz_app/presentation/widgets/latex_text.dart';

import 'package:quiz_app/core/l10n/app_localizations.dart';

class QuestionListWidget extends StatefulWidget {
  final QuizFile quizFile;
  final VoidCallback onFileChange;
  final bool isReordering;

  const QuestionListWidget({
    super.key,
    required this.quizFile,
    required this.onFileChange,
    this.isReordering = false,
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
    return ReorderableListView.builder(
      onReorder: _onReorder,
      padding: const EdgeInsets.all(8.0).copyWith(bottom: 80),
      itemCount: widget.quizFile.questions.length,
      buildDefaultDragHandles: false,
      itemBuilder: (constext, index) {
        final question = widget.quizFile.questions[index];
        return _buildDismissible(
          question,
          index,
          _buildQuestionCard(question, index),
        );
      },
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDisabled) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 70),
                child: Text(
                  AppLocalizations.of(context)!.questionDisabled,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
            ListTile(
              contentPadding: EdgeInsets.only(
                top: isDisabled ? 0 : 8,
                left: 16,
                right: 16,
                bottom: 8,
              ),
              enabled: !isDisabled,
              title: LaTeXText(
                question.text,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  decoration: isDisabled ? TextDecoration.lineThrough : null,
                  color: isDisabled ? Colors.grey : null,
                ),
                maxLines: 2,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 6,
                  children: [
                    Tooltip(
                      message: AppLocalizations.of(context)!.optionsTooltip,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          spacing: 8,
                          mainAxisSize: MainAxisSize.min,
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
                            if (question.options.isNotEmpty)
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.optionsCount(question.options.length),
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
                          ],
                        ),
                      ),
                    ),
                    if (question.explanation.isNotEmpty)
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
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            Icons.lightbulb,
                            size: 16,
                            color: isDisabled
                                ? Colors.grey
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    if (question.image != null)
                      Tooltip(
                        message: AppLocalizations.of(context)!.imageTooltip,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            Icons.image,
                            size: 16,
                            color: isDisabled
                                ? Colors.grey
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),

                    if (_aiAssistantEnabled && !isDisabled)
                      GestureDetector(
                        onTap: () async {
                          final isAiAvailable = await ConfigurationService
                              .instance
                              .getIsAiAvailable();

                          if (!mounted) return;

                          if (!isAiAvailable) {
                            context.presentSnackBar(
                              AppLocalizations.of(context)!.aiApiKeyRequired,
                            );
                          } else {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) =>
                                  AIQuestionDialog(question: question),
                            );
                          }
                        },
                        child: Tooltip(
                          message: AppLocalizations.of(
                            context,
                          )!.aiButtonTooltip,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 6,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.aiButtonText,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.auto_awesome,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              onTap: () => _editQuestion(question, index),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  if (widget.isReordering)
                    ReorderableDragStartListener(
                      key: ValueKey<Question>(question),
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                  Tooltip(
                    message: isDisabled
                        ? AppLocalizations.of(context)!.enableQuestion
                        : AppLocalizations.of(context)!.disableQuestion,
                    child: GestureDetector(
                      onTap: () => _toggleQuestionEnabled(index),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isDisabled
                              ? Colors.orange.withValues(alpha: 0.1)
                              : Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(80),
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
                              ? const Icon(
                                  Icons.pause_circle_outline,
                                  color: Colors.orange,
                                  size: 16,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: _buildPopupMenu(question, index),
            ),
          ],
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

  Future<void> _editQuestion(Question question, int index) async {
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
  }

  Widget _buildPopupMenu(Question question, int index) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            _editQuestion(question, index);
            break;
          case 'delete':
            _deleteQuestion(index);
            break;
          case 'toggle':
            _toggleQuestionEnabled(index);
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                const Icon(Icons.edit, color: Colors.blue),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.edit),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'toggle',
            child: Row(
              children: [
                Icon(
                  question.isEnabled
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  question.isEnabled
                      ? AppLocalizations.of(context)!.disable
                      : AppLocalizations.of(context)!.enable,
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                const Icon(Icons.delete, color: Colors.red),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.deleteButton),
              ],
            ),
          ),
        ];
      },
      icon: const Icon(Icons.more_vert),
    );
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
          const Icon(Icons.delete_forever, color: Colors.white, size: 28),
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
