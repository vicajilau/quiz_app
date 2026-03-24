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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/core/context_extension.dart';
import 'package:quizdy/core/extensions/string_extension.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/core/theme/extensions/quiz_loaded_theme.dart';
import 'package:quizdy/data/services/configuration_service.dart';
import 'package:quizdy/domain/models/ai/ai_study_generation_config.dart';
import 'package:quizdy/domain/models/quiz/study_component.dart';
import 'package:quizdy/presentation/blocs/study_editor_cubit/study_editor_cubit.dart';
import 'package:quizdy/presentation/blocs/study_editor_cubit/study_editor_state.dart';
import 'package:quizdy/presentation/screens/dialogs/ai_generate_study_dialog.dart';
import 'package:quizdy/presentation/screens/dialogs/custom_confirm_dialog.dart';
import 'package:quizdy/presentation/screens/dialogs/exit_confirmation_dialog.dart';
import 'package:quizdy/presentation/screens/dialogs/settings_dialog.dart';
import 'package:quizdy/presentation/screens/study_editor/add_component_sheet.dart';
import 'package:quizdy/presentation/screens/study_editor/component_card.dart';
import 'package:quizdy/presentation/screens/study_editor/component_edit_sidebar.dart';
import 'package:quizdy/presentation/screens/study_editor/component_editor_bottom_navigation.dart';
import 'package:quizdy/presentation/screens/widgets/common/quizdy_app_bar.dart';

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
  late List<StudyComponent> _initialComponents;

  bool _selectionMode = false;
  final Set<int> _selectedIndices = {};

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

    _initialComponents = List<StudyComponent>.from(
      context
          .read<StudyEditorCubit>()
          .state
          .chunks[widget.chunkIndex]
          .pages[widget.pageIndex]
          .uiElements,
    );
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

  // ── Multi-select helpers ──────────────────────────────────────────────────

  void _toggleSelectionMode() {
    if (_selectionMode) {
      setState(() {
        _selectionMode = false;
        _selectedIndices.clear();
      });
    } else {
      _closeSidebar();
      _closeAddComponent();
      setState(() {
        _selectionMode = true;
        _selectedIndices.clear();
      });
    }
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _deleteSelected() {
    if (_selectedIndices.isEmpty) return;
    context.read<StudyEditorCubit>().deleteComponents(
      widget.chunkIndex,
      widget.pageIndex,
      _selectedIndices.toList(),
    );
    setState(() => _selectedIndices.clear());
  }

  void _onReorder(int oldIndex, int newIndex) {
    final cubit = context.read<StudyEditorCubit>();
    if (_selectedIndices.contains(oldIndex) && _selectedIndices.length > 1) {
      // Move all selected components as a group.
      cubit.moveComponents(
        widget.chunkIndex,
        widget.pageIndex,
        _selectedIndices.toList(),
        newIndex,
      );
      setState(() => _selectedIndices.clear());
    } else {
      cubit.reorderComponents(
        widget.chunkIndex,
        widget.pageIndex,
        oldIndex,
        newIndex,
      );
    }
  }

  bool _hasChanges(StudyEditorState state) {
    final current =
        state.chunks[widget.chunkIndex].pages[widget.pageIndex].uiElements;
    return !const ListEquality<StudyComponent>().equals(
      current,
      _initialComponents,
    );
  }

  Future<void> _confirmBack(BuildContext context) async {
    final state = context.read<StudyEditorCubit>().state;
    if (_hasChanges(state)) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => const ExitConfirmationDialog(),
      );
      if (confirmed != true || !context.mounted) return;
    }
    if (context.mounted) context.pop(false);
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

    return BlocConsumer<StudyEditorCubit, StudyEditorState>(
      listenWhen: (prev, curr) =>
          curr.error != null && curr.error != prev.error,
      listener: (context, state) {
        showDialog(
          context: context,
          builder: (context) => CustomConfirmDialog(
            title: localizations.aiGenerationErrorTitle,
            message: state.error!.cleanExceptionPrefix(),
            confirmText: localizations.acceptButton,
            showCloseButton: false,
          ),
        );
      },
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

        // Clean up stale selection indices after external deletions.
        final staleSelected = _selectedIndices
            .where((i) => i >= elements.length)
            .toList();
        if (staleSelected.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _selectedIndices.removeAll(staleSelected));
            }
          });
        }

        final isMobile = context.isMobile;
        final showDesktopSidebar =
            !isMobile && _editingIndex != null && !_selectionMode;
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

        final list = _buildList(
          context,
          elements: elements,
          localizations: localizations,
        );

        return Scaffold(
          appBar: showMobileOverlay
              ? null
              : QuizdyAppBar(
                  onLeadingPressed: () => _confirmBack(context),
                  title: Text(
                    chunk.title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  actions: [
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color:
                            context.quizLoadedTheme.appBarIconBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async => await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const SettingsDialog(),
                        ),
                        icon: Icon(
                          LucideIcons.settings,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 20,
                        ),
                        tooltip: localizations.questionOrderConfigTooltip,
                      ),
                    ),
                    _SelectToggleButton(
                      isSelectionMode: _selectionMode,
                      onTap: _toggleSelectionMode,
                      localizations: localizations,
                    ),
                  ],
                ),
          bottomNavigationBar: showMobileOverlay
              ? null
              : ComponentEditorBottomNavigation(
                  isDark: isDark,
                  localizations: localizations,
                  onAddComponent: _openAddComponent,
                  onSave: () => context.pop(true),
                  onAI: () async {
                    final isAiAvailable =
                        await ServiceLocator.getIt<ConfigurationService>()
                            .getIsAiAvailable();
                    if (!context.mounted) return;
                    if (!isAiAvailable) {
                      context.presentSnackBar(localizations.aiApiKeyRequired);
                      return;
                    }
                    final config = await showDialog<AiStudyGenerationConfig>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const AiGenerateStudyDialog(),
                    );
                    if (config != null && context.mounted) {
                      context.read<StudyEditorCubit>().generateAndAddComponents(
                        widget.chunkIndex,
                        widget.pageIndex,
                        config,
                        localizations,
                      );
                    }
                  },
                  deleteCount: _selectionMode && _selectedIndices.isNotEmpty
                      ? _selectedIndices.length
                      : null,
                  onDelete: _selectionMode && _selectedIndices.isNotEmpty
                      ? _deleteSelected
                      : null,
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
              if (state.isGenerating)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.1),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(
    BuildContext context, {
    required List<StudyComponent> elements,
    required AppLocalizations localizations,
  }) {
    if (elements.isEmpty) {
      return Center(child: Text(localizations.studyEditorEmptyComponents));
    }

    if (_selectionMode) {
      return ReorderableListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        buildDefaultDragHandles: false,
        onReorder: _onReorder,
        itemCount: elements.length,
        itemBuilder: (context, index) =>
            _buildCard(context, elements: elements, index: index),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      itemCount: elements.length,
      itemBuilder: (context, index) =>
          _buildCard(context, elements: elements, index: index),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required List<StudyComponent> elements,
    required int index,
  }) {
    final element = elements[index];
    final isEditing = _editingIndex == index;
    return ComponentCard(
      key: ValueKey(
        'component_${widget.chunkIndex}_${widget.pageIndex}_$index',
      ),
      element: element,
      index: index,
      totalCount: elements.length,
      isSelected: isEditing,
      isInSelectionMode: _selectionMode,
      isChecked: _selectedIndices.contains(index),
      onToggleSelect: () => _toggleSelection(index),
      onEdit: () => _openEditor(context, index),
      onDelete: () {
        if (_editingIndex == index) _closeSidebar();
        context.read<StudyEditorCubit>().deleteComponent(
          widget.chunkIndex,
          widget.pageIndex,
          index,
        );
      },
      onMoveUp: () => context.read<StudyEditorCubit>().reorderComponents(
        widget.chunkIndex,
        widget.pageIndex,
        index,
        index - 1,
      ),
      onMoveDown: () => context.read<StudyEditorCubit>().reorderComponents(
        widget.chunkIndex,
        widget.pageIndex,
        index,
        index + 2,
      ),
      onDuplicate: () => context.read<StudyEditorCubit>().duplicateComponent(
        widget.chunkIndex,
        widget.pageIndex,
        index,
      ),
    );
  }
}

class _SelectToggleButton extends StatelessWidget {
  final bool isSelectionMode;
  final VoidCallback onTap;
  final AppLocalizations localizations;

  const _SelectToggleButton({
    required this.isSelectionMode,
    required this.onTap,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 24),
      constraints: const BoxConstraints(minWidth: 40),
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
                              ? localizations.done
                              : localizations.select,
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
    );
  }
}
