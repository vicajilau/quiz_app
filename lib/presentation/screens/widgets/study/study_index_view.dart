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

import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/data/services/configuration_service.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/domain/use_cases/check_file_changes_use_case.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_bloc.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_event.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_state.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_bloc.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_state.dart';
import 'package:quizdy/presentation/screens/dialogs/custom_confirm_dialog.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_index_chunk_card.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_index_hero_card.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_index_sections_header.dart';
import 'package:quizdy/presentation/widgets/quizdy_empty_state.dart';

class StudyIndexView extends StatelessWidget {
  final StudyExecutionState state;
  final AppLocalizations localizations;
  final VoidCallback? onAddChunk;
  final VoidCallback? onSave;
  final VoidCallback? onImport;
  final QuizFile? quizFile;

  /// Called with the chunk index when the user taps the edit (pencil) button
  /// on a chunk card while in edit mode. `null` when not in edit mode.
  final void Function(int chunkIndex)? onChunkEditTap;

  const StudyIndexView({
    super.key,
    required this.state,
    required this.localizations,
    this.onAddChunk,
    this.onSave,
    this.onImport,
    this.onChunkEditTap,
    this.quizFile,
  });

  Future<void> _onChunkTap(BuildContext context, int index) async {
    final targetChunk = state.chunks[index];
    if (targetChunk.status != StudyChunkState.completed &&
        targetChunk.status != StudyChunkState.downloaded) {
      final isAiAvailable = await ServiceLocator.getIt<ConfigurationService>()
          .getIsAiAvailable();
      if (!isAiAvailable) {
        if (context.mounted) {
          context.presentSnackBar(
            AppLocalizations.of(context)!.aiApiKeyRequired,
          );
        }
        return;
      }
    }
    if (context.mounted) {
      context.read<StudyExecutionBloc>().add(StudyChunkRequested(index));
    }
  }

  Future<void> _onChunkDownload(BuildContext context, int index) async {
    final isAiAvailable = await ServiceLocator.getIt<ConfigurationService>()
        .getIsAiAvailable();

    if (!isAiAvailable) {
      if (context.mounted) {
        context.presentSnackBar(AppLocalizations.of(context)!.aiApiKeyRequired);
      }
      return;
    }

    if (context.mounted) {
      context.read<StudyExecutionBloc>().add(
        DownloadStudyChunkRequested(index),
      );
    }
  }

  Future<void> _onChunkDelete(BuildContext context, int index) async {
    final chunk = state.chunks[index];

    // Check if the section has associated questions
    bool hasQuestions = false;
    try {
      final fileState = context.read<FileBloc>().state;
      QuizFile? quizFile;
      if (fileState is FileLoaded) {
        quizFile = fileState.quizFile;
      } else if (fileState is FileSaved) {
        quizFile = fileState.quizFile;
      }
      if (quizFile != null) {
        hasQuestions = quizFile.questions.any(
          (q) => q.studySectionId == chunk.id,
        );
      }
    } catch (_) {}

    final appLocalizations = AppLocalizations.of(context)!;
    final message = hasQuestions
        ? appLocalizations.confirmDeleteSectionWithQuestionsMessage(chunk.title)
        : appLocalizations.confirmDeleteMessage(chunk.title);

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => CustomConfirmDialog(
            title: appLocalizations.confirmDeleteTitle,
            message: message,
            confirmText: appLocalizations.deleteButton,
            isDestructive: true,
          ),
        ) ??
        false;

    if (confirmed && context.mounted) {
      context.read<StudyExecutionBloc>().add(
        DeleteChunkAtIndexRequested(index),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final duplicateChunkCounts = _buildChunkDuplicateCounts(state.chunks);

    final fileState = context.watch<FileBloc>().state;
    QuizFile? resolvedQuizFile = quizFile;
    if (resolvedQuizFile == null) {
      if (fileState is FileLoaded) {
        resolvedQuizFile = fileState.quizFile;
      } else if (fileState is FileSaved) {
        resolvedQuizFile = fileState.quizFile;
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          if (isWide) {
            return _buildDesktopLayout(
              context,
              duplicateChunkCounts,
              resolvedQuizFile,
            );
          }
          return _buildMobileLayout(
            context,
            duplicateChunkCounts,
            resolvedQuizFile,
          );
        },
      ),
    );
  }

