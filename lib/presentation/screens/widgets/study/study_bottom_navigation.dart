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
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/domain/models/ai/ai_generation_mode.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/domain/use_cases/check_file_changes_use_case.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_bloc.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_state.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_bloc.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_event.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_state.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_execution_bottom_bar.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_index_footer_widget.dart';
import 'package:quizdy/presentation/screens/widgets/study/utils/study_quiz_file_helper.dart';
import 'package:quizdy/routes/app_router.dart';

class StudyBottomNavigation extends StatelessWidget {
  final QuizFile? quizFile;
  final AiGenerationMode? generationMode;
  final String? originalText;
  final VoidCallback onSave;
  final VoidCallback onImport;
  final VoidCallback onAddChunk;
  final VoidCallback onGenerateAI;

  const StudyBottomNavigation({
    super.key,
    this.quizFile,
    this.generationMode,
    this.originalText,
    required this.onSave,
    required this.onImport,
    required this.onAddChunk,
    required this.onGenerateAI,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocBuilder<FileBloc, FileState>(
      builder: (context, fileState) {
        return BlocBuilder<StudyExecutionBloc, StudyExecutionState>(
          builder: (context, state) {
            return AbsorbPointer(
              absorbing: state.isLoading,
              child: () {
                if (state.isIndexMode) {
                  final currentQuizFile = StudyQuizFileHelper.getCurrentQuizFile(
                    studyState: state,
                    fileState: fileState,
                    initialQuizFile: quizFile,
                    generationMode: generationMode,
                    originalText: originalText,
                  );
                  final hasChanges = ServiceLocator.getIt<CheckFileChangesUseCase>()
                      .execute(currentQuizFile);

                  return StudyIndexFooterWidget(
                    localizations: localizations,
                    progressPercentage: state.progressPercentage,
                    hasChunks: state.chunks.isNotEmpty,
                    selectedChunkCount: state.selectedIndices.length,
                    isStartQuizEnabled: state.chunks.isNotEmpty,
                    onDelete: () {
                      context.read<StudyExecutionBloc>().add(
                        const DeleteSelectedChunksRequested(),
                      );
                    },
                    onStartQuiz: () {
                      context.go(AppRoutes.fileLoadedScreen);
                    },
                    onAddChunk: onAddChunk,
                    onGenerateAI: onGenerateAI,
                    onImport: onImport,
                    onSave: onSave,
                    showSaveButton: hasChanges,
                  );
                }

                return StudyExecutionBottomBar(
                  currentIndex: state.currentChunkIndex,
                  totalCount: state.chunks.length,
                  progressPercentage: state.progressPercentage,
                  localizations: localizations,
                  onPrevious: state.hasPrevious
                      ? () => context.read<StudyExecutionBloc>().add(
                          const PreviousStudyChunkRequested(),
                        )
                      : null,
                  onNext: state.hasNext
                      ? () => context.read<StudyExecutionBloc>().add(
                          const NextStudyChunkRequested(),
                        )
                      : null,
                );
              }(),
            );
          },
        );
      },
    );
  }
}
