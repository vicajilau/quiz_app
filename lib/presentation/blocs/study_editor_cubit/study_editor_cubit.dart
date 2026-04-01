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

import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizdy/core/debug_print.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/core/service_locator.dart';
import 'package:quizdy/data/repositories/ai/ai_repository_factory.dart';
import 'package:quizdy/data/repositories/quiz_file_repository.dart';
import 'package:quizdy/domain/models/ai/ai_study_generation_config.dart';
import 'package:quizdy/domain/use_cases/build_study_page_components_prompt_use_case.dart';
import 'package:quizdy/domain/models/quiz/study_page.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';
import 'package:quizdy/domain/models/quiz/source_reference.dart';
import 'package:quizdy/domain/models/quiz/study_chunk.dart';
import 'package:quizdy/domain/models/quiz/study_chunk_state.dart';
import 'package:quizdy/domain/models/quiz/study_component.dart';
import 'package:quizdy/presentation/blocs/study_editor_cubit/study_editor_state.dart';

/// Cubit that manages all in-memory editing of study sections, pages, and
/// components. Persist changes by calling [saveChanges].
class StudyEditorCubit extends Cubit<StudyEditorState> {
  final QuizFileRepository _repository;

  /// The base [QuizFile] used to reconstruct the updated file on save.
  /// `null` when the study was created without an associated file — in that
  /// case [saveChanges] is a no-op.
  QuizFile? _quizFile;

  StudyEditorCubit({
    required List<StudyChunk> initialChunks,
    QuizFile? quizFile,
    required QuizFileRepository repository,
  }) : _repository = repository,
       _quizFile = quizFile,
       super(StudyEditorState(chunks: List<StudyChunk>.from(initialChunks)));

  /// Toggles the study index edit mode on or off.
  void toggleEditMode() {
    emit(
      state.copyWith(
        isEditMode: !state.isEditMode,
        clearError: true,
        currentView: StudyEditorView.studyIndex,
        clearSelectedChunk: true,
        clearSelectedPage: true,
        clearSelectedComponent: true,
      ),
    );
  }

  /// Opens the [StudyEditorView.sectionPageManager] for [chunkIndex].
  void openSectionPageManager(int chunkIndex) {
    if (chunkIndex < 0 || chunkIndex >= state.chunks.length) return;
    emit(
      state.copyWith(
        currentView: StudyEditorView.sectionPageManager,
        selectedChunkIndex: chunkIndex,
        clearSelectedPage: true,
        clearSelectedComponent: true,
        clearError: true,
      ),
    );
  }

  /// Opens the [StudyEditorView.componentEditor] for [pageIndex] within the
  /// currently selected chunk.
  void openComponentEditor(int pageIndex) {
    final chunk = state.selectedChunk;
    if (chunk == null || pageIndex < 0 || pageIndex >= chunk.pages.length) {
      return;
    }
    emit(
      state.copyWith(
        currentView: StudyEditorView.componentEditor,
        selectedPageIndex: pageIndex,
        clearSelectedComponent: true,
        clearError: true,
      ),
    );
  }

  /// Returns to the previous view in the editor flow.
  void navigateBack() {
    switch (state.currentView) {
      case StudyEditorView.componentEditor:
        emit(
          state.copyWith(
            currentView: StudyEditorView.sectionPageManager,
            clearSelectedPage: true,
            clearSelectedComponent: true,
            clearError: true,
          ),
        );
      case StudyEditorView.sectionPageManager:
        emit(
          state.copyWith(
            currentView: StudyEditorView.studyIndex,
            clearSelectedChunk: true,
            clearSelectedPage: true,
            clearSelectedComponent: true,
            clearError: true,
          ),
        );
      case StudyEditorView.studyIndex:
        break;
    }
  }

  /// Renames the section at [chunkIndex] by updating its [SourceReference.blockType].
  void renameSection(int chunkIndex, String newTitle) {
    if (chunkIndex < 0 || chunkIndex >= state.chunks.length) return;
    final updated = List<StudyChunk>.from(state.chunks);
    final chunk = updated[chunkIndex];
    updated[chunkIndex] = chunk.copyWith(
      sourceReference: chunk.sourceReference.copyWith(blockType: newTitle),
    );
    emit(
      state.copyWith(
        chunks: updated,
        hasUnsavedChanges: true,
        clearError: true,
      ),
    );
  }

