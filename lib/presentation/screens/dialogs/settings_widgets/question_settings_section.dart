import 'package:flutter/material.dart';
import 'package:quiz_app/core/l10n/app_localizations.dart';
import 'package:quiz_app/domain/models/quiz/question_order.dart';

class QuestionSettingsSection extends StatelessWidget {
  final QuestionOrder selectedOrder;
  final bool randomizeAnswers;
  final bool showCorrectAnswerCount;
  final ValueChanged<QuestionOrder> onOrderChanged;
  final ValueChanged<bool> onRandomizeAnswersChanged;
  final ValueChanged<bool> onShowCorrectAnswerCountChanged;

  const QuestionSettingsSection({
    super.key,
    required this.selectedOrder,
    required this.randomizeAnswers,
    required this.showCorrectAnswerCount,
    required this.onOrderChanged,
    required this.onRandomizeAnswersChanged,
    required this.onShowCorrectAnswerCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF71717A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Order Section
        Text(
          AppLocalizations.of(context)!.questionOrderConfigDescription,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildOrderOption(
                context,
                order: QuestionOrder.ascending,
                isSelected: selectedOrder == QuestionOrder.ascending,
              ),
              const SizedBox(width: 12),
              _buildOrderOption(
                context,
                order: QuestionOrder.descending,
                isSelected: selectedOrder == QuestionOrder.descending,
              ),
              const SizedBox(width: 12),
              _buildOrderOption(
                context,
                order: QuestionOrder.random,
                isSelected: selectedOrder == QuestionOrder.random,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Randomize Answers Toggle
        _buildToggleRow(
          context,
          title: AppLocalizations.of(context)!.randomizeAnswersTitle,
          subtitle: AppLocalizations.of(context)!.randomizeAnswersDescription,
          value: randomizeAnswers,
          onChanged: onRandomizeAnswersChanged,
        ),

        const SizedBox(height: 12),

        // Show Correct Answer Count Toggle
        _buildToggleRow(
          context,
          title: AppLocalizations.of(context)!.showCorrectAnswerCountTitle,
          subtitle: AppLocalizations.of(
            context,
          )!.showCorrectAnswerCountDescription,
          value: showCorrectAnswerCount,
          onChanged: onShowCorrectAnswerCountChanged,
        ),
      ],
    );
  }

  Widget _buildOrderOption(
    BuildContext context, {
    required QuestionOrder order,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = const Color(0xFF8B5CF6);
    final inactiveBg = isDark
        ? const Color(0xFF3F3F46)
        : const Color(0xFFF4F4F5);
    final activeText = Colors.white;
    final inactiveText = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF71717A);

    String label;
    switch (order) {
      case QuestionOrder.ascending:
        label = AppLocalizations.of(context)!.questionOrderAscending;
        break;
      case QuestionOrder.descending:
        label = AppLocalizations.of(context)!.questionOrderDescending;
        break;
      case QuestionOrder.random:
        label = AppLocalizations.of(context)!.questionOrderRandom;
        break;
    }

    return InkWell(
      onTap: () => onOrderChanged(order),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : inactiveBg,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? activeText : inactiveText,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF3F3F46) : const Color(0xFFF4F4F5);
    final titleColor = isDark ? Colors.white : const Color(0xFF18181B);
    final subtitleColor = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF71717A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF8B5CF6),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: isDark
                ? const Color(0xFF52525B)
                : const Color(0xFFD4D4D8),
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
