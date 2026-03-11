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
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/data/services/configuration_service.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_bloc.dart';
import 'package:quizdy/presentation/blocs/file_bloc/file_state.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_bloc.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_event.dart';
import 'package:quizdy/presentation/blocs/study_execution_bloc/study_execution_state.dart';
import 'package:quizdy/presentation/screens/quiz_execution/widgets/ai_studio_chat_side_panel.dart';
import 'package:quizdy/presentation/screens/widgets/study/components/study_component_builder.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_index_view.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_sections_sidebar.dart';
import 'package:quizdy/presentation/screens/widgets/study/add_edit_chunk_dialog.dart';

class StudyBody extends StatefulWidget {
  final Future<void> Function(BuildContext) onHandleFileReattachment;
  final VoidCallback onSave;

  const StudyBody({
    super.key,
    required this.onHandleFileReattachment,
    required this.onSave,
  });

  @override
  State<StudyBody> createState() => _StudyBodyState();
}

class _StudyBodyState extends State<StudyBody>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _isSidebarOpen = true;
  bool _isSidebarMounted = true;

  bool _isChatOpen = false;
  bool _isChatMounted = false;
  bool _isAiAvailable = false;

  late final AnimationController _mobileSidebarAnimController;
  late final Animation<Offset> _mobileSidebarSlide;

  late final AnimationController _mobileChatAnimController;
  late final Animation<Offset> _mobileChatSlide;

  final GlobalKey<AiStudioChatSidePanelState> _chatPanelKey =
      GlobalKey<AiStudioChatSidePanelState>();

  @override
  void initState() {
    super.initState();
    _mobileSidebarAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _mobileSidebarSlide =
        Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mobileSidebarAnimController,
            curve: Curves.linear,
          ),
        );

    _mobileChatAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _mobileChatSlide =
        Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mobileChatAnimController,
            curve: Curves.linear,
          ),
        );

    _checkAiAvailability();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAiAvailability();
    }
  }

  Future<void> _checkAiAvailability() async {
    final isAvailable = await ServiceLocator.getIt<ConfigurationService>()
        .getIsAiAvailable();
    if (mounted) {
      setState(() => _isAiAvailable = isAvailable);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mobileSidebarAnimController.dispose();
    _mobileChatAnimController.dispose();
    super.dispose();
  }

  void _openSidebar() {
    setState(() {
      _isSidebarOpen = true;
      _isSidebarMounted = true;
    });
    if (context.isMobile) {
      _mobileSidebarAnimController.forward();
    }
  }

  void _closeSidebar() {
    if (!context.isMobile) {
      setState(() => _isSidebarOpen = false);
    } else {
      _mobileSidebarAnimController.reverse().then((_) {
        if (mounted) setState(() => _isSidebarOpen = false);
      });
    }
  }

  Future<void> _openChat() async {
    // Re-check availability every time so stale state is never shown to the user.
    await _checkAiAvailability();
    if (!mounted) return;
    if (!_isAiAvailable) {
      context.presentSnackBar(AppLocalizations.of(context)!.aiApiKeyRequired);
      return;
    }
    setState(() {
      _isChatOpen = true;
      _isChatMounted = true;
    });
    if (context.isMobile) {
      _mobileChatAnimController.forward();
    }
  }

  void _closeChat() {
    if (!context.isMobile) {
      setState(() => _isChatOpen = false);
    } else {
      _mobileChatAnimController.reverse().then((_) {
        if (mounted) setState(() => _isChatOpen = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MultiBlocListener(
      listeners: [
        BlocListener<FileBloc, FileState>(
          listenWhen: (_, current) => current is FileSaved,
          listener: (context, _) {
            context.read<StudyExecutionBloc>().add(const StudyFileSaved());
          },
        ),
        BlocListener<StudyExecutionBloc, StudyExecutionState>(
          listenWhen: (previous, current) =>
              !previous.needsFileReattachment && current.needsFileReattachment,
          listener: (context, state) {
            widget.onHandleFileReattachment(context);
          },
        ),
        BlocListener<StudyExecutionBloc, StudyExecutionState>(
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
        ),
      ],
      child: Stack(
        children: [
          BlocBuilder<StudyExecutionBloc, StudyExecutionState>(
            builder: (context, state) {
              if (state.isLoading && state.chunks.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.isIndexMode) {
                return StudyIndexView(
                  state: state,
                  localizations: localizations,
                  onAddChunk: () async {
                    final result = await showDialog<Map<String, String>>(
                      context: context,
                      builder: (context) =>
                          AddEditChunkDialog(localizations: localizations),
                    );

                    if (result != null && context.mounted) {
                      context.read<StudyExecutionBloc>().add(
                        AddStudyChunkRequested(
                          title: result['title'] ?? '',
                          content: result['text'] ?? '',
                        ),
                      );
                    }
                  },
                  onSave: widget.onSave,
                  onImport: () => widget.onHandleFileReattachment(context),
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

              final isChunkReady =
                  currentChunk.status == StudyChunkState.completed ||
                  currentChunk.status == StudyChunkState.downloaded;

              // Chat panel — single instance, never rebuilt across layouts
              final chatPanel = isChunkReady
                  ? Padding(
                      padding: EdgeInsetsGeometry.only(
                        top: !context.isMobile
                            ? MediaQuery.of(context).padding.top -
                                  15 // In order to align the top of the chat panel
                            : 0,
                      ),
                      child: AiStudioChatSidePanel(
                        key: _chatPanelKey,
                        studyChunk: currentChunk,
                        allStudyChunks: state.chunks,
                        isFullScreen: context.isMobile,
                        onClose: _closeChat,
                      ),
                    )
                  : null;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = context.isMobile;

                  // Sync mobile animation state on resize
                  if (!isMobile && _isSidebarOpen) {
                    _mobileSidebarAnimController.value = 0.0;
                  } else if (isMobile && _isSidebarOpen) {
                    _mobileSidebarAnimController.value = 1.0;
                  }

                  if (!isMobile && _isChatOpen) {
                    _mobileChatAnimController.value = 0.0;
                  } else if (isMobile && _isChatOpen) {
                    _mobileChatAnimController.value = 1.0;
                  }

                  final sidebarPanel = StudySectionsSidebar(
                    chunks: state.chunks,
                    currentChunkIndex: state.currentChunkIndex,
                    localizations: localizations,
                    isFullScreen: isMobile,
                    onClose: _closeSidebar,
                    onChunkSelected: (index) {
                      context.read<StudyExecutionBloc>().add(
                        StudyChunkRequested(index),
                      );
                      if (isMobile) _closeSidebar();
                    },
                    onChunkDownload: (index) async {
                      final isAiAvailable =
                          await ServiceLocator.getIt<ConfigurationService>()
                              .getIsAiAvailable();
                      if (!isAiAvailable) {
                        if (context.mounted) {
                          context.presentSnackBar(
                            AppLocalizations.of(context)!.aiApiKeyRequired,
                          );
                        }
                        return;
                      }
                      if (context.mounted) {
                        context.read<StudyExecutionBloc>().add(
                          DownloadStudyChunkRequested(index),
                        );
                      }
                    },
                  );

                  final mainContent = Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Column(
                          children: [
                            Expanded(
                              child:
                                  currentChunk.status == StudyChunkState.error
                                  ? const SizedBox.shrink()
                                  : (currentChunk.pages.isNotEmpty
                                        ? ListView.builder(
                                            itemCount:
                                                currentChunk.pages.length,
                                            itemBuilder: (context, index) {
                                              final page =
                                                  currentChunk.pages[index];
                                              return Card(
                                                margin: const EdgeInsets.only(
                                                  bottom: 16,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: page.uiElements.map((
                                                      element,
                                                    ) {
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
                                              localizations
                                                  .studyScreenNoSlidesGenerated,
                                            ),
                                          )),
                            ),
                          ],
                        ),
                      ),
                      if (!_isSidebarOpen)
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 12,
                          left: 12,
                          child: _SidebarOpenButton(
                            isDark: isDark,
                            onTap: _openSidebar,
                          ),
                        ),
                      if (isChunkReady && !_isChatOpen)
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 12,
                          right: 12,
                          child: _AskAiButton(
                            isDark: isDark,
                            isAiAvailable: _isAiAvailable,
                            tooltip: localizations.askAIStudyTooltip,
                            onTap: _openChat,
                          ),
                        ),
                    ],
                  );

                  if (!isMobile) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.linear,
                          width: _isSidebarOpen ? 280 : 0,
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(),
                          child: OverflowBox(
                            alignment: Alignment.topRight,
                            minWidth: 280,
                            maxWidth: 280,
                            child: sidebarPanel,
                          ),
                        ),
                        Expanded(child: mainContent),
                        if (chatPanel != null)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.linear,
                            width: _isChatOpen ? 400 : 0,
                            clipBehavior: Clip.hardEdge,
                            decoration: const BoxDecoration(),
                            child: OverflowBox(
                              alignment: Alignment.topLeft,
                              minWidth: 400,
                              maxWidth: 400,
                              child: chatPanel,
                            ),
                          ),
                      ],
                    );
                  }

                  // Narrow layout: Stack with slide overlays
                  return Stack(
                    children: [
                      mainContent,
                      if (_isSidebarMounted)
                        Positioned.fill(
                          child: IgnorePointer(
                            ignoring: !_isSidebarOpen,
                            child: SlideTransition(
                              position: _mobileSidebarSlide,
                              child: Material(
                                color: isDark ? AppTheme.zinc800 : Colors.white,
                                child: sidebarPanel,
                              ),
                            ),
                          ),
                        ),
                      if (_isChatMounted && chatPanel != null)
                        Positioned.fill(
                          child: IgnorePointer(
                            ignoring: !_isChatOpen,
                            child: SlideTransition(
                              position: _mobileChatSlide,
                              child: Material(
                                color: isDark ? AppTheme.zinc800 : Colors.white,
                                child: chatPanel,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
          BlocBuilder<StudyExecutionBloc, StudyExecutionState>(
            builder: (context, state) {
              if (!state.isLoading || state.chunks.isEmpty) {
                return const SizedBox.shrink();
              }

              return Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.1),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SidebarOpenButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _SidebarOpenButton({required this.isDark, required this.onTap});

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

class _AskAiButton extends StatelessWidget {
  final bool isDark;
  final bool isAiAvailable;
  final String tooltip;
  final VoidCallback onTap;

  const _AskAiButton({
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
