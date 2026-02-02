import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../domain/models/quiz/question_order.dart';

/// A widget that handles the question order configuration section.
///
/// Allows the user to select the order of questions (ascending, descending, random),
/// toggle answer randomization, and toggle showing the correct answer count.
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.questionOrderConfigDescription,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        ...QuestionOrder.values.map((order) {
          return RadioGroup<QuestionOrder>(
            groupValue: selectedOrder,
            onChanged: (QuestionOrder? value) {
              if (value != null) {
                onOrderChanged(value);
              }
            },
            child: RadioListTile<QuestionOrder>(
              title: Text(_getLocalizedOrderName(context, order)),
              subtitle: Text(_getLocalizedOrderDescription(context, order)),
              value: order,
            ),
          );
        }),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(AppLocalizations.of(context)!.randomizeAnswersTitle),
          subtitle: Text(
            AppLocalizations.of(context)!.randomizeAnswersDescription,
          ),
          value: randomizeAnswers,
          onChanged: onRandomizeAnswersChanged,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(
            AppLocalizations.of(context)!.showCorrectAnswerCountTitle,
          ),
          subtitle: Text(
            AppLocalizations.of(context)!.showCorrectAnswerCountDescription,
          ),
          value: showCorrectAnswerCount,
          onChanged: onShowCorrectAnswerCountChanged,
        ),
      ],
    );
  }

  String _getLocalizedOrderName(BuildContext context, QuestionOrder order) {
    switch (order) {
      case QuestionOrder.ascending:
        return AppLocalizations.of(context)!.questionOrderAscending;
      case QuestionOrder.descending:
        return AppLocalizations.of(context)!.questionOrderDescending;
      case QuestionOrder.random:
        return AppLocalizations.of(context)!.questionOrderRandom;
    }
  }

  String _getLocalizedOrderDescription(
    BuildContext context,
    QuestionOrder order,
  ) {
    switch (order) {
      case QuestionOrder.ascending:
        return AppLocalizations.of(context)!.questionOrderAscendingDesc;
      case QuestionOrder.descending:
        return AppLocalizations.of(context)!.questionOrderDescendingDesc;
      case QuestionOrder.random:
        return AppLocalizations.of(context)!.questionOrderRandomDesc;
    }
  }
}
