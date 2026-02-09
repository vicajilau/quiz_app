import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:quiz_app/data/services/ai/ai_question_generation_service.dart';
import 'package:quiz_app/domain/models/quiz/question_type.dart';

class AiQuestionTypeChip extends StatelessWidget {
  final AiQuestionType type;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const AiQuestionTypeChip({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    IconData icon;

    switch (type) {
      case AiQuestionType.multipleChoice:
        label = QuestionType.multipleChoice.getQuestionTypeLabel(context);
        icon = QuestionType.multipleChoice.getQuestionTypeIcon();
        break;
      case AiQuestionType.singleChoice:
        label = QuestionType.singleChoice.getQuestionTypeLabel(context);
        icon = QuestionType.singleChoice.getQuestionTypeIcon();
        break;
      case AiQuestionType.trueFalse:
        label = QuestionType.trueFalse.getQuestionTypeLabel(context);
        icon = QuestionType.trueFalse.getQuestionTypeIcon();
        break;
      case AiQuestionType.essay:
        label = QuestionType.essay.getQuestionTypeLabel(context);
        icon = QuestionType.essay.getQuestionTypeIcon();
        break;
      case AiQuestionType.random:
        label = 'Random';
        icon = LucideIcons.shuffle;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8B5CF6)
              : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFF4F4F5)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? LucideIcons.checkCircle2 : icon,
              size: 14,
              color: isSelected
                  ? Colors.white
                  : (isDark
                        ? const Color(0xFFA1A1AA)
                        : const Color(0xFF71717A)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? const Color(0xFFA1A1AA)
                          : const Color(0xFF71717A)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
