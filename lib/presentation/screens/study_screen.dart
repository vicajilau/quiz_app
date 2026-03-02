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
import 'package:quizdy/data/services/ai/ai_jit_processing_service.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/domain/models/ai/ai_file_attachment.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_bloc.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_event.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_bloc.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_event.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_state.dart';

class StudyScreen extends StatelessWidget {
  final List<StudyChunk> initialChunks;
  final AiFileAttachment? fileAttachment;
  final String documentTitle;
  final QuizFile? quizFile;

  const StudyScreen({
    super.key,
    required this.initialChunks,
    this.fileAttachment,
    required this.documentTitle,
    this.quizFile,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => StudyExecutionBloc(
        jitProcessingService: AiJitProcessingService.instance,
        localizations: localizations,
        initialChunks: initialChunks,
        fileAttachment: fileAttachment ?? quizFile?.fileAttachment,
        documentTitle: documentTitle,
        onProgressChanged: (progress, processedChunks, chunks) {
          context.read<FileBloc>().add(
            StudyProgressUpdated(
              progress: progress,
              processedChunks: processedChunks,
              chunks: chunks,
            ),
          );
        },
      ),
      child: const StudyScreenView(),
    );
  }
}

class StudyScreenView extends StatelessWidget {
  const StudyScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<StudyExecutionBloc, StudyExecutionState>(
          builder: (context, state) {
            return Text(state.documentTitle);
          },
        ),
        leading: BlocBuilder<StudyExecutionBloc, StudyExecutionState>(
          builder: (context, state) {
            if (!state.isIndexMode) {
              return IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.read<StudyExecutionBloc>().add(
                    ReturnToIndexRequested(),
                  );
                },
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              );
            }
            return const BackButton(); // Default navigator back to leave screen
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6.0),
          child: BlocBuilder<StudyExecutionBloc, StudyExecutionState>(
            buildWhen: (previous, current) =>
                previous.progressPercentage != current.progressPercentage,
            builder: (context, state) {
              return Tooltip(
                message: '${state.progressPercentage.toStringAsFixed(1)}%',
                child: LinearProgressIndicator(
                  value: state.progressPercentage / 100,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                  minHeight: 6,
                ),
              );
            },
          ),
        ),
      ),
      body: BlocListener<StudyExecutionBloc, StudyExecutionState>(
        listenWhen: (previous, current) {
          final currentChunk = current.currentChunk;
          final previousChunk = previous.currentChunk;
          return currentChunk?.status == StudyChunkState.error &&
              previousChunk?.status != StudyChunkState.error;
        },
        listener: (context, state) {
          final currentChunk = state.currentChunk;
          if (currentChunk == null) return;

          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(localizations.studyScreenError),
              content: Text(
                currentChunk.errorMessage ?? localizations.studyScreenError,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    MaterialLocalizations.of(context).closeButtonLabel,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.read<StudyExecutionBloc>().add(
                      StudyChunkRequested(state.currentChunkIndex),
                    );
                  },
                  child: Text(localizations.studyScreenRetry),
                ),
              ],
            ),
          );
        },
        child: BlocBuilder<StudyExecutionBloc, StudyExecutionState>(
          builder: (context, state) {
            if (state.chunks.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.isIndexMode) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.chunks.length,
                itemBuilder: (context, index) {
                  final chunk = state.chunks[index];
                  // If it's the full document fallback, just show standard title
                  final title = chunk.title;
                  return Card(
                    child: ListTile(
                      title: Text(title),
                      subtitle: Text(
                        localizations.studyScreenSectionIndicator(index + 1, state.chunks.length),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        context.read<StudyExecutionBloc>().add(
                          StudyChunkRequested(index),
                        );
                      },
                    ),
                  );
                },
              );
            }

            final currentChunk = state.currentChunk;
            if (currentChunk == null) {
              return Center(
                child: Text(localizations.studyScreenNoSlidesAvailable),
              );
            }

            if (currentChunk.status == StudyChunkState.processing) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(localizations.studyScreenGenerating),
                  ],
                ),
              );
            }

            return Row(
              children: [
                // 1. Sidebar (Index)
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    child: ListView.builder(
                      itemCount: state.chunks.length,
                      itemBuilder: (context, index) {
                        final chunk = state.chunks[index];
                        final isSelected = index == state.currentChunkIndex;
                        return ListTile(
                          title: Text(
                            chunk.title,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                          ),
                          selected: isSelected,
                          onTap: () {
                            context.read<StudyExecutionBloc>().add(
                              StudyChunkRequested(index),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                // 2. Main Content
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: currentChunk.status == StudyChunkState.error
                              ? const SizedBox.shrink()
                              : (currentChunk.slides != null &&
                                        currentChunk.slides!.isNotEmpty
                                    ? ListView.builder(
                                        itemCount: currentChunk.slides!.length,
                                        itemBuilder: (context, index) {
                                          final slide =
                                              currentChunk.slides![index];
                                          return Card(
                                            margin: const EdgeInsets.only(
                                              bottom: 16,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: slide.uiElements.map((
                                                  element,
                                                ) {
                                                  final text =
                                                      element.props['text']
                                                          ?.toString() ??
                                                      '';
                                                  if (element.componentType ==
                                                      'Title') {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            bottom: 8.0,
                                                          ),
                                                      child: Text(
                                                        text,
                                                        style: Theme.of(
                                                          context,
                                                        ).textTheme.titleLarge,
                                                      ),
                                                    );
                                                  }
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          bottom: 8.0,
                                                        ),
                                                    child: Text(text),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Center(
                                        child: Text(
                                          localizations
                                              .studyScreenNoSlidesGenerated,
                                        ),
                                      )),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: state.hasPrevious
                                  ? () => context
                                        .read<StudyExecutionBloc>()
                                        .add(PreviousStudyChunkRequested())
                                  : null,
                              child: Text(
                                localizations.studyScreenPreviousSection,
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  localizations.studyScreenSectionIndicator(
                                    state.currentChunkIndex + 1,
                                    state.chunks.length,
                                  ),
                                ),
                                Text(
                                  '${state.progressPercentage.toStringAsFixed(0)}% ${localizations.studyScreenCoverage}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: state.hasNext
                                  ? () => context
                                        .read<StudyExecutionBloc>()
                                        .add(NextStudyChunkRequested())
                                  : null,
                              child: Text(localizations.studyScreenNextSection),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // 3. AI Summary Panel
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.studyScreenAiSummaryTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              currentChunk.aiSummary ??
                                  localizations.studyScreenNoSummary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
