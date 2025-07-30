import 'package:flutter/material.dart';
import 'package:quiz_app/domain/models/custom_exceptions/process_error.dart';
import 'package:quiz_app/domain/models/custom_exceptions/regular_process_error_type.dart';

import '../../../core/l10n/app_localizations.dart';

class RegularProcessError implements ProcessError {
  final RegularProcessErrorType errorType;
  final Object? param1;
  final Object? param2;
  final Object? param3;
  @override
  final bool success;

  RegularProcessError({
    required this.errorType,
    this.param1,
    this.param2,
    this.param3,
    this.success = false,
  });

  RegularProcessError.success()
    : this(success: true, errorType: RegularProcessErrorType.emptyName);

  @override
  String getDescriptionForInputError(BuildContext context) {
    switch (errorType) {
      case RegularProcessErrorType.emptyName:
        return AppLocalizations.of(context)!.emptyNameError;
      case RegularProcessErrorType.duplicatedName:
        return AppLocalizations.of(context)!.duplicateNameError;
      case RegularProcessErrorType.invalidArrivalTime:
        return AppLocalizations.of(context)!.invalidArrivalTimeError;
      case RegularProcessErrorType.invalidServiceTime:
        return AppLocalizations.of(context)!.invalidServiceTimeError;
    }
  }

  @override
  String getDescriptionForFileError(BuildContext context) {
    switch (errorType) {
      case RegularProcessErrorType.emptyName:
        return AppLocalizations.of(
          context,
        )!.emptyNameProcessBadContent(param1!);
      case RegularProcessErrorType.duplicatedName:
        return AppLocalizations.of(context)!.duplicatedNameProcessBadContent;
      case RegularProcessErrorType.invalidArrivalTime:
        return AppLocalizations.of(
          context,
        )!.invalidArrivalTimeBadContent(param1!);
      case RegularProcessErrorType.invalidServiceTime:
        return AppLocalizations.of(
          context,
        )!.invalidServiceTimeBadContent(param1!);
    }
  }
}