  /// Reorders sections by moving the section at [oldIndex] to [newIndex].
  void reorderSections(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final updated = List<StudyChunk>.from(state.chunks);
    final chunk = updated.removeAt(oldIndex);
    final insertAt = newIndex > oldIndex ? newIndex - 1 : newIndex;
    updated.insert(insertAt, chunk);

    // Re-assign chunkIndex values to reflect new order.
    final reindexed = [
      for (var i = 0; i < updated.length; i++)
        updated[i].copyWith(chunkIndex: i),
    ];

    emit(
      state.copyWith(
        chunks: reindexed,
        hasUnsavedChanges: true,
        clearError: true,
      ),
    );
  }

  /// Deletes the section at [chunkIndex].
  void deleteSection(int chunkIndex) {
    if (chunkIndex < 0 || chunkIndex >= state.chunks.length) return;
    final updated = List<StudyChunk>.from(state.chunks)..removeAt(chunkIndex);

    // Re-assign chunkIndex values.
    final reindexed = [
      for (var i = 0; i < updated.length; i++)
        updated[i].copyWith(chunkIndex: i),
    ];

    emit(
      state.copyWith(
        chunks: reindexed,
        hasUnsavedChanges: true,
        clearError: true,
      ),
    );
  }

  /// Adds a new empty section with the given [title].
  void addSection(String title) {
    final newChunk = StudyChunk(
      chunkIndex: state.chunks.length,
      status: StudyChunkState.completed,
      sourceReference: SourceReference(
        documentId: '',
        startPage: 0,
        endPage: 0,
        startOffset: 0,
        endOffset: 0,
        blockType: title,
      ),
      pages: const [],
    );

    emit(
      state.copyWith(
        chunks: [...state.chunks, newChunk],
        hasUnsavedChanges: true,
        clearError: true,
      ),
    );
  }

  /// Adds an empty page to the section at [chunkIndex].
  void addPage(int chunkIndex) {
    if (chunkIndex < 0 || chunkIndex >= state.chunks.length) return;
    final updatedChunks = List<StudyChunk>.from(state.chunks);
    final chunk = updatedChunks[chunkIndex];
    final updatedPages = [...chunk.pages, const StudyPage(uiElements: [])];
    updatedChunks[chunkIndex] = chunk.copyWith(pages: updatedPages);

    emit(
      state.copyWith(
        chunks: updatedChunks,
        hasUnsavedChanges: true,
        clearError: true,
      ),
    );
  }

  /// Deletes the page at [pageIndex] from the section at [chunkIndex].
  void deletePage(int chunkIndex, int pageIndex) {
    if (!_isValidPageRef(chunkIndex, pageIndex)) return;
    final updatedChunks = List<StudyChunk>.from(state.chunks);
    final chunk = updatedChunks[chunkIndex];
    final updatedPages = List<StudyPage>.from(chunk.pages)..removeAt(pageIndex);
    updatedChunks[chunkIndex] = chunk.copyWith(pages: updatedPages);

    emit(
      state.copyWith(
        chunks: updatedChunks,
        hasUnsavedChanges: true,
        clearError: true,
      ),
    );
  }

  /// Duplicates the page at [pageIndex] within the section at [chunkIndex],
  /// inserting the copy immediately after the original.
  void duplicatePage(int chunkIndex, int pageIndex) {
    if (!_isValidPageRef(chunkIndex, pageIndex)) return;
    final updatedChunks = List<StudyChunk>.from(state.chunks);
    final chunk = updatedChunks[chunkIndex];
    final pageCopy = chunk.pages[pageIndex].copyWith();
    final updatedPages = List<StudyPage>.from(chunk.pages)
      ..insert(pageIndex + 1, pageCopy);
    updatedChunks[chunkIndex] = chunk.copyWith(pages: updatedPages);

    emit(
      state.copyWith(
        chunks: updatedChunks,
        hasUnsavedChanges: true,
        clearError: true,
      ),
    );
  }

