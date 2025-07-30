import 'package:quiz_app/core/extensions/process_list_extension.dart';
import 'package:quiz_app/domain/models/custom_exceptions/regular_process_error.dart';
import 'package:quiz_app/domain/models/custom_exceptions/regular_process_error_type.dart';
import 'package:quiz_app/domain/models/maso/maso_file.dart';

import '../models/custom_exceptions/burst_process_error.dart';
import '../models/custom_exceptions/burst_process_error_type.dart';
import '../models/maso/burst_process.dart';
import '../models/maso/burst_type.dart';

class ValidateMasoProcessUseCase {
  static BurstProcessError validateBurstProcess({
    required String processNameString,
    required String arrivalTimeString,
    required int? processPosition,
    required MasoFile masoFile,
    required BurstProcess cachedProcess,
  }) {
    final name = processNameString.trim();
    final arrivalTime = int.tryParse(arrivalTimeString);

    // Validate name input.
    if (name.isEmpty) {
      return BurstProcessError(
        errorType: BurstProcessErrorType.emptyName,
        param1: processPosition,
      );
    }

    // Check for duplicate process names.
    if (masoFile.processes.elements.containProcessWithName(
      name,
      position: processPosition,
    )) {
      return BurstProcessError(errorType: BurstProcessErrorType.duplicatedName);
    }

    // Validate arrival time input.
    if (arrivalTime == null || arrivalTime < 0) {
      return BurstProcessError(
        errorType: BurstProcessErrorType.invalidArrivalTime,
        param1: name,
      );
    }

    for (final thread in cachedProcess.threads) {
      if (thread.id.isEmpty) {
        return BurstProcessError(
          errorType: BurstProcessErrorType.emptyThread,
          param1: name,
        );
      }
      final bursts = thread.bursts;
      if (bursts.isEmpty) {
        return BurstProcessError(
          errorType: BurstProcessErrorType.emptyThread,
          param1: name,
        );
      } else if (bursts.first.type != BurstType.cpu ||
          bursts.last.type != BurstType.cpu) {
        return BurstProcessError(
          errorType: BurstProcessErrorType.startAndEndCpuSequence,
          param1: processNameString,
          param2: thread.id,
        );
      }
      for (int i = 0; i < bursts.length - 1; i++) {
        if (bursts[i].type == BurstType.io &&
            bursts[i + 1].type == BurstType.io) {
          return BurstProcessError(
            errorType: BurstProcessErrorType.invalidBurstSequence,
            param1: processNameString,
            param2: thread.id,
          );
        } else if (bursts[i].duration <= 0) {
          return BurstProcessError(
            errorType: BurstProcessErrorType.invalidBurstDuration,
            param1: i.toString(),
            param2: name,
            param3: thread.id,
          );
        }
      }
    }

    return BurstProcessError.success();
  }

  /// Validate the input fields.
  static RegularProcessError validateRegularProcess(
    String nameString,
    String arrivalTimeString,
    String serviceTimeString,
    int? processPosition,
    MasoFile masoFile,
  ) {
    final name = nameString.trim();
    final arrivalTime = int.tryParse(arrivalTimeString);
    final serviceTime = int.tryParse(serviceTimeString);

    // Validate name input.
    if (name.isEmpty) {
      return RegularProcessError(
        errorType: RegularProcessErrorType.emptyName,
        param1: processPosition,
      );
    }

    // Check for duplicate process names.
    if (masoFile.processes.elements.containProcessWithName(
      name,
      position: processPosition,
    )) {
      return RegularProcessError(
        errorType: RegularProcessErrorType.duplicatedName,
      );
    }

    // Validate arrival time input.
    if (arrivalTime == null || arrivalTime < 0) {
      return RegularProcessError(
        errorType: RegularProcessErrorType.invalidArrivalTime,
        param1: name,
      );
    }

    // Validate service time input.
    if (serviceTime == null || serviceTime < 1) {
      return RegularProcessError(
        errorType: RegularProcessErrorType.invalidServiceTime,
        param1: name,
      );
    }

    return RegularProcessError.success(); // Input is valid.
  }
}
