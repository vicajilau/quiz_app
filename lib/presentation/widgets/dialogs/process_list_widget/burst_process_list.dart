import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_app/domain/models/maso/maso_file.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../domain/models/maso/burst_process.dart';
import '../../../../domain/models/maso/thread.dart';
import '../add_edit_process_dialog/add_edit_process_dialog.dart';

class BurstProcessList extends StatefulWidget {
  final MasoFile masoFile;
  final VoidCallback onFileChange;

  const BurstProcessList({
    super.key,
    required this.masoFile,
    required this.onFileChange,
  });

  @override
  State<BurstProcessList> createState() => _BurstProcessListState();
}

class _BurstProcessListState extends State<BurstProcessList> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      onReorder: _onReorder,
      itemCount: widget.masoFile.processes.elements.length,
      itemBuilder: (context, index) {
        final process =
            widget.masoFile.processes.elements[index] as BurstProcess;

        return _buildDismissible(
          process,
          index,
          Container(
            key: ValueKey(process.id),
            child: Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _editProcess(process, index),
                    child: ExpansionTile(
                      title: Text(process.id),
                      subtitle: Text(
                        AppLocalizations.of(
                          context,
                        )!.arrivalTimeLabel(process.arrivalTime.toString()),
                      ),
                      leading: Switch(
                        value: process.enabled,
                        onChanged: (value) {
                          setState(() {
                            process.enabled = value;
                            for (var thread in process.threads) {
                              thread.enabled = value;
                            }
                            widget.onFileChange();
                          });
                        },
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                      ),
                      children: process.threads
                          .map((thread) => _buildThreadTile(thread))
                          .toList(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editProcess(process, index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editProcess(BurstProcess process, int index) async {
    final result = await showDialog<BurstProcess>(
      context: context,
      builder: (context) => AddEditProcessDialog(
        process: process,
        masoFile: widget.masoFile,
        processPosition: index,
      ),
    );
    if (result != null) {
      setState(() {
        widget.masoFile.processes.elements[index] = result;
        widget.onFileChange();
      });
    }
  }

  Widget _buildThreadTile(Thread thread) {
    String subtitle = thread.bursts
        .map((burst) {
          return '${burst.type.description(context)} - ${burst.duration}ut';
        })
        .join(', ');

    return ListTile(
      title: Text(AppLocalizations.of(context)!.threadIdLabel(thread.id)),
      subtitle: Text(
        "${AppLocalizations.of(context)!.processModeBurst}: [$subtitle]",
      ),
      leading: Switch(
        value: thread.enabled,
        onChanged: (value) {
          setState(() {
            thread.enabled = value;
            widget.onFileChange();
          });
        },
        activeColor: Colors.green,
        inactiveThumbColor: Colors.red,
      ),
    );
  }

  Future<bool> _confirmDismiss(
    BuildContext context,
    BurstProcess process,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.confirmDeleteTitle),
            content: Text(
              AppLocalizations.of(context)!.confirmDeleteMessage(process.id),
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(false),
                child: Text(AppLocalizations.of(context)!.cancelButton),
              ),
              ElevatedButton(
                onPressed: () => context.pop(true),
                child: Text(AppLocalizations.of(context)!.deleteButton),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final process = widget.masoFile.processes.elements.removeAt(oldIndex);
      widget.masoFile.processes.elements.insert(newIndex, process);
      widget.onFileChange();
    });
  }

  Widget _buildDismissible(BurstProcess process, int index, Widget child) {
    return Dismissible(
      key: ValueKey(process.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) => _confirmDismiss(context, process),
      onDismissed: (direction) {
        setState(() {
          widget.masoFile.processes.elements.removeAt(index);
          widget.onFileChange();
        });
      },
      background: _buildDismissBackground(alignment: Alignment.centerLeft),
      secondaryBackground: _buildDismissBackground(
        alignment: Alignment.centerRight,
      ),
      child: child,
    );
  }

  Widget _buildDismissBackground({required Alignment alignment}) {
    return Container(
      color: Colors.red,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }
}
