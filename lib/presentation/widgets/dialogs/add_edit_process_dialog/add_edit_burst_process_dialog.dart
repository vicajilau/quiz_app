import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/domain/models/custom_exceptions/burst_process_error_type.dart';
import 'package:quiz_app/domain/models/maso/burst_process.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../domain/models/maso/burst.dart';
import '../../../../domain/models/maso/burst_type.dart';
import '../../../../domain/models/maso/maso_file.dart';
import '../../../../domain/models/maso/thread.dart';
import '../../../../domain/use_cases/validate_maso_regular_processes_use_case.dart';

class AddEditBurstProcessDialog extends StatefulWidget {
  final BurstProcess? process;
  final MasoFile masoFile;
  final int? processPosition;

  const AddEditBurstProcessDialog({
    super.key,
    this.process,
    required this.masoFile,
    this.processPosition,
  });

  @override
  State<AddEditBurstProcessDialog> createState() =>
      _AddEditBurstProcessDialogState();
}

class _AddEditBurstProcessDialogState extends State<AddEditBurstProcessDialog> {
  late TextEditingController _idController;
  late TextEditingController _arrivalTimeController;
  late BurstProcess cachedProcess;
  String? _idError;
  String? _arrivalTimeError;
  String? _burstSequenceError;
  List<List<TextEditingController>> threadControllersBurstList = [];

  @override
  void initState() {
    super.initState();
    cachedProcess =
        widget.process?.copy() ??
        BurstProcess(id: '', arrivalTime: 0, threads: [], enabled: true);

    _idController = TextEditingController(text: widget.process?.id);
    _arrivalTimeController = TextEditingController(
      text: widget.process?.arrivalTime.toString(),
    );
    _initializeBurstControllers();
  }

