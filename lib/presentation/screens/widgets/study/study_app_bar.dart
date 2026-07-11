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
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/extensions/home_theme.dart';
import 'package:quizdy/core/theme/extensions/quiz_loaded_theme.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_bloc.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_event.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_bloc.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_event.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_state.dart';
import 'package:quizdy/presentation/screens/widgets/common/quizdy_app_bar.dart';

class StudyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Future<bool> Function() onConfirmExit;
  final VoidCallback? onExit;
  final VoidCallback onEditCurrentChunk;
  final VoidCallback? onRegenerateCurrentChunk;
  final bool showLeading;

  const StudyAppBar({
    super.key,
    required this.onConfirmExit,
    this.onExit,
    required this.onEditCurrentChunk,
    this.onRegenerateCurrentChunk,
    this.showLeading = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return QuizdyAppBar(
      showLeading: showLeading,
      leading: Center(
        child: BlocBuilder<StudyExecutionBloc, StudyExecutionState>(
          builder: (context, state) {
            return AbsorbPointer(
              absorbing: state.isLoading,
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: context.quizLoadedTheme.appBarIconBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    state.isIndexMode ? Icons.close : LucideIcons.arrow_left,
                    color: context.homeTheme.textPrimaryColor,
                    size: 20,
                  ),
                  onPressed: () async {
                    if (state.isSelectionMode) {
                      context.read<StudyExecutionBloc>().add(
                        const ClearSelectionRequested(),
                      );
                      return;
                    }
                    if (!state.isIndexMode) {
                      context.read<StudyExecutionBloc>().add(
                        const ReturnToIndexRequested(),
                      );
                      return;
                    }
                    final shouldExit = await onConfirmExit();
                    if (shouldExit && context.mounted) {
                      context.read<FileBloc>().add(QuizFileReset());
                      if (onExit != null) {
                        onExit!();
                      } else {
                        context.pop();
                      }
                    }
                  },
                  tooltip: AppLocalizations.of(context)!.close,
                ),
              ),
            );
          },
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                BlocBuilder<StudyExecutionBloc, StudyExecutionState>(
                  builder: (context, state) {
                    return Text(
                      state.documentTitle,
                      style: TextStyle(
                        color: context.homeTheme.textPrimaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        BlocBuilder<StudyExecutionBloc, StudyExecutionState>(
          builder: (context, state) {
            return AbsorbPointer(
              absorbing: state.isLoading,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit Button (only when viewing a specific chunk)
                  if (!state.isIndexMode)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      constraints: const BoxConstraints(minWidth: 40),
                      child: Tooltip(
                        message: localizations.edit,
                        child: Material(
                          color: context
                              .quizLoadedTheme
                              .selectionInactiveBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: onEditCurrentChunk,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Builder(
                                builder: (context) {
                                  final showText =
                                      MediaQuery.of(context).size.width > 500;
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        LucideIcons.pencil,
                                        color:
                                            context.homeTheme.textPrimaryColor,
                                        size: 18,
                                      ),
                                      if (showText) ...[
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            localizations.edit,
                                            style: TextStyle(
                                              color: context
                                                  .homeTheme
                                                  .textPrimaryColor,
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
                    ),
                  if (!state.isIndexMode && onRegenerateCurrentChunk != null)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      constraints: const BoxConstraints(minWidth: 40),
                      child: Tooltip(
                        message: localizations.regenerate,
                        child: Material(
                          color: context
                              .quizLoadedTheme
                              .selectionInactiveBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: onRegenerateCurrentChunk,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Builder(
                                builder: (context) {
                                  final showText =
                                      MediaQuery.of(context).size.width > 500;
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        LucideIcons.refresh_cw,
                                        color:
                                            context.homeTheme.textPrimaryColor,
                                        size: 18,
                                      ),
                                      if (showText) ...[
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            localizations.regenerate,
                                            style: TextStyle(
                                              color: context
                                                  .homeTheme
                                                  .textPrimaryColor,
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
                    ),
                  // Selection Mode Toggle Button
                  if (state.isIndexMode)
                    Container(
                      margin: const EdgeInsets.only(right: 24),
                      constraints: const BoxConstraints(minWidth: 40),
                      child: Tooltip(
                        message: state.isSelectionMode
                            ? localizations.done
                            : localizations.select,
                        child: Material(
                          color: context
                              .quizLoadedTheme
                              .selectionInactiveBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              context.read<StudyExecutionBloc>().add(
                                const ToggleStudySelectionMode(),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Builder(
                                builder: (context) {
                                  final showText =
                                      MediaQuery.of(context).size.width > 500;

                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        state.isSelectionMode
                                            ? LucideIcons.square_check
                                            : LucideIcons.mouse_pointer_2,
                                        color:
                                            context.homeTheme.textPrimaryColor,
                                        size: 18,
                                      ),
                                      if (showText) ...[
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            state.isSelectionMode
                                                ? localizations.done
                                                : localizations.select,
                                            style: TextStyle(
                                              color: context
                                                  .homeTheme
                                                  .textPrimaryColor,
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
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
