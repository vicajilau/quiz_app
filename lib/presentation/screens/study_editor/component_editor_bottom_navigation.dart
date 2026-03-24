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
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';

class ComponentEditorBottomNavigation extends StatefulWidget {
  final bool isDark;
  final AppLocalizations localizations;
  final VoidCallback onAddComponent;
  final VoidCallback onSave;
  final VoidCallback onAI;

  /// When non-null, a delete button is shown before "Add Component".
  final int? deleteCount;
  final VoidCallback? onDelete;

  const ComponentEditorBottomNavigation({
    super.key,
    required this.isDark,
    required this.localizations,
    required this.onAddComponent,
    required this.onSave,
    required this.onAI,
    this.deleteCount,
    this.onDelete,
  });

  @override
  State<ComponentEditorBottomNavigation> createState() =>
      _ComponentEditorBottomNavigationState();
}

class _ComponentEditorBottomNavigationState
    extends State<ComponentEditorBottomNavigation> {
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
  void didUpdateWidget(ComponentEditorBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deleteCount != widget.deleteCount) {
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
    final backgroundColor = Theme.of(context).cardColor;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.deleteCount != null) ...[
                        QuizdyButton(
                          type: QuizdyButtonType.warning,
                          icon: LucideIcons.trash2,
                          title:
                              '${widget.localizations.deleteButton} (${widget.deleteCount})',
                          onPressed: widget.onDelete,
                        ),
                        const SizedBox(width: 12),
                      ],
                      QuizdyButton(
                        type: QuizdyButtonType.secondary,
                        icon: LucideIcons.plus,
                        title: widget.localizations.addComponentTitle,
                        onPressed: widget.onAddComponent,
                      ),
                      const SizedBox(width: 12),
                      QuizdyButton(
                        backgroundColor: AppTheme.secondaryColor,
                        title: widget.localizations.addComponentsWithAI,
                        icon: LucideIcons.sparkles,
                        onPressed: widget.onAI,
                      ),
                    ],
                  ),
                ),

                // Left shadow indicator
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
                              backgroundColor.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // Right shadow indicator
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
                              backgroundColor.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            QuizdyButton(
              type: QuizdyButtonType.primary,
              title: widget.localizations.studyEditorSaveChanges,
              expanded: true,
              onPressed: widget.onSave,
            ),
          ],
        ),
      ),
    );
  }
}