  void _initializeBurstControllers() {
    threadControllersBurstList.clear();
    for (int i = 0; i < cachedProcess.threads.length; i++) {
      List<TextEditingController> burstControllersList = [];
      for (int j = 0; j < cachedProcess.threads[i].bursts.length; j++) {
        final burstController = TextEditingController(
          text: cachedProcess.threads[i].bursts[j].duration.toString(),
        );
        burstControllersList.add(burstController);
      }
      threadControllersBurstList.add(burstControllersList);
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _arrivalTimeController.dispose();
    for (var burstControllerList in threadControllersBurstList) {
      for (var controller in burstControllerList) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  bool _validateInput() {
    setState(() {
      _idError = null;
      _arrivalTimeError = null;
      _burstSequenceError = null;
    });
    final validateInput = ValidateMasoProcessUseCase.validateBurstProcess(
      processNameString: _idController.text,
      arrivalTimeString: _arrivalTimeController.text,
      processPosition: widget.processPosition,
      masoFile: widget.masoFile,
      cachedProcess: cachedProcess,
    );
    if (validateInput.success) return true;
    switch (validateInput.errorType) {
      case BurstProcessErrorType.emptyName:
        _idError = validateInput.getDescriptionForInputError(context);
      case BurstProcessErrorType.duplicatedName:
        _idError = validateInput.getDescriptionForInputError(context);
      case BurstProcessErrorType.invalidArrivalTime:
        _arrivalTimeError = validateInput.getDescriptionForInputError(context);
      case BurstProcessErrorType.emptyBurst:
        _burstSequenceError = validateInput.getDescriptionForInputError(
          context,
        );
      case BurstProcessErrorType.emptyThread:
        _burstSequenceError = validateInput.getDescriptionForInputError(
          context,
        );
      case BurstProcessErrorType.startAndEndCpuSequence:
        _burstSequenceError = validateInput.getDescriptionForInputError(
          context,
        );
      case BurstProcessErrorType.invalidBurstSequence:
        _burstSequenceError = validateInput.getDescriptionForInputError(
          context,
        );
      case BurstProcessErrorType.invalidBurstDuration:
        _burstSequenceError = validateInput.getDescriptionForInputError(
          context,
        );
    }

    return false;
  }

  void _submit() {
    if (_validateInput()) {
      context.pop(
        BurstProcess(
          id: _idController.text.trim(),
          arrivalTime: int.parse(_arrivalTimeController.text),
          threads: cachedProcess.threads,
          enabled: cachedProcess.enabled,
        ),
      );
    }
  }

  void _addThread() {
    setState(() {
      cachedProcess.threads.add(
        Thread(
          id: 'Thread ${cachedProcess.threads.length + 1}',
          bursts: [],
          enabled: true,
        ),
      );
      threadControllersBurstList.add([]);
    });
  }

  void _addBurst(Thread thread, int threadIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectBurstType),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: BurstType.values.map((type) {
            return ListTile(
              title: Text(type.description(context)),
              onTap: () {
                setState(() {
                  thread.bursts.add(Burst(type: type, duration: 0));
                  final burstController = TextEditingController();
                  threadControllersBurstList[threadIndex].add(burstController);
                });
                context.pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _removeThread(Thread thread, int threadIndex) {
    setState(() {
      cachedProcess.threads.remove(thread);
      threadControllersBurstList.removeAt(threadIndex);
    });
  }

  void _removeBurst(Thread thread, int threadIndex, int burstIndex) {
    // printInDebug("Before removed burst $burstIndex on Thread: $thread");
    thread.bursts.removeAt(burstIndex);
    threadControllersBurstList[threadIndex].removeAt(burstIndex);
    setState(() {
      // printInDebug("Removed burst $burstIndex on Thread: $thread");
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.createBurstProcessTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _idController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.processIdLabel,
                      errorText: _idError,
                    ),
                    onChanged: (value) => setState(() => _idError = null),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _arrivalTimeController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(
                        context,
                      )!.arrivalTimeLabelDecorator,
                      errorText: _arrivalTimeError,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) =>
                        setState(() => _arrivalTimeError = null),
                  ),
                ),
              ],
            ),
            if (_burstSequenceError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _burstSequenceError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ...cachedProcess.threads.asMap().entries.map((threadEntry) {
              final thread = threadEntry.value;
              final threadIndex = threadEntry.key;
              return ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(thread.id),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              AppLocalizations.of(context)!.deleteThreadTitle,
                            ),
                            content: Text(
                              AppLocalizations.of(
                                context,
                              )!.deleteThreadConfirmation(thread.id),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => context.pop(),
                                child: Text(
                                  AppLocalizations.of(context)!.cancelButton,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _removeThread(thread, threadIndex);
                                  context.pop();
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.confirmButton,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                children: [
                  ...thread.bursts.asMap().entries.map((burstEntry) {
                    final burst = burstEntry.value;
                    final burstIndex = burstEntry.key;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Card(
                        child: ExpansionTile(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!.burstNameLabel(burstIndex + 1),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.deleteBurstTitle,
                                  ),
                                  content: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.deleteBurstConfirmation(
                                      burst.duration.toString(),
                                      burst.type.description(context),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => context.pop(),
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.cancelButton,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _removeBurst(
                                          thread,
                                          threadIndex,
                                          burstIndex,
                                        );
                                        context.pop();
                                      },
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.confirmButton,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 10,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.burstTypeLabel,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                      DropdownButton<BurstType>(
                                        value: burst.type,
                                        onChanged: (newType) {
                                          setState(() {
                                            burst.type = newType!;
                                          });
                                        },
                                        items: BurstType.values.map((type) {
                                          return DropdownMenuItem(
                                            value: type,
                                            child: Text(
                                              type.description(context),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                  TextFormField(
                                    controller:
                                        threadControllersBurstList[threadIndex][burstIndex],
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(
                                        context,
                                      )!.burstDurationLabel,
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        burst.duration =
                                            int.tryParse(value) ?? 0;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => _addBurst(thread, threadIndex),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: Text(AppLocalizations.of(context)!.addBurstButton),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }),
            ElevatedButton.icon(
              onPressed: _addThread,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(AppLocalizations.of(context)!.addThreadButton),
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
          onPressed: _submit,
          child: Text(AppLocalizations.of(context)!.saveButton),
        ),
      ],
    );
  }
}
