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

import 'package:flutter/material.dart' hide Page;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/domain/models/quiz/study_page.dart';
import 'package:quizdy/presentation/blocs/study_editor_cubit/study_editor_cubit.dart';
import 'package:quizdy/presentation/blocs/study_editor_cubit/study_editor_state.dart';
import 'package:quizdy/presentation/screens/study_editor/component_editor_screen.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';

/// Manages the list of pages within a study section (chunk).
/// Allows adding, deleting, duplicating, reordering and opening pages.
class SectionPageManagerScreen extends StatelessWidget {
  final int chunkIndex;

  const SectionPageManagerScreen({super.key, required this.chunkIndex});

  void _openComponentEditor(BuildContext context, int pageIndex) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<StudyEditorCubit>(),
          child: ComponentEditorScreen(
            chunkIndex: chunkIndex,
            pageIndex: pageIndex,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeletePage(BuildContext context, int pageIndex) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.studyEditorDeletePage),
        content: Text(l.studyEditorDeletePage),
        actions: [
          QuizdyButton(
            type: QuizdyButtonType.tertiary,
            title: l.cancelButton,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          QuizdyButton(
            type: QuizdyButtonType.warning,
            title: l.deleteButton,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<StudyEditorCubit>().deletePage(chunkIndex, pageIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocBuilder<StudyEditorCubit, StudyEditorState>(
      builder: (context, state) {
        final chunk = state.chunks[chunkIndex];
        final pages = chunk.pages;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(localizations.studyEditorEditName(chunk.title)),
            elevation: 0,
          ),
          body: pages.isEmpty
              ? Center(child: Text(localizations.studyEditorEmptyPages))
              : ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  buildDefaultDragHandles: false,
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    return _PageCard(
                      key: ValueKey('page_${chunkIndex}_$index'),
                      page: pages[index],
                      index: index,
                      label: localizations.studyEditorPageN(index + 1),
                      onTap: () => _openComponentEditor(context, index),
                      onDuplicate: () => context
                          .read<StudyEditorCubit>()
                          .duplicatePage(chunkIndex, index),
                      onDelete: () => _confirmDeletePage(context, index),
                    );
                  },
                  onReorder: (oldIndex, newIndex) => context
                      .read<StudyEditorCubit>()
                      .reorderPages(chunkIndex, oldIndex, newIndex),
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () =>
                context.read<StudyEditorCubit>().addPage(chunkIndex),
            icon: const Icon(LucideIcons.plus),
            label: Text(localizations.studyEditorAddPage),
          ),
        );
      },
    );
  }
}

class _PageCard extends StatelessWidget {
  final StudyPage page;
  final int index;
  final String label;
  final VoidCallback onTap;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const _PageCard({
    super.key,
    required this.page,
    required this.index,
    required this.label,
    required this.onTap,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final componentCount = page.uiElements.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: ReorderableDragStartListener(
          index: index,
          child: Icon(
            LucideIcons.gripVertical,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
        title: Text(label),
        subtitle: Text(
          '$componentCount ${AppLocalizations.of(context)!.studyEditorComponents.toLowerCase()}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                LucideIcons.copy,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: onDuplicate,
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: Icon(
                LucideIcons.trash2,
                size: 18,
                color: colorScheme.error,
              ),
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
            ),
            const Icon(LucideIcons.chevronRight),
          ],
        ),
      ),
    );
  }
}
