// Copyright (C) 2026 Víctor Carreras
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/domain/models/quiz/study_component.dart';
import 'package:quizdy/presentation/blocs/study_editor_cubit/study_editor_cubit.dart';
import 'package:quizdy/presentation/screens/widgets/common/quizdy_app_bar.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';
import 'package:quizdy/presentation/widgets/quizdy_text_field.dart';

/// Full-screen panel for editing a [StudyComponent] with `componentType == 'paragraph'`.
class ParagraphPropertyPanel extends StatefulWidget {
  final int chunkIndex;
  final int pageIndex;
  final int componentIndex;

  const ParagraphPropertyPanel({
    super.key,
    required this.chunkIndex,
    required this.pageIndex,
    required this.componentIndex,
  });

  @override
  State<ParagraphPropertyPanel> createState() => _ParagraphPropertyPanelState();
}

class _ParagraphPropertyPanelState extends State<ParagraphPropertyPanel> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    final element = context
        .read<StudyEditorCubit>()
        .state
        .chunks[widget.chunkIndex]
        .pages[widget.pageIndex]
        .uiElements[widget.componentIndex];
    _titleController = TextEditingController(
      text: element.props['title']?.toString() ?? '',
    );
    _bodyController = TextEditingController(
      text: element.props['body']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _save() {
    final props = <String, dynamic>{
      'body': _bodyController.text,
      if (_titleController.text.isNotEmpty) 'title': _titleController.text,
    };
    context.read<StudyEditorCubit>().updateComponent(
      widget.chunkIndex,
      widget.pageIndex,
      widget.componentIndex,
      StudyComponent(componentType: StudyComponentType.paragraph, props: props),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: QuizdyAppBar(
        onLeadingPressed: () => Navigator.of(context).pop(),
        title: Text(
          localizations.studyEditorEditParagraph,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Plus Jakarta Sans',
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QuizdyFieldLabel(label: localizations.studyEditorFieldTitle),
                  const SizedBox(height: 8),
                  QuizdyTextField(
                    controller: _titleController,
                    hint: localizations.studyEditorFieldTitle,
                  ),
                  const SizedBox(height: 24),
                  QuizdyFieldLabel(label: localizations.studyEditorFieldBody),
                  const SizedBox(height: 8),
                  QuizdyTextField(
                    controller: _bodyController,
                    hint: localizations.studyEditorFieldBody,
                    minLines: 6,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ],
              ),
            ),
          ),
          _SaveFooter(onSave: _save),
        ],
      ),
    );
  }
}

class _SaveFooter extends StatelessWidget {
  final VoidCallback onSave;

  const _SaveFooter({required this.onSave});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: QuizdyButton(
          title: localizations.save,
          onPressed: onSave,
          expanded: true,
        ),
      ),
    );
  }
}
