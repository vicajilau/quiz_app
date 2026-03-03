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
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_bloc.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_event.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_state.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_index_chunk_card.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_index_hero_card.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_index_sections_header.dart';

class StudyIndexView extends StatelessWidget {
  final StudyExecutionState state;
  final AppLocalizations localizations;

  const StudyIndexView({
    super.key,
    required this.state,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 800;
        if (isWide) {
          return _buildDesktopLayout(context);
        }
        return _buildMobileLayout(context);
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
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
        ...List.generate(state.chunks.length, (index) {
          final chunk = state.chunks[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: StudyIndexChunkCard(
              chunk: chunk,
              index: index,
              total: state.chunks.length,
              localizations: localizations,
              onTap: () {
                context.read<StudyExecutionBloc>().add(
                  StudyChunkRequested(index),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
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
                              onTap: () {
                                context.read<StudyExecutionBloc>().add(
                                  StudyChunkRequested(i),
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
                              onTap: () {
                                context.read<StudyExecutionBloc>().add(
                                  StudyChunkRequested(i),
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