  /// Reorders pages within the section at [chunkIndex].
  void reorderPages(int chunkIndex, int oldIndex, int newIndex) {
    if (!_isValidPageRef(chunkIndex, oldIndex)) return;
    if (oldIndex == newIndex) return;
    final updatedChunks = List<StudyChunk>.from(state.chunks);
    final chunk = updatedChunks[chunkIndex];
    final updatedPages = List<StudyPage>.from(chunk.pages);
    final page = updatedPages.removeAt(oldIndex);
    final insertAt = newIndex > oldIndex ? newIndex - 1 : newIndex;
    updatedPages.insert(insertAt, page);
    updatedChunks[chunkIndex] = chunk.copyWith(pages: updatedPages);

    emit(
      state.copyWith(
        chunks: updatedChunks,
        hasUnsavedChanges: true,
        clearError: true,
      ),
    );
  }

  /// Selects the component at [componentIndex] on the current page.
  void selectComponent(int componentIndex) {
    final page = state.selectedPage;
    if (page == null ||
        componentIndex < 0 ||
        componentIndex >= page.uiElements.length) {
      return;
    }
    emit(
      state.copyWith(selectedComponentIndex: componentIndex, clearError: true),
    );
  }

  /// Clears the component selection without leaving the component editor.
  void clearComponentSelection() {
    emit(state.copyWith(clearSelectedComponent: true, clearError: true));
  }

  /// Adds [component] to the page at [pageIndex] within the section at
  /// [chunkIndex].
  void addComponent(int chunkIndex, int pageIndex, StudyComponent component) {
    if (!_isValidPageRef(chunkIndex, pageIndex)) return;
    final updatedChunks = _withUpdatedPage(
      chunkIndex,
      pageIndex,
      (page) => page.copyWith(uiElements: [...page.uiElements, component]),
    );

    emit(
      state.copyWith(
        chunks: updatedChunks,
        hasUnsavedChanges: true,
        clearError: true,
      ),
    );
  }

  /// Replaces the component at [componentIndex] on the page at [pageIndex]
  /// within the section at [chunkIndex].
  void updateComponent(
    int chunkIndex,
    int pageIndex,
    int componentIndex,
    StudyComponent component,
  ) {
    if (!_isValidComponentRef(chunkIndex, pageIndex, componentIndex)) return;
    final updatedChunks = _withUpdatedPage(chunkIndex, pageIndex, (page) {
      final elements = List<StudyComponent>.from(page.uiElements);
      elements[componentIndex] = component;
      return page.copyWith(uiElements: elements);
    });

    emit(
      state.copyWith(
        chunks: updatedChunks,
        hasUnsavedChanges: true,
        clearError: true,
      ),
    );
  }

  /// Deletes the component at [componentIndex] from the page at [pageIndex]
  /// within the section at [chunkIndex].
  void deleteComponent(int chunkIndex, int pageIndex, int componentIndex) {
    if (!_isValidComponentRef(chunkIndex, pageIndex, componentIndex)) return;
    final updatedChunks = _withUpdatedPage(chunkIndex, pageIndex, (page) {
      final elements = List<StudyComponent>.from(page.uiElements)
        ..removeAt(componentIndex);
      return page.copyWith(uiElements: elements);
    });

    emit(
      state.copyWith(
        chunks: updatedChunks,
        hasUnsavedChanges: true,
        clearError: true,
        clearSelectedComponent: true,
      ),
    );
  }

  /// Duplicates the component at [componentIndex], inserting the copy
  /// immediately after the original.
  void duplicateComponent(int chunkIndex, int pageIndex, int componentIndex) {
    if (!_isValidComponentRef(chunkIndex, pageIndex, componentIndex)) return;
    final updatedChunks = _withUpdatedPage(chunkIndex, pageIndex, (page) {
      final copy = page.uiElements[componentIndex].copyWith();
      final elements = List<StudyComponent>.from(page.uiElements)
        ..insert(componentIndex + 1, copy);
      return page.copyWith(uiElements: elements);
    });

    emit(
      state.copyWith(
        chunks: updatedChunks,
        hasUnsavedChanges: true,
        clearError: true,
      ),
    );
  }

