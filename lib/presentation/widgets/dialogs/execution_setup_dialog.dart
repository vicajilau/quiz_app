import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/domain/models/scheduling_algorithm.dart';
import 'package:quiz_app/domain/models/settings_maso.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/service_locator.dart';
import '../../../domain/models/execution_setup.dart';

class ExecutionSetupDialog extends StatefulWidget {
  const ExecutionSetupDialog({super.key});

  @override
  State<ExecutionSetupDialog> createState() => _ExecutionSetupDialogState();
}

class _ExecutionSetupDialogState extends State<ExecutionSetupDialog> {
  ExecutionSetup? _previousES;
  SchedulingAlgorithm _selectedAlgorithm =
      SchedulingAlgorithm.firstComeFirstServed;
  final TextEditingController _quantumController = TextEditingController();
  final TextEditingController _queueQuantaController = TextEditingController();
  final TextEditingController _timeLimitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (ServiceLocator.instance.getIt.isRegistered<ExecutionSetup>()) {
      _previousES = ServiceLocator.instance.getIt<ExecutionSetup>();
      _selectedAlgorithm = _previousES!.algorithm;
      _quantumController.text = _previousES!.settings.quantum.toString();
      _queueQuantaController.text = _previousES!.settings.queueQuanta
          .toString();
      _timeLimitController.text = _previousES!.settings.timeLimit.toString();
    }
  }

  @override
  void dispose() {
    _quantumController.dispose();
    _queueQuantaController.dispose();
    _timeLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width (you can also adjust the multiplier based on your design)
    double screenWidth = MediaQuery.of(context).size.width;
    double maxWidth = screenWidth * 0.5;

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.executionSetupTitle),
      content: SingleChildScrollView(
        // Allow scrolling in case of long text
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<SchedulingAlgorithm>(
              value: _selectedAlgorithm,
              onChanged: (SchedulingAlgorithm? newValue) {
                setState(() {
                  _selectedAlgorithm = newValue!;
                });
              },
              items: SchedulingAlgorithm.values.map((algorithm) {
                return DropdownMenuItem<SchedulingAlgorithm>(
                  value: algorithm,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!.algorithmLabel(algorithm.name),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.selectAlgorithmLabel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedAlgorithm == SchedulingAlgorithm.roundRobin)
              TextFormField(
                controller: _quantumController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.quantumLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
            if (_selectedAlgorithm ==
                SchedulingAlgorithm.multiplePriorityQueuesWithFeedback)
              TextFormField(
                controller: _queueQuantaController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.queueQuantaLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
            if (_selectedAlgorithm == SchedulingAlgorithm.timeLimit)
              TextFormField(
                controller: _timeLimitController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.timeLimitLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(AppLocalizations.of(context)!.cancelButton),
        ),
        ElevatedButton(
          onPressed: () async {
            final settings = ServiceLocator.instance.getIt<SettingsMaso>();

            if (_selectedAlgorithm == SchedulingAlgorithm.roundRobin) {
              final parsed = int.tryParse(_quantumController.text);
              if (parsed == null || parsed <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.invalidQuantumError,
                    ),
                  ),
                );
                return;
              }
              settings.quantum = parsed;
            } else if (_selectedAlgorithm ==
                SchedulingAlgorithm.multiplePriorityQueuesWithFeedback) {
              final parsed = _queueQuantaController.text
                  .replaceAll('[', '')
                  .replaceAll(']', '')
                  .split(',')
                  .map((e) => int.tryParse(e.trim()))
                  .toList();

              // Check if there is any null or <= 0 value
              final isInvalid = parsed.any((e) => e == null || e <= 0);
              if (isInvalid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.invalidQueueQuantaError,
                    ),
                  ),
                );
                return;
              }

              settings.queueQuanta = parsed.cast<int>();
            } else if (_selectedAlgorithm == SchedulingAlgorithm.timeLimit) {
              final parsed = int.tryParse(_timeLimitController.text);
              if (parsed == null || parsed <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.invalidTimeLimitError,
                    ),
                  ),
                );
                return;
              }
              settings.timeLimit = parsed;
            }
            await settings.saveToPreferences();
            ServiceLocator.instance.registerSettings(settings);

            if (!context.mounted) return;
            context.pop(
              ExecutionSetup(algorithm: _selectedAlgorithm, settings: settings),
            );
          },
          child: Text(AppLocalizations.of(context)!.acceptButton),
        ),
      ],
    );
  }
}
