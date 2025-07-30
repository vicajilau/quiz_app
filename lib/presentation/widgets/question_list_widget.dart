import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/domain/models/quiz/quiz_file.dart';
import 'package:quiz_app/presentation/widgets/dialogs/add_edit_question_dialog.dart';

import '../../../../core/l10n/app_localizations.dart';

class QuestionListWidget extends StatefulWidget {
  final QuizFile quizFile;
  final VoidCallback onFileChange;
  const QuestionListWidget({
    super.key,
    required this.quizFile  ,
    required this.onFileChange,
  });

  @override
  State<QuestionListWidget> createState() => _QuestionListWidgetState();
}

class _QuestionListWidgetState extends State<QuestionListWidget> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      onReorder: _onReorder,
      children:
          List.generate(widget.quizFile.questions.length, (index) {
        final question =
            widget.quizFile.questions[index];
        return _buildDismissible(
          question,
          index,
          _buildListTile(
            question,
            index,
            widget.quizFile.questions[index].text,
          ),
        );
      }),
    );
  }

  Widget _buildListTile(Question question, int index, String subtitle) {
    return ListTile(
      title: Text(question.text),
      subtitle: Text(subtitle),
      onTap: () async {
        final updatedQuestion = await showDialog<Question>(
          context: context,
          builder: (context) => AddEditQuestionDialog(
            question: question,
            quizFile: widget.quizFile,
            questionPosition: index,
          ),
        );
        if (updatedQuestion != null) {
          setState(() {
            widget.quizFile.questions[index] = updatedQuestion;
            widget.onFileChange();
          });
        }
      },
    );
  }

  Future<bool> _confirmDismiss(BuildContext context, Question question) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.confirmDeleteTitle),
            content: Text(
                AppLocalizations.of(context)!.confirmDeleteMessage(question.text)),
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
      if (newIndex > oldIndex) newIndex -= 1;
      final question = widget.quizFile.questions.removeAt(oldIndex);
      widget.quizFile.questions.insert(newIndex, question);
      widget.onFileChange();
    });
  }

  Widget _buildDismissible(Question question, int index, Widget child) {
    return Dismissible(
      key: ValueKey(question),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) => _confirmDismiss(context, question),
      onDismissed: (direction) {
        setState(() {
          widget.quizFile.questions.removeAt(index);
          widget.onFileChange();
        });
      },
      background: _buildDismissBackground(alignment: Alignment.centerLeft),
      secondaryBackground:
          _buildDismissBackground(alignment: Alignment.centerRight),
      child: child,
    );
  }

  Widget _buildDismissBackground({required Alignment alignment}) {
    return Container(
      color: Colors.red,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }
}
