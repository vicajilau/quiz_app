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

import 'package:quizdy/domain/models/recent_quiz/recent_quiz.dart';

/// Base state for recent quizzes.
abstract class RecentQuizzesState {}

/// Initial state when the cubit is created.
class RecentQuizzesInitial extends RecentQuizzesState {}

/// State emitted while loading recent quizzes.
class RecentQuizzesLoading extends RecentQuizzesState {}

/// State emitted when recent quizzes are loaded successfully.
class RecentQuizzesLoaded extends RecentQuizzesState {
  final List<RecentQuiz> recentQuizzes;
  RecentQuizzesLoaded(this.recentQuizzes);
}

/// State emitted when an error occurs during recent quizzes operations.
class RecentQuizzesError extends RecentQuizzesState {
  final String errorMessage;
  RecentQuizzesError(this.errorMessage);
}