  /// Deletes all components whose indices are listed in [indices] from the page
  /// at [pageIndex] within the section at [chunkIndex].
  void deleteComponents(int chunkIndex, int pageIndex, List<int> indices) {
    if (indices.isEmpty || !_isValidPageRef(chunkIndex, pageIndex)) return;
    final sortedDesc = indices.toList()..sort((a, b) => b.compareTo(a));
    final updatedChunks = _withUpdatedPage(chunkIndex, pageIndex, (page) {
      final elements = List<StudyComponent>.from(page.uiElements);
      for (final idx in sortedDesc) {
        if (idx >= 0 && idx < elements.length) elements.removeAt(idx);
      }
      return page.copyWith(uiElements: elements);
    });

    emit(
      state.copyWith(
        chunks: updatedChunks,
        hasUnsavedChanges: true,
        clearError: true,
        clearSelectedComponent: true,
      ),
    );
  }

  /// Moves the components at [fromIndices] to [targetIndex] (insert-before
  /// position in the original list) on the page at [pageIndex] within the
  /// section at [chunkIndex].
  void moveComponents(
    int chunkIndex,
    int pageIndex,
    List<int> fromIndices,
    int targetIndex,
  ) {
    if (fromIndices.isEmpty || !_isValidPageRef(chunkIndex, pageIndex)) return;
    final sortedFrom = fromIndices.toList()..sort();
    final updatedChunks = _withUpdatedPage(chunkIndex, pageIndex, (page) {
      final elements = List<StudyComponent>.from(page.uiElements);
      final selected = sortedFrom.map((i) => elements[i]).toList();

      // Remove selected elements (highest index first to preserve order).
      for (final idx in sortedFrom.reversed) {
        elements.removeAt(idx);
      }

      // Adjust target: each removed index below targetIndex shifts it left by 1.
      final offset = sortedFrom.where((i) => i < targetIndex).length;
      final insertAt = (targetIndex - offset).clamp(0, elements.length);
      elements.insertAll(insertAt, selected);

      return page.copyWith(uiElements: elements);
    });

    emit(
      state.copyWith(
        chunks: updatedChunks,
        hasUnsavedChanges: true,
        clearError: true,
      ),
    );
  }

  /// Reorders components on the page at [pageIndex] within the section at
  /// [chunkIndex].
  void reorderComponents(
    int chunkIndex,
    int pageIndex,
    int oldIndex,
    int newIndex,
  ) {
    if (!_isValidComponentRef(chunkIndex, pageIndex, oldIndex)) return;
    if (oldIndex == newIndex) return;
    final updatedChunks = _withUpdatedPage(chunkIndex, pageIndex, (page) {
      final elements = List<StudyComponent>.from(page.uiElements);
      final element = elements.removeAt(oldIndex);
      final insertAt = newIndex > oldIndex ? newIndex - 1 : newIndex;
      elements.insert(insertAt, element);
      return page.copyWith(uiElements: elements);
    });

    emit(
      state.copyWith(
        chunks: updatedChunks,
        hasUnsavedChanges: true,
        clearError: true,
      ),
    );
  }

  /// Generates [StudyComponent]s from [config] and appends them to the page
  /// at [pageIndex] within the section at [chunkIndex].
  ///
  /// Uses [AiRepositoryFactory] to obtain the correct provider and
  /// [BuildStudyPageComponentsPromptUseCase] to assemble the prompt,
  /// keeping all prompt logic out of the network layer.
  Future<void> generateAndAddComponents(
    int chunkIndex,
    int pageIndex,
    AiStudyGenerationConfig config,
    AppLocalizations localizations,
  ) async {
    if (state.isGenerating) return;
    emit(state.copyWith(isGenerating: true, clearError: true));
    try {
      final factory = ServiceLocator.getIt<AiRepositoryFactory>();
      final repository = config.preferredModel != null
          ? factory.createForModel(config.preferredModel!)
          : await factory.createDefault();

      final prompt = BuildStudyPageComponentsPromptUseCase.build(
        config,
        localizations,
      );

      final String responseBody;
      if (config.hasFile) {
        responseBody = await repository.sendMessagesWithFile(
          prompt,
          localizations,
          file: config.file!,
          responseMimeType: 'application/json',
        );
      } else {
        responseBody = await repository.sendMessages(
          prompt,
          localizations,
          responseMimeType: 'application/json',
        );
      }

      final components = _parseComponentsResponse(responseBody);
      for (final component in components) {
        addComponent(chunkIndex, pageIndex, component);
      }
      emit(state.copyWith(isGenerating: false));
    } catch (e) {
      printInDebug('StudyEditorCubit.generateAndAddComponents error: $e');
      emit(state.copyWith(isGenerating: false, error: e.toString()));
    }
  }