  Map<String, int> _buildChunkDuplicateCounts(List<StudyChunk> chunks) {
    final counts = <String, int>{};
    for (final chunk in chunks) {
      final key = chunk.duplicationKey;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  bool _isChunkDuplicated(StudyChunk chunk, Map<String, int> counts) {
    return (counts[chunk.duplicationKey] ?? 0) > 1;
  }

  Widget _buildMobileLayout(
    BuildContext context,
    Map<String, int> duplicateChunkCounts,
    QuizFile? quizFile,
  ) {
    if (state.isSelectionMode) {
      return ReorderableListView.builder(
        padding: const EdgeInsets.all(20),
        buildDefaultDragHandles: false,
        itemCount: state.chunks.length,
        header: Column(
          children: [
            StudyIndexHeroCard(
              state: state,
              localizations: localizations,
              quizFile: quizFile,
            ),
            const SizedBox(height: 24),
            StudyIndexSectionsHeader(
              chunksCount: state.chunks.length,
              localizations: localizations,
            ),
            const SizedBox(height: 12),
          ],
        ),
        itemBuilder: (context, index) {
          final chunk = state.chunks[index];
          final isSelected = state.selectedIndices.contains(index);
          return Padding(
            key: ValueKey('chunk_${chunk.chunkIndex}'),
            padding: const EdgeInsets.only(bottom: 10),
            child: StudyIndexChunkCard(
              chunk: chunk,
              index: index,
              total: state.chunks.length,
              localizations: localizations,
              isSelectionMode: state.isSelectionMode,
              isSelected: isSelected,
              supportsReordering: true,
              isNew: ServiceLocator.getIt<CheckFileChangesUseCase>()
                  .isStudyChunkNew(index, chunk),
              isModified: ServiceLocator.getIt<CheckFileChangesUseCase>()
                  .isStudyChunkModified(index, chunk),
              isDuplicated: _isChunkDuplicated(chunk, duplicateChunkCounts),
              quizFile: quizFile,
              onTap: () {
                if (state.isSelectionMode) {
                  context.read<StudyExecutionBloc>().add(
                    ToggleChunkSelection(index),
                  );
                } else {
                  _onChunkTap(context, index);
                }
              },
              onDownload: () => _onChunkDownload(context, index),
              onEdit: onChunkEditTap != null
                  ? () => onChunkEditTap!(index)
                  : null,
              onDelete: () => _onChunkDelete(context, index),
              onLongPress: () {
                context.read<StudyExecutionBloc>().add(
                  ToggleChunkSelection(index),
                );
              },
            ),
          );
        },
        onReorder: (oldIndex, newIndex) {
          context.read<StudyExecutionBloc>().add(
            ReorderStudyChunks(oldIndex, newIndex),
          );
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        StudyIndexHeroCard(
          state: state,
          localizations: localizations,
          quizFile: quizFile,
        ),
        const SizedBox(height: 24),
        StudyIndexSectionsHeader(
          chunksCount: state.chunks.length,
          localizations: localizations,
        ),
        const SizedBox(height: 12),
        if (state.chunks.isEmpty)
          QuizdyEmptyState(message: localizations.studyScreenNoSlidesAvailable)
        else
          ...List.generate(state.chunks.length, (index) {
            final chunk = state.chunks[index];
            final isSelected = state.selectedIndices.contains(index);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: StudyIndexChunkCard(
                chunk: chunk,
                index: index,
                total: state.chunks.length,
                localizations: localizations,
                isSelectionMode: state.isSelectionMode,
                isSelected: isSelected,
                supportsReordering: false,
                isNew: ServiceLocator.getIt<CheckFileChangesUseCase>()
                    .isStudyChunkNew(index, chunk),
                isModified: ServiceLocator.getIt<CheckFileChangesUseCase>()
                    .isStudyChunkModified(index, chunk),
                isDuplicated: _isChunkDuplicated(chunk, duplicateChunkCounts),
                quizFile: quizFile,
                onTap: () {
                  if (state.isSelectionMode) {
                    context.read<StudyExecutionBloc>().add(
                      ToggleChunkSelection(index),
                    );
                  } else {
                    _onChunkTap(context, index);
                  }
                },
                onDownload: () => _onChunkDownload(context, index),
                onEdit: onChunkEditTap != null
                    ? () => onChunkEditTap!(index)
                    : null,
                onDelete: () => _onChunkDelete(context, index),
                onLongPress: () {
                  context.read<StudyExecutionBloc>().add(
                    ToggleChunkSelection(index),
                  );
                },
              ),
            );
          }),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    Map<String, int> duplicateChunkCounts,
    QuizFile? quizFile,
  ) {
    if (state.isSelectionMode) {
      // Use single column ReorderableListView even on desktop for functional reordering
      return _buildMobileLayout(context, duplicateChunkCounts, quizFile);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Hero card (fixed width)
        SizedBox(
          width: 420,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              StudyIndexHeroCard(
                state: state,
                localizations: localizations,
                quizFile: quizFile,
              ),
            ],
          ),
        ),
        // Right: Sections header + 2-column grid of chunk cards
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
            children: [
              StudyIndexSectionsHeader(
                chunksCount: state.chunks.length,
                localizations: localizations,
              ),
              const SizedBox(height: 16),
              if (state.chunks.isEmpty)
                QuizdyEmptyState(
                  message: localizations.studyScreenNoSlidesAvailable,
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column (even indices: 0, 2, 4...)
                    Expanded(
                      child: Column(
                        children: [
                          for (int i = 0; i < state.chunks.length; i += 2)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: StudyIndexChunkCard(
                                chunk: state.chunks[i],
                                index: i,
                                total: state.chunks.length,
                                localizations: localizations,
                                isSelectionMode: state.isSelectionMode,
                                isSelected: state.selectedIndices.contains(i),
                                supportsReordering: true,
                                isNew:
                                    ServiceLocator.getIt<
                                          CheckFileChangesUseCase
                                        >()
                                        .isStudyChunkNew(i, state.chunks[i]),
                                isModified:
                                    ServiceLocator.getIt<
                                          CheckFileChangesUseCase
                                        >()
                                        .isStudyChunkModified(
                                          i,
                                          state.chunks[i],
                                        ),
                                isDuplicated: _isChunkDuplicated(
                                  state.chunks[i],
                                  duplicateChunkCounts,
                                ),
                                quizFile: quizFile,
                                onTap: () {
                                  if (state.isSelectionMode) {
                                    context.read<StudyExecutionBloc>().add(
                                      ToggleChunkSelection(i),
                                    );
                                  } else {
                                    _onChunkTap(context, i);
                                  }
                                },
                                onDownload: () => _onChunkDownload(context, i),
                                onEdit: onChunkEditTap != null
                                    ? () => onChunkEditTap!(i)
                                    : null,
                                onDelete: () => _onChunkDelete(context, i),
                                onLongPress: () {
                                  context.read<StudyExecutionBloc>().add(
                                    ToggleChunkSelection(i),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right column (odd indices: 1, 3, 5...)
                    Expanded(
                      child: Column(
                        children: [
                          for (int i = 1; i < state.chunks.length; i += 2)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: StudyIndexChunkCard(
                                chunk: state.chunks[i],
                                index: i,
                                total: state.chunks.length,
                                localizations: localizations,
                                isSelectionMode: state.isSelectionMode,
                                isSelected: state.selectedIndices.contains(i),
                                supportsReordering:
                                    false, // Desktop doesn't support reorder yet
                                isNew:
                                    ServiceLocator.getIt<
                                          CheckFileChangesUseCase
                                        >()
                                        .isStudyChunkNew(i, state.chunks[i]),
                                isModified:
                                    ServiceLocator.getIt<
                                          CheckFileChangesUseCase
                                        >()
                                        .isStudyChunkModified(
                                          i,
                                          state.chunks[i],
                                        ),
                                isDuplicated: _isChunkDuplicated(
                                  state.chunks[i],
                                  duplicateChunkCounts,
                                ),
                                quizFile: quizFile,
                                onTap: () {
                                  if (state.isSelectionMode) {
                                    context.read<StudyExecutionBloc>().add(
                                      ToggleChunkSelection(i),
                                    );
                                  } else {
                                    _onChunkTap(context, i);
                                  }
                                },
                                onDownload: () => _onChunkDownload(context, i),
                                onEdit: onChunkEditTap != null
                                    ? () => onChunkEditTap!(i)
                                    : null,
                                onDelete: () => _onChunkDelete(context, i),
                                onLongPress: () {
                                  context.read<StudyExecutionBloc>().add(
                                    ToggleChunkSelection(i),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
