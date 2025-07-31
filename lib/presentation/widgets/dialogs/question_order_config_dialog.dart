import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/services/configuration_service.dart';
import '../../../domain/models/quiz/question_order.dart';

class QuestionOrderConfigDialog extends StatefulWidget {
  const QuestionOrderConfigDialog({super.key});

  @override
  State<QuestionOrderConfigDialog> createState() =>
      _QuestionOrderConfigDialogState();
}

class _QuestionOrderConfigDialogState extends State<QuestionOrderConfigDialog> {
  QuestionOrder _selectedOrder = QuestionOrder.random;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentOrder();
  }

  Future<void> _loadCurrentOrder() async {
    final currentOrder = await ConfigurationService.instance.getQuestionOrder();
    setState(() {
      _selectedOrder = currentOrder;
      _isLoading = false;
    });
  }

  Future<void> _saveOrder() async {
    await ConfigurationService.instance.saveQuestionOrder(_selectedOrder);
    if (mounted) {
      context.pop(_selectedOrder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.questionOrderConfigTitle),
      content: _isLoading
          ? const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.questionOrderConfigDescription,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                ...QuestionOrder.values.map((order) {
                  return RadioListTile<QuestionOrder>(
                    title: Text(_getLocalizedOrderName(context, order)),
                    subtitle: Text(
                      _getLocalizedOrderDescription(context, order),
                    ),
                    value: order,
                    groupValue: _selectedOrder,
                    onChanged: (QuestionOrder? value) {
                      if (value != null) {
                        setState(() {
                          _selectedOrder = value;
                        });
                      }
                    },
                  );
                }),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveOrder,
          child: Text(AppLocalizations.of(context)!.saveButton),
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