  /// Extracts and parses a JSON array of [StudyComponent]s from [response].
  List<StudyComponent> _parseComponentsResponse(String response) {
    String cleanJson = response.trim();
    final regExp = RegExp(r'```json\s*([\s\S]*?)\s*```', multiLine: true);
    final match = regExp.firstMatch(cleanJson);
    if (match != null && match.groupCount >= 1) {
      cleanJson = match.group(1)!.trim();
    } else {
      final first = cleanJson.indexOf('[');
      final last = cleanJson.lastIndexOf(']');
      if (first != -1 && last != -1 && last > first) {
        cleanJson = cleanJson.substring(first, last + 1).trim();
      }
    }

    final decoded = jsonDecode(cleanJson);
    if (decoded is! List) {
      throw FormatException(
        'Expected a JSON array of components. Got: $cleanJson',
      );
    }
    return decoded
        .map((e) => StudyComponent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Persists the current working [chunks] to the `.quiz` file via
  /// [QuizFileRepository].
  ///
  /// [dialogTitle] and [fileName] are forwarded to the save dialog.
  Future<void> saveChanges({
    required String dialogTitle,
    required String fileName,
  }) async {
    if (_quizFile == null || state.isSaving) return;
    emit(state.copyWith(isSaving: true, clearError: true));

    try {
      final quizFile = _quizFile!;
      final updatedStudy = quizFile.study?.copyWith(
        content: quizFile.study!.content.copyWith(cache: state.chunks),
      );

      final updatedFile = quizFile.copyWith(study: updatedStudy);

      final savedFile = await _repository.saveQuizFile(
        updatedFile,
        dialogTitle,
        fileName,
      );

      if (savedFile != null) {
        _quizFile = savedFile;
        emit(
          state.copyWith(
            isSaving: false,
            hasUnsavedChanges: false,
            clearError: true,
          ),
        );
      } else {
        // User cancelled the save dialog.
        emit(state.copyWith(isSaving: false));
      }
    } catch (e) {
      printInDebug('StudyEditorCubit.saveChanges error: $e');
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }

  /// Restores the cubit to an arbitrary [snapshot] of chunks, clearing the
  /// unsaved-changes flag. Used to roll back edits when the user leaves an
  /// editor screen without saving.
  void resetToSnapshot(List<StudyChunk> snapshot) {
    emit(
      state.copyWith(
        chunks: List<StudyChunk>.from(snapshot),
        hasUnsavedChanges: false,
        clearError: true,
      ),
    );
  }

  /// Discards all unsaved changes and restores the chunks from the original
  /// [QuizFile].
  void discardChanges() {
    final originalChunks =
        _quizFile?.study?.content.cache ?? const <StudyChunk>[];
    emit(
      StudyEditorState(
        chunks: List<StudyChunk>.from(originalChunks),
        isEditMode: false,
      ),
    );
  }

  bool _isValidPageRef(int chunkIndex, int pageIndex) {
    if (chunkIndex < 0 || chunkIndex >= state.chunks.length) return false;
    final pages = state.chunks[chunkIndex].pages;
    return pageIndex >= 0 && pageIndex < pages.length;
  }

  bool _isValidComponentRef(int chunkIndex, int pageIndex, int componentIndex) {
    if (!_isValidPageRef(chunkIndex, pageIndex)) return false;
    final elements = state.chunks[chunkIndex].pages[pageIndex].uiElements;
    return componentIndex >= 0 && componentIndex < elements.length;
  }

  /// Returns a new chunk list where the page at [pageIndex] within [chunkIndex]
  /// has been replaced by the result of [transform].
  List<StudyChunk> _withUpdatedPage(
    int chunkIndex,
    int pageIndex,
    StudyPage Function(StudyPage page) transform,
  ) {
    final updatedChunks = List<StudyChunk>.from(state.chunks);
    final chunk = updatedChunks[chunkIndex];
    final updatedPages = List<StudyPage>.from(chunk.pages);
    updatedPages[pageIndex] = transform(updatedPages[pageIndex]);
    updatedChunks[chunkIndex] = chunk.copyWith(pages: updatedPages);
    return updatedChunks;
  }
}
