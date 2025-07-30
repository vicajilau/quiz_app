import 'package:flutter/material.dart';
import 'package:quiz_app/domain/models/maso/maso_file.dart';

import '../../../../domain/models/maso/process_mode.dart';
import 'add_edit_burst_process_dialog.dart';
import 'add_edit_regular_process_dialog.dart';

/// A dialog widget that redirects to the appropriate process dialog
/// based on the current `ProcessesMode` of the `masoFile`.
class AddEditProcessDialog extends StatelessWidget {
  final MasoFile masoFile; // Contains the processes and their mode.
  final dynamic process; // Can be RegularProcess or BurstProcess.
  final int? processPosition; // Optional index of the process.

  /// Constructor for initializing the `ProcessDialog`.
  const AddEditProcessDialog({
    super.key,
    required this.masoFile,
    this.process,
    this.processPosition,
  });

  @override
  Widget build(BuildContext context) {
    switch (masoFile.processes.mode) {
      case ProcessesMode.regular:
        return AddEditRegularProcessDialog(
          masoFile: masoFile,
          process: process,
          processPosition: processPosition,
        );
      case ProcessesMode.burst:
        return AddEditBurstProcessDialog(
          masoFile: masoFile,
          process: process,
          processPosition: processPosition,
        );
    }
  }
}
