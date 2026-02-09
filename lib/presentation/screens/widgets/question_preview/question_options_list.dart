import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quiz_app/domain/models/quiz/question.dart';
import 'package:quiz_app/presentation/widgets/latex_text.dart';
import 'package:quiz_app/core/theme/extensions/custom_colors.dart';

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
    return Column(
      children: question.options.asMap().entries.map((entry) {
        final idx = entry.key;
        final option = entry.value;
        final isCorrect = question.correctAnswers.contains(idx);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCorrect
                ? Theme.of(
                    context,
                  ).extension<CustomColors>()!.success!.withValues(alpha: 0.1)
                : Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCorrect
                  ? Theme.of(context).extension<CustomColors>()!.success!
                  : Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Option Letter Circle
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isCorrect
                      ? Theme.of(context).extension<CustomColors>()!.success
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCorrect
                        ? Theme.of(context).extension<CustomColors>()!.success!
                        : Theme.of(context).dividerColor,
                  ),
                ),
                child: isCorrect
                    ? const Icon(
                        LucideIcons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : Text(
                        String.fromCharCode(65 + idx),
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              // Option Text
              Expanded(
                child: LaTeXText(
                  option,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontFamily: 'Inter',
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
