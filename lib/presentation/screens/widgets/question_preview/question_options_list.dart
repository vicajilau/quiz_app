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
import 'package:quizdy/domain/models/quiz/question.dart';
import 'package:quizdy/presentation/widgets/quizdy_latex_text.dart';
import 'package:quizdy/core/theme/extensions/custom_colors.dart';

class QuestionOptionsList extends StatelessWidget {
  final Question question;
  final bool isDisabled;

  const QuestionOptionsList({
    super.key,
    required this.question,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    final successColor = Theme.of(context).extension<CustomColors>()!.success!;

    return Column(
      children: question.options.asMap().entries.map((entry) {
        final idx = entry.key;
        final option = entry.value;
        final isCorrect = question.correctAnswers.contains(idx);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isCorrect
                ? successColor.withValues(alpha: 0.05)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCorrect
                  ? successColor.withValues(alpha: 0.5)
                  : Theme.of(context).dividerColor,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Option Letter Circle
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isCorrect ? successColor : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCorrect
                        ? successColor
                        : Theme.of(context).dividerColor,
                    width: 2,
                  ),
                ),
                child: isCorrect
                    ? const Icon(
                        LucideIcons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : Text(
                        String.fromCharCode(65 + idx),
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              // Option Text
              Expanded(
                child: QuizdyLatexText(
                  option,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: isCorrect ? FontWeight.w600 : FontWeight.w500,
                    decoration: isDisabled ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
