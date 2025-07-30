import 'package:flutter/material.dart';
import 'package:quiz_app/presentation/widgets/dialogs/process_list_widget/regular_process_list.dart';

import '../../../../domain/models/maso/maso_file.dart';
import '../../../../domain/models/maso/process_mode.dart';
import 'burst_process_list.dart';

class ProcessListWidget extends StatelessWidget {
  final MasoFile maso;
  final VoidCallback onFileChange;

  const ProcessListWidget({
    super.key,
    required this.maso,
    required this.onFileChange,
  });

  @override
  Widget build(BuildContext context) {
    switch (maso.processes.mode) {
      case ProcessesMode.regular:
        return RegularProcessList(masoFile: maso, onFileChange: onFileChange);
      case ProcessesMode.burst:
        return BurstProcessList(masoFile: maso, onFileChange: onFileChange);
    }
  }
}
