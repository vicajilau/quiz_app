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

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/core/theme/extensions/custom_colors.dart';
import 'package:quizdy/presentation/screens/widgets/study/study_progress_bar.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';

class StudyIndexFooterWidget extends StatefulWidget {
  final AppLocalizations localizations;

  final double progressPercentage;
  final VoidCallback? onAddChunk;
  final VoidCallback? onGenerateAI;
  final VoidCallback? onImport;
  final VoidCallback? onSave;
  final VoidCallback? onDelete;
  final VoidCallback? onExportPdf;
  final VoidCallback? onDeleteDuplicates;
  final VoidCallback onStartQuiz;
  final bool isStartQuizEnabled;
  final int selectedChunkCount;
  final bool hasDuplicates;
  final bool showSaveButton;
  final bool hasChunks;
  final bool canExportPdf;

  const StudyIndexFooterWidget({
    super.key,
    required this.localizations,
    this.progressPercentage = 0,
    this.onAddChunk,
    this.onGenerateAI,
    this.onImport,
    this.onSave,
    this.onDelete,
    this.onExportPdf,
    this.onDeleteDuplicates,
    required this.onStartQuiz,
    this.isStartQuizEnabled = true,
    this.selectedChunkCount = 0,
    this.hasDuplicates = false,
    this.showSaveButton = true,
    this.hasChunks = true,
    this.canExportPdf = false,
  });

  @override
  State<StudyIndexFooterWidget> createState() => _StudyIndexFooterWidgetState();
}

