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
import 'package:quizdy/presentation/blocs/quiz_execution_bloc/quiz_execution_state.dart';
import 'package:quizdy/presentation/screens/quiz_execution/quiz_question_options.dart';

/// Wrapper widget that loads quiz configuration síncronamente and passes it to QuizQuestionOptions
class QuizOptionsWrapper extends StatelessWidget {
  final QuizExecutionInProgress state;
  final void Function({String? prefillText})? onAskAi;

  const QuizOptionsWrapper({super.key, required this.state, this.onAskAi});

  @override
  Widget build(BuildContext context) {
    final quizConfig = state.quizConfig;
    final isStudyMode = quizConfig.isStudyMode;
    final showCorrectAnswerCount = quizConfig.showCorrectAnswerCount;

    return QuizQuestionOptions(
      state: state,
      showCorrectAnswerCount: showCorrectAnswerCount,
      isStudyMode: isStudyMode,
      onAskAi: onAskAi,
    );
  }
}
