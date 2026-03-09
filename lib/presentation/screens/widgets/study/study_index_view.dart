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
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_bloc.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_event.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_state.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_index_chunk_card.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_index_hero_card.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_index_sections_header.dart';

class StudyIndexView extends StatelessWidget {
  final StudyExecutionState state;
  final AppLocalizations localizations;
  final VoidCallback? onAddChunk;
  final VoidCallback? onSave;
  final VoidCallback? onImport;

  const StudyIndexView({
    super.key,
    required this.state,
    required this.localizations,
    this.onAddChunk,
    this.onSave,
    this.onImport,
  });

  void _onChunkTap(BuildContext context, int index) {
    context.read<StudyExecutionBloc>().add(StudyChunkRequested(index));
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;
          if (isWide) {
            return _buildDesktopLayout(context);
          }
          return _buildMobileLayout(context);
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    if (state.isSelectionMode) {
      return ReorderableListView.builder(
        padding: const EdgeInsets.all(20),
        buildDefaultDragHandles: false,
        itemCount: state.chunks.length,
        header: Column(
          children: [
            StudyIndexHeroCard(state: state, localizations: localizations),
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
        StudyIndexHeroCard(state: state, localizations: localizations),
        const SizedBox(height: 24),
        StudyIndexSectionsHeader(
          chunksCount: state.chunks.length,
          localizations: localizations,
        ),
        const SizedBox(height: 12),
        if (state.chunks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 64,
                    color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.studyScreenNoSlidesAvailable,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
          )
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
                supportsReordering: false, // In standard ListView branch
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

  Widget _buildDesktopLayout(BuildContext context) {
    if (state.isSelectionMode) {
      // Use single column ReorderableListView even on desktop for functional reordering
      return _buildMobileLayout(context);
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
              StudyIndexHeroCard(state: state, localizations: localizations),
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 64),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.library_books_outlined,
                          size: 80,
                          color: Theme.of(
                            context,
                          ).hintColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          localizations.studyScreenNoSlidesAvailable,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: Theme.of(context).hintColor),
                        ),
                      ],
                    ),
                  ),
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
                                supportsReordering:
                                    false, // Desktop doesn't support reorder yet
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
