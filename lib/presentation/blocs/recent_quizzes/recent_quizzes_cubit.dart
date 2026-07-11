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

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizdy/data/repositories/recent_quiz/recent_quiz_repository.dart';
import 'package:quizdy/presentation/blocs/recent_quizzes/recent_quizzes_state.dart';
import 'package:quizdy/domain/models/quiz/quiz_file.dart';

/// Cubit responsible for managing the state of recent study/quiz files.
class RecentQuizzesCubit extends Cubit<RecentQuizzesState> {
  final RecentQuizRepository _recentQuizRepository;

  RecentQuizzesCubit({required this._recentQuizRepository})
    : super(RecentQuizzesInitial());

  /// Loads/reloads the list of recent quizzes from the database.
  void loadRecentQuizzes() {
    emit(RecentQuizzesLoading());
    try {
      final list = _recentQuizRepository.getRecentQuizzes();
      emit(RecentQuizzesLoaded(list));
    } catch (e) {
      emit(RecentQuizzesError(e.toString()));
    }
  }

  /// Deletes a recent quiz by its ID and refreshes the list.
  Future<void> deleteRecentQuiz(String id) async {
    try {
      await _recentQuizRepository.removeRecentQuiz(id);
      loadRecentQuizzes();
    } catch (e) {
      emit(RecentQuizzesError(e.toString()));
    }
  }

  /// Saves or updates a quiz file in the database and reloads.
  Future<void> addOrUpdateRecentQuiz(QuizFile quizFile) async {
    try {
      await _recentQuizRepository.saveRecentQuiz(quizFile);
      loadRecentQuizzes();
    } catch (e) {
      emit(RecentQuizzesError(e.toString()));
    }
  }

  /// Clears the history and reloads.
  Future<void> clearAllRecentQuizzes() async {
    try {
      await _recentQuizRepository.clearAll();
      loadRecentQuizzes();
    } catch (e) {
      emit(RecentQuizzesError(e.toString()));
    }
  }
}
