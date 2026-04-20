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

class StudyContentView extends StatelessWidget {
  final StudyChunk currentChunk;
  final int currentChunkIndex;
  final AppLocalizations localizations;

  const StudyContentView({
    super.key,
    required this.currentChunk,
    required this.currentChunkIndex,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        children: [
          Expanded(
            child: currentChunk.status == StudyChunkState.error
                ? const SizedBox.shrink()
                : (currentChunk.pages.isNotEmpty
                      ? ListView.builder(
                          key: ValueKey(currentChunkIndex),
                          itemCount: currentChunk.pages.length,
                          itemBuilder: (context, index) {
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
