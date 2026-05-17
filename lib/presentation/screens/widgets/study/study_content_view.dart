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
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/presentation/screens/widgets/study/components/study_component_builder.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/domain/models/quiz/quiz_config.dart';
import 'package:quizdy/domain/models/quiz/question.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/routes/app_router.dart';
import 'package:go_router/go_router.dart';

class StudyContentView extends StatelessWidget {
  final StudyChunk currentChunk;
  final int currentChunkIndex;
  final AppLocalizations localizations;
  final QuizFile? quizFile;

  const StudyContentView({
    super.key,
    required this.currentChunk,
    required this.currentChunkIndex,
    required this.localizations,
    this.quizFile,
  });

  @override
  Widget build(BuildContext context) {
    final List<Question> enabledLinkedQuestions = quizFile != null
        ? quizFile!.questions
              .where((q) => q.isEnabled && q.studySectionId == currentChunk.id)
              .toList()
        : const [];
    final hasLinkedQuestions = enabledLinkedQuestions.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        children: [
          Expanded(
            child: currentChunk.status == StudyChunkState.error
                ? const SizedBox.shrink()
                : (currentChunk.pages.isNotEmpty || hasLinkedQuestions
                      ? ListView.builder(
                          key: ValueKey(currentChunkIndex),
                          itemCount:
                              currentChunk.pages.length +
                              (hasLinkedQuestions ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == currentChunk.pages.length) {
                              return _buildPracticeBanner(
                                context,
                                enabledLinkedQuestions,
                              );
                            }
                            final page = currentChunk.pages[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: page.uiElements.map((element) {
                                    return StudyComponentBuilder(
                                      element: element,
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            localizations.studyScreenNoSlidesGenerated,
                          ),
                        )),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeBanner(
    BuildContext context,
    List<Question> linkedQuestions,
  ) {
    if (quizFile == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.zinc800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.zinc700 : AppTheme.zinc200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.graduationCap,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.studySectionPracticePrompt,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizations.studySectionPracticeSubtitle(
                        linkedQuestions.length,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppTheme.zinc400 : AppTheme.zinc500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          QuizdyButton(
            title: localizations.startQuizFromStudy,
            icon: LucideIcons.play,
            expanded: true,
            onPressed: () {
              final sectionQuizFile = quizFile!.copyWith(
                questions: linkedQuestions,
              );
              ServiceLocator.registerQuizFile(sectionQuizFile);
              ServiceLocator.registerQuizConfig(
                QuizConfig(
                  questionCount: linkedQuestions.length,
                  isStudyMode: false,
                ),
              );
              context.push(AppRoutes.quizFileExecutionScreen);
            },
          ),
        ],
      ),
    );
  }
}

class StudyLoadingOverlay extends StatelessWidget {
  const StudyLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.1),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class StudyNoChunkAvailable extends StatelessWidget {
  final AppLocalizations localizations;

  const StudyNoChunkAvailable({super.key, required this.localizations});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(localizations.studyScreenNoSlidesAvailable));
  }
}

class StudyGeneratingContent extends StatelessWidget {
  final AppLocalizations localizations;

  const StudyGeneratingContent({super.key, required this.localizations});

  @override
  Widget build(BuildContext context) {
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
}

class SidebarOpenButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const SidebarOpenButton({
    super.key,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.zinc700 : AppTheme.zinc100,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Icon(
          LucideIcons.panelRightClose,
          size: 18,
          color: isDark ? AppTheme.zinc400 : AppTheme.zinc500,
        ),
      ),
    );
  }
}

class AskAiButton extends StatelessWidget {
  final bool isDark;
  final bool isAiAvailable;
  final String tooltip;
  final VoidCallback onTap;

  const AskAiButton({
    super.key,
    required this.isDark,
    required this.isAiAvailable,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.zinc700 : AppTheme.zinc100,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Icon(
            LucideIcons.sparkles,
            size: 18,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
