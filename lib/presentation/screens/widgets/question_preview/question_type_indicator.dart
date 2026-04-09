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
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quizdy/core/l10n/app_localizations.dart';
import 'package:quizdy/domain/models/quiz/question_type.dart';

class QuestionTypeIndicator extends StatelessWidget {
  final QuestionType questionType;
  final bool showText;

  const QuestionTypeIndicator({
    super.key,
    required this.questionType,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(context),
        if (showText) ...[const SizedBox(width: 6), _buildText(context)],
      ],
    );
  }

  Widget _buildIcon(BuildContext context) {
    IconData icon;
    switch (questionType.value) {
      case 'multiple_choice':
        icon = LucideIcons.checkSquare;
        break;
      case 'true_false':
        icon = LucideIcons.circleDot;
        break;
      case 'single_choice':
        icon = LucideIcons.list;
        break;
      case 'essay':
        icon = LucideIcons.fileText;
        break;
      default:
        icon = LucideIcons.helpCircle;
    }

    return Icon(icon, size: 13, color: Theme.of(context).colorScheme.onSurface);
  }

  Widget _buildText(BuildContext context) {
    return Text(
      getQuestionTypeString(context, questionType),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }

  static String getQuestionTypeString(
    BuildContext context,
    QuestionType questionType,
  ) {
    switch (questionType.value) {
      case 'multiple_choice':
        return AppLocalizations.of(context)!.questionTypeMultipleChoice;
      case 'true_false':
        return AppLocalizations.of(context)!.questionTypeTrueFalse;
      case 'single_choice':
        return AppLocalizations.of(context)!.questionTypeSingleChoice;
      case 'essay':
        return AppLocalizations.of(context)!.questionTypeEssay;
      default:
        return AppLocalizations.of(context)!.questionTypeUnknown;
    }
  }
}
