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
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/domain/models/quiz/study_component.dart';
import 'package:quizdy/presentation/blocs/study_editor_cubit/study_editor_cubit.dart';
import 'package:quizdy/presentation/blocs/study_editor_cubit/study_editor_state.dart';
import 'package:quizdy/presentation/screens/study_editor/add_component_sheet.dart';
import 'package:quizdy/presentation/screens/study_editor/component_card.dart';
import 'package:quizdy/presentation/screens/study_editor/component_edit_sidebar.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';

/// Shows the list of [StudyComponent]s on a single page within a section.
/// On desktop the property panel appears as an inline sidebar.
/// On mobile it slides in as a full-screen overlay (same pattern as other sidebars).
class ComponentEditorScreen extends StatefulWidget {
  final int chunkIndex;
  final int pageIndex;

  const ComponentEditorScreen({
    super.key,
    required this.chunkIndex,
    required this.pageIndex,
  });

  @override
  State<ComponentEditorScreen> createState() => _ComponentEditorScreenState();
}

class _ComponentEditorScreenState extends State<ComponentEditorScreen>
    with SingleTickerProviderStateMixin {
  int? _editingIndex;
  bool _isSidebarMounted = false;
  bool _isAddCompMounted = false;

  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _openEditor(BuildContext context, int componentIndex) {
    setState(() {
      _editingIndex = componentIndex;
      _isSidebarMounted = true;
      _isAddCompMounted = false;
    });
    _slideController.forward();
  }

  void _closeSidebar() {
    _slideController.reverse().then((_) {
      if (mounted) setState(() => _isSidebarMounted = false);
    });
    setState(() => _editingIndex = null);
  }

  void _openAddComponent() {
    setState(() {
      _isAddCompMounted = true;
      _isSidebarMounted = false;
      _editingIndex = null;
    });
    _slideController.forward();
  }

  void _closeAddComponent() {
    _slideController.reverse().then((_) {
      if (mounted) setState(() => _isAddCompMounted = false);
    });
  }

  void _selectComponentType(BuildContext context, StudyComponentType type) {
    final cubit = context.read<StudyEditorCubit>();
    final newIndex = cubit
        .state
        .chunks[widget.chunkIndex]
        .pages[widget.pageIndex]
        .uiElements
        .length;
    cubit.addComponent(
      widget.chunkIndex,
      widget.pageIndex,
      StudyComponent(
        componentType: type,
        props: AddComponentSheet.defaultProps(type),
      ),
    );
    // Swap directly into the editor panel (slide is already at 1.0)
    setState(() {
      _isAddCompMounted = false;
      _editingIndex = newIndex;
      _isSidebarMounted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<StudyEditorCubit, StudyEditorState>(
      builder: (context, state) {
        final chunk = state.chunks[widget.chunkIndex];
        final page = chunk.pages[widget.pageIndex];
        final elements = page.uiElements;

        // Reset sidebar if selected index goes out of bounds after a delete.
        if (_editingIndex != null && _editingIndex! >= elements.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _closeSidebar();
          });
        }

        final list = elements.isEmpty
            ? Center(child: Text(localizations.studyEditorEmptyComponents))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                itemCount: elements.length,
                itemBuilder: (context, index) {
                  final element = elements[index];
                  final isSelected = _editingIndex == index;
                  return ComponentCard(
                    key: ValueKey(
                      'component_${widget.chunkIndex}_${widget.pageIndex}_$index',
                    ),
                    element: element,
                    index: index,
                    totalCount: elements.length,
                    isSelected: isSelected,
                    onEdit: () => _openEditor(context, index),
                    onDelete: () {
                      if (_editingIndex == index) _closeSidebar();
                      context.read<StudyEditorCubit>().deleteComponent(
                        widget.chunkIndex,
                        widget.pageIndex,
                        index,
                      );
                    },
                    onMoveUp: () =>
                        context.read<StudyEditorCubit>().reorderComponents(
                          widget.chunkIndex,
                          widget.pageIndex,
                          index,
                          index - 1,
                        ),
                    onMoveDown: () =>
                        context.read<StudyEditorCubit>().reorderComponents(
                          widget.chunkIndex,
                          widget.pageIndex,
                          index,
                          index + 2,
                        ),
                    onDuplicate: () =>
                        context.read<StudyEditorCubit>().duplicateComponent(
                          widget.chunkIndex,
                          widget.pageIndex,
                          index,
                        ),
                  );
                },
              );

        final isMobile = context.isMobile;
        final showDesktopSidebar = !isMobile && _editingIndex != null;
        final showDesktopAddComp = !isMobile && _isAddCompMounted;
        final showMobileOverlay =
            isMobile && (_isSidebarMounted || _isAddCompMounted);

        final sidebar = _isSidebarMounted && _editingIndex != null
            ? ComponentEditSidebar(
                key: ValueKey(
                  'sidebar_${widget.chunkIndex}_${widget.pageIndex}_$_editingIndex',
                ),
                chunkIndex: widget.chunkIndex,
                pageIndex: widget.pageIndex,
                componentIndex: _editingIndex!,
                isFullScreen: isMobile,
                onClose: _closeSidebar,
              )
            : null;

        return Scaffold(
          appBar: showMobileOverlay
              ? null
              : AppBar(
                  backgroundColor: Theme.of(context).primaryColor,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                  ),
                  toolbarHeight: 72,
                  leadingWidth: 72,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.appBarIconBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            LucideIcons.arrowLeft,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 20,
                          ),
                          onPressed: () => context.pop(false),
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    chunk.title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
          bottomNavigationBar: showMobileOverlay
              ? null
              : Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.3 : 0.05,
                        ),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            QuizdyButton(
                              type: QuizdyButtonType.secondary,
                              icon: LucideIcons.plus,
                              title: localizations.addSection,
                              onPressed: _openAddComponent,
                            ),
                            const SizedBox(width: 12),
                            QuizdyButton(
                              backgroundColor: AppTheme.secondaryColor,
                              title: localizations.addSectionsWithAI,
                              icon: LucideIcons.sparkles,
                              onPressed: () => context.presentSnackBar(
                                localizations.featureComingSoon,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        QuizdyButton(
                          type: QuizdyButtonType.primary,
                          title: localizations.studyEditorSaveChanges,
                          expanded: true,
                          onPressed: () => context.pop(true),
                        ),
                      ],
                    ),
                  ),
                ),
          body: Stack(
            children: [
              Row(
                children: [
                  Expanded(child: list),
                  if (showDesktopSidebar) sidebar!,
                  if (showDesktopAddComp)
                    AddComponentSheet(
                      isFullScreen: false,
                      onClose: () => setState(() => _isAddCompMounted = false),
                      onSelect: (type) => _selectComponentType(context, type),
                    ),
                ],
              ),
              if (isMobile && _isSidebarMounted && sidebar != null)
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: _editingIndex == null,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Material(
                        color: isDark ? AppTheme.zinc900 : Colors.white,
                        child: sidebar,
                      ),
                    ),
                  ),
                ),
              if (isMobile && _isAddCompMounted)
                Positioned.fill(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Material(
                      color: isDark ? AppTheme.zinc900 : Colors.white,
                      child: AddComponentSheet(
                        isFullScreen: true,
                        onClose: _closeAddComponent,
                        onSelect: (type) => _selectComponentType(context, type),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
