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
import 'package:quizdy/domain/models/quiz/study_page.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_component.dart';

/// Represents the currently active view within the study editor flow.
enum StudyEditorView {
  /// The study index with the edit-mode toggle.
  studyIndex,

  /// The section page manager (list of pages within a section).
  sectionPageManager,

  /// The component editor for a single page.
  componentEditor,
}

/// Immutable state for [StudyEditorCubit].
class StudyEditorState {
  /// Working copy of all sections (chunks). Modifications happen here before
  /// being persisted.
  final List<StudyChunk> chunks;

  /// Whether the editor overlay is currently active.
  final bool isEditMode;

  /// The currently active view within the editor flow.
  final StudyEditorView currentView;

  /// Index of the section (chunk) selected for page management.
  /// `null` when [currentView] is [StudyEditorView.studyIndex].
  final int? selectedChunkIndex;

  /// Index of the page selected for component editing.
  /// `null` unless [currentView] is [StudyEditorView.componentEditor].
  final int? selectedPageIndex;

  /// Index of the component currently being edited in the property panel.
  /// `null` when no component is selected.
  final int? selectedComponentIndex;

  /// Whether an async save operation is in progress.
  final bool isSaving;

  /// Whether there are unsaved changes compared to the original state.
  final bool hasUnsavedChanges;

  /// Non-null when the last operation produced an error.
  final String? error;

  const StudyEditorState({
    this.chunks = const [],
    this.isEditMode = false,
    this.currentView = StudyEditorView.studyIndex,
    this.selectedChunkIndex,
    this.selectedPageIndex,
    this.selectedComponentIndex,
    this.isSaving = false,
    this.hasUnsavedChanges = false,
    this.error,
  });

  /// Returns the currently selected [StudyChunk], or `null` if none selected.
  StudyChunk? get selectedChunk {
    final index = selectedChunkIndex;
    if (index == null || index < 0 || index >= chunks.length) return null;
    return chunks[index];
  }

  /// Returns the currently selected [Page], or `null` if none selected.
  StudyPage? get selectedPage {
    final chunk = selectedChunk;
    final index = selectedPageIndex;
    if (chunk == null ||
        index == null ||
        index < 0 ||
        index >= chunk.pages.length) {
      return null;
    }
    return chunk.pages[index];
  }

  /// Returns the currently selected [StudyComponent], or `null` if none selected.
  StudyComponent? get selectedComponent {
    final page = selectedPage;
    final index = selectedComponentIndex;
    if (page == null ||
        index == null ||
        index < 0 ||
        index >= page.uiElements.length) {
      return null;
    }
    return page.uiElements[index];
  }

  StudyEditorState copyWith({
    List<StudyChunk>? chunks,
    bool? isEditMode,
    StudyEditorView? currentView,
    int? selectedChunkIndex,
    bool clearSelectedChunk = false,
    int? selectedPageIndex,
    bool clearSelectedPage = false,
    int? selectedComponentIndex,
    bool clearSelectedComponent = false,
    bool? isSaving,
    bool? hasUnsavedChanges,
    String? error,
    bool clearError = false,
  }) {
    return StudyEditorState(
      chunks: chunks ?? this.chunks,
      isEditMode: isEditMode ?? this.isEditMode,
      currentView: currentView ?? this.currentView,
      selectedChunkIndex: clearSelectedChunk
          ? null
          : selectedChunkIndex ?? this.selectedChunkIndex,
      selectedPageIndex: clearSelectedPage
          ? null
          : selectedPageIndex ?? this.selectedPageIndex,
      selectedComponentIndex: clearSelectedComponent
          ? null
          : selectedComponentIndex ?? this.selectedComponentIndex,
      isSaving: isSaving ?? this.isSaving,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is StudyEditorState &&
        listEquals(other.chunks, chunks) &&
        other.isEditMode == isEditMode &&
        other.currentView == currentView &&
        other.selectedChunkIndex == selectedChunkIndex &&
        other.selectedPageIndex == selectedPageIndex &&
        other.selectedComponentIndex == selectedComponentIndex &&
        other.isSaving == isSaving &&
        other.hasUnsavedChanges == hasUnsavedChanges &&
        other.error == error;
  }

  @override
  int get hashCode =>
      chunks.hashCode ^
      isEditMode.hashCode ^
      currentView.hashCode ^
      selectedChunkIndex.hashCode ^
      selectedPageIndex.hashCode ^
      selectedComponentIndex.hashCode ^
      isSaving.hashCode ^
      hasUnsavedChanges.hashCode ^
      error.hashCode;
}