class _StudyIndexFooterWidgetState extends State<StudyIndexFooterWidget> {
  late final ScrollController _scrollController;
  bool _showLeftShadow = false;
  bool _showRightShadow = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateShadows);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateShadows());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateShadows);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(StudyIndexFooterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedChunkCount != widget.selectedChunkCount ||
        oldWidget.showSaveButton != widget.showSaveButton) {
      _scrollToStart();
    }
  }

  void _scrollToStart() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _updateShadows() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    final showLeft = currentScroll > 0;
    final showRight = currentScroll < maxScroll;

    if (showLeft != _showLeftShadow || showRight != _showRightShadow) {
      setState(() {
        _showLeftShadow = showLeft;
        _showRightShadow = showRight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).cardColor;

    return Container(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress Bar
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: StudyProgressBar(
                  progressPercentage: widget.progressPercentage,
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 12.0;
                  final availableWidth = constraints.maxWidth;

                  final buttonData = [
                    if (widget.hasDuplicates)
                      (
                        button: QuizdyButton(
                          backgroundColor: Theme.of(
                            context,
                          ).extension<CustomColors>()?.onWarningContainer,
                          icon: LucideIcons.copyX,
                          expanded: true,
                          title: widget.localizations.deleteDuplicatesButton,
                          onPressed: widget.onDeleteDuplicates,
                        ),
                        flex: 2,
                      ),
                    if (widget.selectedChunkCount > 0)
                      (
                        button: QuizdyButton(
                          type: QuizdyButtonType.warning,
                          icon: LucideIcons.trash2,
                          expanded: true,
                          title:
                              '${widget.localizations.deleteButton} (${widget.selectedChunkCount})',
                          onPressed: widget.onDelete,
                        ),
                        flex: 2,
                      ),
                    if (widget.showSaveButton)
                      (
                        button: QuizdyButton(
                          type: QuizdyButtonType.secondary,
                          icon: LucideIcons.save,
                          expanded: true,
                          title: widget.localizations.saveButton,
                          onPressed: widget.onSave,
                        ),
                        flex: 2,
                      ),
                    (
                      button: QuizdyButton(
                        type: QuizdyButtonType.secondary,
                        icon: LucideIcons.plus,
                        expanded: true,
                        title: widget.localizations.addSection,
                        onPressed: widget.onAddChunk,
                      ),
                      flex: 2,
                    ),
                    (
                      button: QuizdyButton(
                        backgroundColor: AppTheme.secondaryColor,
                        icon: LucideIcons.sparkles,
                        expanded: true,
                        title: widget.hasChunks
                            ? widget.localizations.addSectionsWithAI
                            : widget.localizations.generateSectionsWithAI,
                        onPressed: widget.onGenerateAI,
                      ),
                      flex: 3, // More space for AI
                    ),
                    (
                      button: QuizdyButton(
                        type: QuizdyButtonType.secondary,
                        icon: LucideIcons.upload,
                        expanded: true,
                        title: widget.localizations.importButton,
                        onPressed: widget.onImport,
                      ),
                      flex: 2,
                    ),
                    if (widget.canExportPdf)
                      (
                        button: QuizdyButton(
                          type: QuizdyButtonType.secondary,
                          icon: LucideIcons.fileDown,
                          expanded: true,
                          title: widget.localizations.exportAsPdf,
                          onPressed: widget.onExportPdf,
                        ),
                        flex: 2,
                      ),
                  ];

                  final buttonCount = buttonData.length;
                  final totalFlex = buttonData.fold<int>(
                    0,
                    (sum, item) => sum + item.flex,
                  );

                  // Use a 'safe' width that avoids truncation for most labels
                  const safeFlexUnitWidth = 120.0;

                  final idealWidth =
                      (safeFlexUnitWidth * totalFlex) +
                      (gap * (buttonCount - 1));

                  final isScrollable = idealWidth > availableWidth;

                  // This width will be shared by both rows
                  final effectiveWidth = isScrollable
                      ? availableWidth
                      : idealWidth;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top Action Row
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: effectiveWidth,
                          child: !isScrollable
                              ? Row(
                                  children: [
                                    for (
                                      int i = 0;
                                      i < buttonData.length;
                                      i++
                                    ) ...[
                                      Expanded(
                                        flex: buttonData[i].flex,
                                        child: buttonData[i].button,
                                      ),
                                      if (i < buttonData.length - 1)
                                        const SizedBox(width: gap),
                                    ],
                                  ],
                                )
                              : Stack(
                                  children: [
                                    ScrollConfiguration(
                                      behavior: ScrollConfiguration.of(context)
                                          .copyWith(
                                            dragDevices: {
                                              PointerDeviceKind.touch,
                                              PointerDeviceKind.mouse,
                                            },
                                          ),
                                      child:
                                          NotificationListener<
                                            ScrollMetricsNotification
                                          >(
                                            onNotification: (notification) {
                                              _updateShadows();
                                              return true;
                                            },
                                            child: SingleChildScrollView(
                                              controller: _scrollController,
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  for (
                                                    int i = 0;
                                                    i < buttonData.length;
                                                    i++
                                                  ) ...[
                                                    SizedBox(
                                                      width:
                                                          safeFlexUnitWidth *
                                                          buttonData[i].flex,
                                                      child:
                                                          buttonData[i].button,
                                                    ),
                                                    if (i <
                                                        buttonData.length - 1)
                                                      const SizedBox(
                                                        width: gap,
                                                      ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),
                                    ),

                                    // Left Shadow Indicator
                                    if (_showLeftShadow)
                                      Positioned(
                                        left: -1,
                                        top: 0,
                                        bottom: 0,
                                        width: 40,
                                        child: IgnorePointer(
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                                colors: [
                                                  backgroundColor,
                                                  backgroundColor.withValues(
                                                    alpha: 0.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                    // Right Shadow Indicator
                                    if (_showRightShadow)
                                      Positioned(
                                        right: -1,
                                        top: 0,
                                        bottom: 0,
                                        width: 40,
                                        child: IgnorePointer(
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.centerRight,
                                                end: Alignment.centerLeft,
                                                colors: [
                                                  backgroundColor,
                                                  backgroundColor.withValues(
                                                    alpha: 0.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Bottom Action Button
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: effectiveWidth,
                          child: QuizdyButton(
                            title: widget.localizations.startQuizFromStudy,
                            icon: LucideIcons.play,
                            expanded: true,
                            onPressed: widget.onStartQuiz,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
