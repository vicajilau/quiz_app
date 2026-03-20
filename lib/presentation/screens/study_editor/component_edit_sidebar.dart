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
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/core/extensions/study_extension.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/theme/app_theme.dart';
import 'package:quizdy/domain/models/quiz/study_component.dart';
import 'package:quizdy/presentation/blocs/study_editor_cubit/study_editor_cubit.dart';
import 'package:quizdy/presentation/screens/study_editor/component_property_form.dart';
import 'package:quizdy/presentation/widgets/quizdy_button.dart';

/// Inline property-panel sidebar shown on the right on desktop.
/// Supports all [StudyComponentType]s via [ComponentPropertyForm].
class ComponentEditSidebar extends StatefulWidget {
  final int chunkIndex;
  final int pageIndex;
  final int componentIndex;
  final VoidCallback onClose;
  final bool isFullScreen;

  const ComponentEditSidebar({
    super.key,
    required this.chunkIndex,
    required this.pageIndex,
    required this.componentIndex,
    required this.onClose,
    this.isFullScreen = false,
  });

  @override
  State<ComponentEditSidebar> createState() => _ComponentEditSidebarState();
}

class _ComponentEditSidebarState extends State<ComponentEditSidebar> {
  final _formKey = GlobalKey<ComponentPropertyFormState>();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final panelBg = isDark ? AppTheme.zinc900 : Colors.white;
    final borderColor = isDark ? AppTheme.zinc800 : AppTheme.zinc200;

    final componentType = context
        .read<StudyEditorCubit>()
        .state
        .chunks[widget.chunkIndex]
        .pages[widget.pageIndex]
        .uiElements[widget.componentIndex]
        .componentType;

    return Container(
      width: widget.isFullScreen ? double.infinity : 320,
      decoration: BoxDecoration(
        color: panelBg,
        border: widget.isFullScreen
            ? null
            : Border(left: BorderSide(color: borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.fileText,
                          size: 13,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          componentType.displayName(localizations),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.violet400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Close button
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.zinc800 : AppTheme.zinc100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        LucideIcons.x,
                        size: 14,
                        color: AppTheme.zinc500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: borderColor),
          Expanded(
            child: ComponentPropertyForm(
              key: _formKey,
              chunkIndex: widget.chunkIndex,
              pageIndex: widget.pageIndex,
              componentIndex: widget.componentIndex,
              onSave: widget.onClose,
            ),
          ),
          Divider(height: 1, thickness: 1, color: borderColor),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: QuizdyButton(
              type: QuizdyButtonType.primary,
              icon: LucideIcons.check,
              title: localizations.okButton,
              expanded: true,
              onPressed: () => _formKey.currentState?.save(),
            ),
          ),
        ],
      ),
    );
  }
}
