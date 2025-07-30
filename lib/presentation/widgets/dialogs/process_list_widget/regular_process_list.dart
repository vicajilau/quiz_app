import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../domain/models/maso/i_process.dart';
import '../../../../domain/models/maso/maso_file.dart';
import '../../../../domain/models/maso/regular_process.dart';
import '../add_edit_process_dialog/add_edit_process_dialog.dart';

class RegularProcessList extends StatefulWidget {
  final MasoFile masoFile;
  final VoidCallback onFileChange;
  const RegularProcessList({
    super.key,
    required this.masoFile,
    required this.onFileChange,
  });

  @override
  State<RegularProcessList> createState() => _RegularProcessListState();
}

class _RegularProcessListState extends State<RegularProcessList> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      onReorder: _onReorder,
      children:
          List.generate(widget.masoFile.processes.elements.length, (index) {
        final process =
            widget.masoFile.processes.elements[index] as RegularProcess;
        return _buildDismissible(
          process,
          index,
          _buildListTile(
            process,
            index,
            '${AppLocalizations.of(context)!.arrivalTimeLabel(process.arrivalTime.toString())} '
            '${AppLocalizations.of(context)!.serviceTimeLabel(process.serviceTime.toString())}',
          ),
        );
      }),
    );
  }

  Widget _buildListTile(IProcess process, int index, String subtitle) {
    return ListTile(
      title: Text(process.id),
      subtitle: Text(subtitle),
      leading: Switch(
        value: process.enabled,
        onChanged: (value) {
          setState(() {
            process.enabled = value;
            widget.onFileChange();
          });
        },
        activeColor: Colors.green,
        inactiveThumbColor: Colors.red,
      ),
      onTap: () async {
        final updatedProcess = await showDialog<RegularProcess>(
          context: context,
          builder: (context) => AddEditProcessDialog(
            process: process,
            masoFile: widget.masoFile,
            processPosition: index,
          ),
        );
        if (updatedProcess != null) {
          setState(() {
            widget.masoFile.processes.elements[index] = updatedProcess;
            widget.onFileChange();
          });
        }
      },
    );
  }

  Future<bool> _confirmDismiss(BuildContext context, IProcess process) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.confirmDeleteTitle),
            content: Text(
                AppLocalizations.of(context)!.confirmDeleteMessage(process.id)),
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

  Widget _buildDismissible(IProcess process, int index, Widget child) {
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
      secondaryBackground:
          _buildDismissBackground(alignment: Alignment.centerRight),
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
