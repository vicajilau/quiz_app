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
import 'package:quizdy/core/theme/extensions/quiz_loaded_theme.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';

class QuizLoadedDragOverlay extends StatelessWidget {
  const QuizLoadedDragOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: context.quizLoadedTheme.dragOverlayColor,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: context.quizLoadedTheme.dragOverlayBorderColor,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.quizLoadedTheme.dragOverlayShadowColor,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.upload,
                  size: 48,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.dropFileHere,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuizLoadedStudyModeButton extends StatelessWidget {
  final QuizFile quizFile;
  final VoidCallback onTap;

  const QuizLoadedStudyModeButton({
    super.key,
    required this.quizFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: AppLocalizations.of(context)!.studyModeLabel,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        constraints: const BoxConstraints(minWidth: 40),
        child: Material(
          color: context.quizLoadedTheme.appBarIconBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Builder(
                builder: (context) {
                  final showText = MediaQuery.of(context).size.width > 500;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.bookOpen,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 18,
                      ),
                      if (showText) ...[
                        const SizedBox(width: 6),
                        Text(
                          AppLocalizations.of(context)!.studyModeLabel,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuizLoadedSettingsButton extends StatelessWidget {
  final VoidCallback onTap;

  const QuizLoadedSettingsButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: context.quizLoadedTheme.appBarIconBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        icon: Icon(
          LucideIcons.settings,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 20,
        ),
        tooltip: AppLocalizations.of(context)!.settingsTitle,
      ),
    );
  }
}

class QuizLoadedSelectionToggleButton extends StatelessWidget {
  final bool isSelectionMode;
  final VoidCallback onTap;

  const QuizLoadedSelectionToggleButton({
    super.key,
    required this.isSelectionMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 24),
      constraints: const BoxConstraints(minWidth: 40),
      child: Tooltip(
        message: isSelectionMode
            ? AppLocalizations.of(context)!.done
            : AppLocalizations.of(context)!.select,
        child: Material(
          color: context.quizLoadedTheme.selectionInactiveBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Builder(
                builder: (context) {
                  final showText = MediaQuery.of(context).size.width > 500;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelectionMode
                            ? LucideIcons.checkSquare
                            : LucideIcons.mousePointer2,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 18,
                      ),
                      if (showText) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            isSelectionMode
                                ? AppLocalizations.of(context)!.done
                                : AppLocalizations.of(context)!.select,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
