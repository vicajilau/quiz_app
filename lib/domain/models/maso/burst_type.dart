import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';

enum BurstType {
  cpu,
  io;

  /// Converts a string to a `BurstType` enum.
  ///
  /// This method parses the input string and returns the corresponding
  /// `BurstType` value. If the input does not match any defined mode,
  /// an `ArgumentError` is thrown.
  ///
  /// - [value]: A string representation of the mode.
  /// - Returns: The matching `BurstType` value.
  /// - Throws: `ArgumentError` if the input string is invalid.
  static BurstType fromJson(String value) {
    switch (value) {
      case 'cpu':
        return BurstType.cpu;
      case 'io':
        return BurstType.io;
    }
    throw ArgumentError("Invalid BurstType value: $value");
  }

  /// Converts a `BurstType` enum to a string.
  String description(BuildContext context) {
    switch (this) {
      case BurstType.cpu:
        return AppLocalizations.of(context)!.burstCpuType;
      case BurstType.io:
        return AppLocalizations.of(context)!.burstIoType;
    }
  }
}
