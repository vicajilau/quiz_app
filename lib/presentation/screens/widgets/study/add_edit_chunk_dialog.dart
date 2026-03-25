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
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';
import 'package:quizdy/presentation/widgets/quizdy_text_field.dart';

class AddEditChunkDialog extends StatefulWidget {
  final AppLocalizations localizations;
  final String? initialTitle;
  final String? initialText;

  const AddEditChunkDialog({
    super.key,
    required this.localizations,
    this.initialTitle,
    this.initialText,
  });

  @override
  State<AddEditChunkDialog> createState() => _AddEditChunkDialogState();
}

class _AddEditChunkDialogState extends State<AddEditChunkDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _textController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final title = _titleController.text.trim();
    final text = _textController.text.trim();

    if (title.isEmpty) return;

    // Returns a map with title and optional text
    Navigator.of(context).pop({'title': title, 'text': text});
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialTitle != null;
    final dialogTitle = isEditing
        ? widget.localizations.editSection
        : widget.localizations.addSection;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                  ),
                ),
                Text(
                  dialogTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 24),
            QuizdyFieldLabel(label: widget.localizations.sectionTitleLabel),
            const SizedBox(height: 6),
            QuizdyTextField(
              controller: _titleController,
              hint: widget.localizations.sectionTitleHint,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            QuizdyFieldLabel(label: widget.localizations.sectionContentLabel),
            const SizedBox(height: 6),
            Expanded(
              child: QuizdyTextField(
                controller: _textController,
                hint: widget.localizations.sectionContentHint,
                minLines: 1,
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(height: 24),
            QuizdyButton(
              type: QuizdyButtonType.primary,
              title: widget.localizations.saveButton,
              expanded: true,
              onPressed: _titleController.text.trim().isNotEmpty
                  ? _handleSave
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
