import 'package:flutter/material.dart';
import 'package:quiz_app/domain/models/custom_exceptions/burst_process_error_type.dart';
import 'package:quiz_app/domain/models/custom_exceptions/process_error.dart';

import '../../../core/l10n/app_localizations.dart';

class BurstProcessError implements ProcessError {
  final BurstProcessErrorType errorType;
  final Object? param1;
  final Object? param2;
  final Object? param3;
  @override
  final bool success;

  BurstProcessError({
    required this.errorType,
    this.param1,
    this.param2,
    this.param3,
    this.success = false,
  });

  BurstProcessError.success()
    : this(success: true, errorType: BurstProcessErrorType.emptyName);

  @override
  String getDescriptionForInputError(BuildContext context) {
    switch (errorType) {
      case BurstProcessErrorType.emptyName:
        return AppLocalizations.of(context)!.emptyNameError;
      case BurstProcessErrorType.duplicatedName:
        return AppLocalizations.of(context)!.duplicateNameError;
      case BurstProcessErrorType.invalidArrivalTime:
        return AppLocalizations.of(context)!.invalidArrivalTimeError;
      case BurstProcessErrorType.emptyThread:
        return AppLocalizations.of(context)!.emptyThreadError(param1!);
      case BurstProcessErrorType.startAndEndCpuSequence:
        return AppLocalizations.of(
          context,
        )!.startAndEndCpuSequenceError(param1!);
      case BurstProcessErrorType.invalidBurstSequence:
        return AppLocalizations.of(context)!.invalidBurstSequenceError(param1!);
      case BurstProcessErrorType.emptyBurst:
        return AppLocalizations.of(context)!.emptyBurstError(param1!, param2!);
      case BurstProcessErrorType.invalidBurstDuration:
        return AppLocalizations.of(
          context,
        )!.invalidBurstDuration(param1!, param2!, param3!);
    }
  }

  @override
  String getDescriptionForFileError(BuildContext context) {
    switch (errorType) {
      case BurstProcessErrorType.emptyName:
        return AppLocalizations.of(
          context,
        )!.emptyNameProcessBadContent(param1!);
      case BurstProcessErrorType.duplicatedName:
        return AppLocalizations.of(context)!.duplicatedNameProcessBadContent;
      case BurstProcessErrorType.invalidArrivalTime:
        return AppLocalizations.of(
          context,
        )!.invalidArrivalTimeBadContent(param1!);
      case BurstProcessErrorType.emptyThread:
        return AppLocalizations.of(context)!.emptyThreadError(param1!);
      case BurstProcessErrorType.startAndEndCpuSequence:
        return AppLocalizations.of(
          context,
        )!.startAndEndCpuSequenceBadContent(param1!, param2!);
      case BurstProcessErrorType.invalidBurstSequence:
        return AppLocalizations.of(
          context,
        )!.invalidBurstSequenceBadContent(param1!, param2!);
      case BurstProcessErrorType.emptyBurst:
        return AppLocalizations.of(context)!.emptyBurstError(param1!, param2!);
      case BurstProcessErrorType.invalidBurstDuration:
        return AppLocalizations.of(
          context,
        )!.invalidBurstDuration(param1!, param2!, param3!);
    }
  }
}
